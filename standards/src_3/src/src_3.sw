library;

abi SRC3 {
    /// Mints new tokens using the `sub_id` sub-identifier.
    ///
    /// # Arguments
    ///
    /// * `recipient`: [Identity] - The user to which the newly minted tokens are transferred to.
    /// * `sub_id`: [SubId] - The sub-identifier of the newly minted token.
    /// * `amount`: [u64] - The quantity of tokens to mint.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    ///
    /// fn foo(contract: ContractId) {
    ///     let contract_abi = abi(SR3, contract);
    ///     contract_abi.mint(Identity::ContractId(this_contract()), ZERO_B256, 100);
    /// }
    /// ```
    fn mint(recipient: Identity, sub_id: SubId, amount: u64);

    /// Burns tokens sent with the given `sub_id`.
    ///
    /// # Additional Information
    ///
    /// NOTE: The sha-256 hash of `(ContractId, SubId)` must match the `AssetId` where `ContractId` is the id of
    /// the implementing contract and `SubId` is the given `sub_id` argument.
    ///
    /// # Arguments
    ///
    /// * `sub_id`: [SubId] - The sub-identifier of the token to burn.
    /// * `amount`: [u64] - The quantity of tokens to burn.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    ///
    /// fn foo(contract: ContractId, asset_id: AssetId) {
    ///     let contract_abi = abi(SR3, contract);
    ///     contract_abi {
    ///         gas: 10000,
    ///         coins: 100,
    ///         asset_id: AssetId,
    ///     }.burn(ZERO_B256, 100);
    /// }
    /// ```
    fn burn(sub_id: SubId, amount: u64);
}
