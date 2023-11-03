contract;

use src_5::{SRC_5, Ownership, State};
use std::constants::ZERO_B256;

configurable { 
    /// The owner of this contract at deployment.
    INITIAL_OWNER: Identity = Identity::Address(Address::from(ZERO_B256)),
}

storage {
    /// The owner in storage.
    owner: Ownership = Ownership { state: State::Initialized(INITIAL_OWNER) },
}

impl SRC_5 for Contract {
    /// Returns the owner.
    ///
    /// # Return Values
    ///
    /// * [State] - Represents the state of ownership for this contract.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src_5::SRC_5;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let ownership_abi = abi(contract_id, SRC_5);
    /// 
    ///     match ownership_abi.owner() {
    ///         State::Initialized(owner) => log("The ownership is initalized"),
    ///         _ => log("This example will never reach this statement"),
    ///     }
    /// }
    /// ```
    #[storage(read)]
    fn owner() -> State {
        storage.owner.read().state
    }
}
