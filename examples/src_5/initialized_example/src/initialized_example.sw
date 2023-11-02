contract;

use src_5::{SRC_5, Ownership, State};
use std::constants::ZERO_B256;

configurable { 
    // Replace ZERO_B256 with your address
    INITIAL_OWNER: Identity = Identity::Address(Address::from(ZERO_B256)),
}

storage {
    owner: Ownership = Ownership { state: State::Initialized(INITIAL_OWNER) },
}

impl SRC_5 for Contract {
    #[storage(read)]
    fn owner() -> State {
        storage.owner.read().state
    }
}
