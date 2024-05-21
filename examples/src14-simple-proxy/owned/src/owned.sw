contract;

use std::execution::run_external;
use std::constants::ZERO_B256;
use standards::src5::{AccessError, SRC5, State};
use standards::src14::SRC14;

/// The owner of this contract at deployment.
const INITIAL_OWNER: Identity = Identity::Address(Address::from(ZERO_B256));

// use sha256("storage_SRC14") as base to avoid collisions
#[namespace(SRC14)]
storage {
    target: ContractId = ContractId::from(ZERO_B256),
    owner: State = State::Initialized(INITIAL_OWNER),
}

impl SRC5 for Contract {
    #[storage(read)]
    fn owner() -> State {
        storage.owner.read()
    }
}

impl SRC14 for Contract {
    #[storage(write)]
    fn set_proxy_target(new_target: ContractId) {
        only_owner();
        storage.target.write(new_target);
    }
}

#[fallback]
#[storage(read)]
fn fallback() {
    // pass through any other method call to the target
    run_external(storage.target.read())
}

#[storage(read)]
fn only_owner() {
    require(
        storage
            .owner
            .read() == State::Initialized(msg_sender().unwrap()),
        AccessError::NotOwner,
    );
}
