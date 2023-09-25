library;

// Required logs:

/// Event logged when a deposit is made.
pub struct Deposit {
    /// The caller of the deposit function.
    caller: Identity,
    /// The receiver of the deposit.
    receiver: Identity,
    /// The asset being deposited.
    asset: AssetId,
    /// The amount of assets being deposited.
    assets: u64,
    /// The amount of shares being minted.
    shares: u64,
}

/// Event logged when a withdrawal is made.
pub struct Withdraw {
    /// The caller of the withdrawal function.
    caller: Identity,
    /// The receiver of the withdrawal.
    receiver: Identity,
    /// The asset being withdrawn.
    asset: AssetId,
    /// The amount of assets being withdrawn.
    assets: u64,
    /// The amount of shares being burned.
    shares: u64,
}

abi SRC6 {
    // SRC-6
    // Deposit/Withdrawal
    /// Deposits assets into the contract and mints shares to the receiver.
    ///
    /// # Additional Information
    ///
    /// * Assets must be forwarded to the contract in the contract call.
    ///
    /// # Arguments
    ///
    /// * `receiver`: [Identity] - The receiver of the shares.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of shares minted.
    ///
    /// # Reverts
    ///
    /// * If the asset is not supported by the contract.
    /// * If the amount of assets is zero.
    /// * The user crosses any global or user specific deposit limits.
    #[storage(read, write)]
    fn deposit(receiver: Identity) -> u64;
    /// Burns shares from the sender and transfers assets to the receiver.
    ///
    /// # Additional Information
    ///
    /// * Shares must be forwarded to the contract in the contract call.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the shares should be burned.
    /// * `receiver`: [Identity] - The receiver of the assets.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of assets transferred.
    ///
    /// # Reverts
    ///
    /// * If the asset is not supported by the contract.
    /// * If the amount of shares is zero.
    /// * If the transferred shares do not corresspond to the given asset.
    /// * The user crosses any global or user specific withdrawal limits.
    #[storage(read, write)]
    fn withdraw(asset: AssetId, receiver: Identity) -> u64;

    // Accounting
    /// Returns the amount of managed assets of the given asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the amount of managed assets should be returned.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of managed assets of the given asset.
    #[storage(read)]
    fn managed_assets(asset: AssetId) -> u64;
    /// Returns how many shares would be minted for the given amount of assets, in an ideal scenario (No accounting for slippage, or any limits).
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the amount of shares should be returned.
    /// * `assets`: [u64] - The amount of assets for which the amount of shares should be returned.
    ///
    /// # Returns
    ///
    /// * [Some(u64)] - The amount of shares that would be minted for the given amount of assets.
    /// * [None] - If the asset is not supported by the contract.
    #[storage(read)]
    fn convert_to_shares(asset: AssetId, assets: u64) -> Option<u64>;
    /// Returns how many assets would be transferred for the given amount of shares, in an ideal scenario (No accounting for slippage, or any limits).
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the amount of assets should be returned.
    /// * `shares`: [u64] - The amount of shares for which the amount of assets should be returned.
    ///
    /// # Returns
    ///
    /// * [Some(u64)] - The amount of assets that would be transferred for the given amount of shares.
    /// * [None] - If the asset is not supported by the contract.
    #[storage(read)]
    fn convert_to_assets(asset: AssetId, shares: u64) -> Option<u64>;
    /// Returns how many shares would have been minted for the given amount of assets, if this was a deposit call.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the amount of shares should be returned.
    /// * `assets`: [u64] - The amount of assets for which the amount of shares should be returned.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of shares that would have been minted for the given amount of assets.
    ///
    /// # Reverts
    ///
    /// * For any reason a deposit would revert.
    #[storage(read)]
    fn preview_deposit(asset: AssetId, assets: u64) -> u64;
    /// Returns how many assets would have been transferred for the given amount of shares, if this was a withdrawal call.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the amount of assets should be returned.
    /// * `shares`: [u64] - The amount of shares for which the amount of assets should be returned.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of assets that would have been transferred for the given amount of shares.
    ///
    /// # Reverts
    ///
    /// * For any reason a withdrawal would revert.
    #[storage(read)]
    fn preview_withdraw(asset: AssetId, shares: u64) -> u64;

    // Deposit/Withdrawal Limits
    /// Returns the maximum amount of assets that can be deposited into the contract, for the given asset.
    ///
    /// # Additional Information
    ///
    /// Does not account for any user or global limits.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the maximum amount of depositable assets should be returned.
    ///
    /// # Returns
    ///
    /// * [Some(u64)] - The maximum amount of assets that can be deposited into the contract, for the given asset.
    /// * [None] - If the asset is not supported by the contract.
    #[storage(read)]
    fn max_depositable(asset: AssetId) -> Option<u64>;
    /// Returns the maximum amount of assets that can be withdrawn from the contract, for the given asset.
    ///
    /// # Additional Information
    ///
    /// Does not account for any user or global limits.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which the maximum amount of withdrawable assets should be returned.
    ///
    /// # Returns
    ///
    /// * [Some(u64)] - The maximum amount of assets that can be withdrawn from the contract, for the given asset.
    /// * [None] - If the asset is not supported by the contract.
    #[storage(read)]
    fn max_withdrawable(asset: AssetId) -> Option<u64>;
}
