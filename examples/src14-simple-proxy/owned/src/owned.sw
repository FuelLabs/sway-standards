contract;

use std::execution::run_external;
use standards::src5::{AccessError, State};
use standards::src14::{SRC14, SRC14Extension};

/// The owner of this contract at deployment.
const INITIAL_OWNER: Identity = Identity::Address(Address::zero());

// use sha256("storage_SRC14") as base to avoid collisions
#[namespace(SRC14)]
storage {
    // target is at sha256("storage_SRC14_0")
    target: ContractId = ContractId::zero(),
    owner: State = State::Initialized(INITIAL_OWNER),
}

impl SRC14 for Contract {
    #[storage(read, write)]
    fn set_proxy_target(new_target: ContractId) {
        only_owner();
        storage.target.write(new_target);
    }
}

impl SRC14Extension for Contract {
    #[storage(read)]
    fn proxy_owner() -> State {
        storage.owner.read()
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
