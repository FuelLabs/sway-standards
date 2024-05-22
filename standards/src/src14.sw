library;

abi SRC14 {
    /// Change the target address of a proxy contract.
    ///
    /// # Arguments
    ///
    /// * `new_target`: [ContractId] - The new proxy contract to which all fallback calls will be passed.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src14::SRC14;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC14, contract_id.bits());
    ///     let new_target = ContractId::from(0x4a778acfad1abc155a009dc976d2cf0db6197d3d360194d74b1fb92b96986b00);
    ///     contract_abi.set_proxy_target(new_target);
    /// }
    /// ```
    #[storage(write)]
    fn set_proxy_target(new_target: ContractId);
}

/// The standard storage slot to store proxy target address.
///
/// Value is `sha256("storage_SRC14_0")`.
pub const SRC14_TARGET_STORAGE: b256 = 0x7bb458adc1d118713319a5baa00a2d049dd64d2916477d2688d76970c898cd55;
