contract;

use src_5::{SRC_5, Ownership, State};

storage {
    owner: Ownership = Ownership { 
        state: State::Uninitialized
    },
}

impl SRC_5 for Contract {
    #[storage(read)]
    fn owner() -> State {
        storage.owner.read().state
    }
}
