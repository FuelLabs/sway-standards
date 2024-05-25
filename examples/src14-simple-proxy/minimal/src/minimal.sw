contract;

use std::execution::run_external;
use std::constants::ZERO_B256;
use standards::src14::SRC14;

// use sha256("storage_SRC14") as base to avoid collisions
#[namespace(SRC14)]
storage {
    // target is at sha256("storage_SRC14_0")
    target: ContractId = ContractId::from(ZERO_B256),
}

impl SRC14 for Contract {
    #[storage(write)]
    fn set_proxy_target(new_target: ContractId) {
        storage.target.write(new_target);
    }
}

#[fallback]
#[storage(read)]
fn fallback() {
    // pass through any other method call to the target
    run_external(storage.target.read())
}
