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

/// Error log for when access is denied.
pub enum AccessError {
    /// Emitted when the caller is not the owner of the contract.
    NotOwner: (),
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
    /// use standards::src5::{SRC5, State};
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

impl core::ops::Eq for AccessError {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Self::NotOwner, Self::NotOwner) => true,
        }
    }
}

impl State {
    /// Returns whether the state is uninitialized.
    ///
    /// # Return Values
    ///
    /// * [bool] - `true` if the state is uninitialized, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src5::{SRC5, State};
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC5, contract_id.bits());
    ///
    ///     let owner_state: State = contract_abi.owner();
    ///     assert(owner_state.is_uninitialized());
    /// }
    /// ```
    pub fn is_uninitialized(self) -> bool {
        match self {
            Self::Uninitialized => true,
            _ => false,
        }
    }

    /// Returns whether the state is initialized.
    ///
    /// # Return Values
    ///
    /// * [bool] - `true` if the state is initialized, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src5::{SRC5, State};
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC5, contract_id.bits());
    ///
    ///     let owner_state: State = contract_abi.owner();
    ///     assert(owner_state.is_initialized());
    /// }
    /// ```
    pub fn is_initialized(self) -> bool {
        match self {
            Self::Initialized(_) => true,
            _ => false,
        }
    }

    /// Returns whether the state is revoked.
    ///
    /// # Return Values
    ///
    /// * [bool] - `true` if the state is revoked, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src5::{SRC5, State};
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC5, contract_id.bits());
    ///
    ///     let owner_state: State = contract_abi.owner();
    ///     assert(owner_state.is_revoked());
    /// }
    /// ```
    pub fn is_revoked(self) -> bool {
        match self {
            Self::Revoked => true,
            _ => false,
        }
    }

    /// Returns the underlying owner as a `Identity`.
    ///
    /// # Returns
    ///
    /// * [Option<Identity>] - `Some` if the state is initialized, otherwise `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src5::{SRC5, State};
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC5, contract_id.bits());
    ///
    ///     let owner_state: State = contract_abi.owner();
    ///     assert(owner_state.owner().is_some());
    /// }
    /// ```
    pub fn owner(self) -> Option<Identity> {
        match self {
            Self::Initialized(owner) => Some(owner),
            _ => None,
        }
    }
}
