contract;

use std::execution::run_external;
use standards::src5::{AccessError, State};
use standards::src14::{SRC14, SRC14_TARGET_STORAGE, SRC14Extension};

/// The owner of this contract at deployment.
#[allow(dead_code)]
const INITIAL_OWNER: Identity = Identity::Address(Address::zero());

storage {
    proxy {
        // target is at sha256("storage_SRC14_0")
        owner: State = State::Initialized(INITIAL_OWNER),
    },
    target: ContractId = ContractId::zero(),
}

impl SRC14 for Contract {
    #[storage(read, write)]
    fn set_proxy_target(new_target: ContractId) {
        only_owner();
        storage.target.write(new_target);
    }

    #[storage(read)]
    fn proxy_target() -> Option<ContractId> {
        storage.target.try_read()
    }
}

impl SRC14Extension for Contract {
    #[storage(read)]
    fn proxy_owner() -> State {
        storage::proxy.owner.read()
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
        storage::proxy
            .owner
            .read() == State::Initialized(msg_sender().unwrap()),
        AccessError::NotOwner,
    );
}
