library;

/// Determines the state of ownership.
pub enum State {
    /// The ownership has not been set.
    Uninitialized: (),
    /// The user which has been given ownership.
    Initialized: Identity,
    /// The ownership has been given up and can never be set again.
    Revoked: (),
}

impl core::ops::Eq for State {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Self::Initialized(owner1), Self::Initialized(owner2)) => {
                owner1 == owner2
            },
            (Self::Uninitialized, Self::Uninitialized) => true,
            (Self::Revoked, Self::Revoked) => true,
            _ => false,
        }
    }
}

/// Error log for when access is denied.
pub enum AccessError {
    /// Emitted when the caller is not the owner of the contract.
    NotOwner: (),
}

impl core::ops::Eq for AccessError {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Self::NotOwner, Self::NotOwner) => true,
        }
    }
}

abi SRC5 {
    /// Returns the owner.
    ///
    /// # Return Values
    ///
    /// * [State] - Represents the state of ownership for this contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src5::{SRC5, Owner, State};
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC5, contract_id.bits());
    ///
    ///     match contract_abi.owner() {
    ///         State::Uninitialized => log("The ownership is uninitialized"),
    ///         State::Initialized(owner) => log("The ownership is initialized"),
    ///         State::Revoked => log("The ownership is revoked"),
    ///     }
    /// }
    /// ```
    #[storage(read)]
    fn owner() -> State;
}
