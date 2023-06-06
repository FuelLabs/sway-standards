library;

/// Determines the state of ownership.
///
/// ### Variants
///
/// * `Uninitialized`: () - The ownership has not been set.
/// * `Initialized`: `Identity` - The user which has been given ownership.
/// * `Revoked`: () - The ownership has been given up and can never be set again.
pub enum State {
    Uninitialized: (),
    Initialized: Identity,
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
///
/// ### Errors
///
/// * `NotOwner` - Emitted when the caller is not the owner of the contract.
pub enum AccessError {
    NotOwner: (),
}

/// Contains the ownership state.
///
/// ### Fields
///
/// * `owner`: `State` - Represents the state of ownership.
pub struct Ownership {
    owner: State,
}

abi SRC_5 {
    /// Returns the owner.
    ///
    /// ### Return Values
    ///
    /// * `State` - Represents the state of ownership for this contract.
    #[storage(read)]
    fn owner() -> State;
    /// Ensures that the sender is the owner.
    ///
    /// ### Reverts
    ///
    /// * When the sender is not the owner.
    #[storage(read)]
    fn only_owner();
}
