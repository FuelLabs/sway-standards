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
            (State::Initialized(owner1), State::Initialized(owner2)) => {
                owner1 == owner2
            },
            (State::Uninitialized, State::Uninitialized) => true,
            (State::Revoked, State::Revoked) => true,
            _ => false,
        }
    }
}

/// Error log for when access is denied.
pub enum AccessError {
    /// Emitted when the caller is not the owner of the contract.
    NotOwner: (),
}

/// Contains the ownership state.
pub struct Ownership {
    /// Represents the state of ownership.
    owner: State,
}

abi SRC_5 {
    /// Returns the owner.
    ///
    /// ### Return Values
    ///
    /// * [State] - Represents the state of ownership for this contract.
    ///
    /// ### Examples
    ///
    /// ```sway
    /// fn foo() {
    ///     let stored_owner = owner();
    /// }
    /// ```
    #[storage(read)]
    fn owner() -> State;

    /// Ensures that the sender is the owner.
    ///
    /// ### Reverts
    ///
    /// * When the sender is not the owner.
    ///
    /// ### Examples
    /// 
    /// fn foo() {
    ///     only_owner();
    ///     // Do stuff here
    /// }
    /// ```
    #[storage(read)]
    fn only_owner();
}
