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
