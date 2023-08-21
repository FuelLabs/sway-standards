library;

use std::string::String;

abi SRC20 {
    /// Returns the total number of individual assets for a contract.
    ///
    /// # Returns
    ///
    /// * [u64] - The number of assets that this contract has minted.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract: ContractId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let total_assets = contract_abi.total_assets();
    ///     assert(total_assets != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_assets() -> u64;

    /// Returns the total supply of tokens for an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the total supply.
    ///
    /// # Returns
    ///
    /// * [u64] - The total supply of tokens for `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let total_supply = contract_abi.total_supply(asset);
    ///     assert(total_supply != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_supply(asset: AssetId) -> u64;

    /// Returns the name of the asset, such as “Ether”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the name.
    ///
    /// # Returns
    ///
    /// * [String] - The name of `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let name = contract_abi.name(asset);
    ///     assert(name.len() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn name(asset: AssetId) -> String;
    /// Returns the symbol of the asset, such as “ETH”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the symbol.
    ///
    /// # Returns
    ///
    /// * [String] - The symbol of `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let symbol = contract_abi.symbol(asset);
    ///     assert(symbol.len() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn symbol(asset: AssetId) -> String;
    /// Returns the number of decimals the asset uses.
    ///
    /// # Additional Information
    ///
    /// e.g. 8, means to divide the token amount by 100000000 to get its user representation.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the decimals.
    ///
    /// # Returns
    ///
    /// * [u8] - The decimal precision used by `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract: ContractId, asset: AssedId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let decimals = contract_abi.decimals(asset);
    ///     assert(decimals == 8);
    /// }
    /// ```
    #[storage(read)]
    fn decimals(asset: AssetId) -> u8;
}
