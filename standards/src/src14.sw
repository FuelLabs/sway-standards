library;

abi SRC14 {
    /// Change the target address of a proxy contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src14::SRC14;
    ///
    /// fn foo(contract: ContractId) {
    ///     let contract_abi = abi(SRC14, contract);
    ///     let new_target = ContractId::from(0x4a778acfad1abc155a009dc976d2cf0db6197d3d360194d74b1fb92b96986b00);
    ///     contract_abi.set_proxy_target(new_target);
    /// }
    /// ```
    #[storage(write)]
    fn set_proxy_target(new_target: ContractId);
}
