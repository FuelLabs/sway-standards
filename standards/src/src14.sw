library;

use ::src5::State;

abi SRC14 {
    /// Change the target contract of a proxy contract.
    ///
    /// # Arguments
    ///
    /// * `new_target`: [ContractId] - The new proxy contract to which all fallback calls will be passed.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src14::SRC14;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC14, contract_id.bits());
    ///     let new_target = ContractId::from(0x4a778acfad1abc155a009dc976d2cf0db6197d3d360194d74b1fb92b96986b00);
    ///     contract_abi.set_proxy_target(new_target);
    /// }
    /// ```
    #[storage(read, write)]
    fn set_proxy_target(new_target: ContractId);

    /// Returns the target contract of a proxy contract.
    ///
    /// # Returns
    ///
    /// * [Option<ContractId>] - The new proxy contract to which all fallback calls will be passed or `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src14::SRC14;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC14, contract_id.bits());
    ///     let target_contract: Option<ContractId> = contract_abi.proxy_target();
    ///     assert(target_contract.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn proxy_target() -> Option<ContractId>;
}

abi SRC14Extension {
    /// Returns the owner of the proxy contract.
    ///
    /// # Returns
    ///
    /// * [State] - Represents the state of ownership for this contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src5::State, src14::{SRC14Extension, proxy_owner}};
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC14Extension, contract_id.bits());
    ///
    ///     match contract_abi.proxy_owner() {
    ///         State::Uninitialized => log("The ownership is uninitialized"),
    ///         State::Initialized(owner) => log("The ownership is initialized"),
    ///         State::Revoked => log("The ownership is revoked"),
    ///     }
    /// }
    /// ```
    #[storage(read)]
    fn proxy_owner() -> State;
}

/// The standard storage slot to store proxy target address.
///
/// Value is `sha256("storage_SRC14_0")`.
pub const SRC14_TARGET_STORAGE: b256 = 0x7bb458adc1d118713319a5baa00a2d049dd64d2916477d2688d76970c898cd55;
