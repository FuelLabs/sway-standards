<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-5-logo-dark-theme.png">
        <img alt="SRC-5 logo" width="400px" src=".docs/src-5-logo-light-theme.png">
    </picture>
</p>

# Abstract
The following standard allows for the implementation of a standard API for token vaults such as yield bearing token vaults. This standard is an optional add-on to the SRC-20 standard.

# Motivation
Token vaults allow users to own shares of variable amount of assets, such as lending protocols which may have growing assets due to profits from interest. This pattern is highly useful and would greatly benefit from standardisation

# Prior Art
Token vaults have been thoroughly explored on Ethereum and with [EIP 4626](https://eips.ethereum.org/EIPS/eip-4626) they have their own standard for it. However as Fuel's native assets are fundamentally different to Ethereum's ERC-20 tokens, the implementation will differ, but the interface may be used as reference.

# Specification
## Required public functions
The following functions MUST be implemented (on top of the SRC-20 functions) to follow the SRC-6 standard

### `fn deposit(receiver: Identity) -> u64`
Method that allows depositing of the underlying asset in exchange for shares of the vault.
This function takes the receiver's identity as an argument and returns the amount of shares minted to the receiver.

MUST revert if any AssetId other than the underlying is forwarded.
MUST mint `preview_deposit(deposited_assets)` amount of shares to `receiver`.
MUST increase `managed_assets` by `deposited_assets` (through any means including `std::context::this_balance(ASSET_ID)` if applicable).
MUST increase `total_supply` of the share's AssetId by newly minted shares.
MUST increase `total_assets` by one if the the AssetId is minted for the first time.
MUST emit a `Deposit` log.

### `fn withdraw(asset: AssetId, receiver: Identity) -> u64`
Method that allows the redeeming of the vault shares in exchange for a pro-rata amount of the underlying asset
This function takes the asset's AssetId and the receiver's identity as arguments and returns the amount of assets transferred to the receiver.
The AssetId of the asset, and the AssetId of the shares MUST be one-to-one, meaning every deposited AssetId shall have a unique corresponding shares AssetId.

MUST revert if any AssetId other than the AssetId corresponding to the deposited asset is forwarded.
MUST send `preview_withdraw(redeemed_shares)` amount of assets to `receiver`.
MUST burn the received shares.
MUST reduce `managed_assets` by `preview_withdraw(redeemed_shares)`.
MUST reduce `total_supply` of the shares's AssetId by amount of burnt shares.
MUST emit a `Withdraw` log.

### `fn managed_assets(asset: AssetId) -> u64`
Method that returns the total assets under management by vault. Includes assets controlled by the vault but not directly possessed by vault.
This function takes the asset's AssetId as an argument and returns the total amount of assets of AssetId under management by vault.

MUST return total amount of assets of underlying AssetId under management by vault.
MUST return 0 if there are no assets of underlying AssetId under management by vault.
MUST NOT revert under any circumstances.

### `fn convert_to_shares(asset: AssetId, assets: u64) -> Option<u64>`
Helper method for converting assets to shares.
This function takes the asset's AssetId and the amount of assets as arguments and returns the amount of shares that would be minted for the given amount of assets, in an ideal condition without slippage.

MUST return an Option::Some of the amount of shares that would be minted for the given amount of assets, without accounting for any slippage, if the given asset is supported.
MUST return an Option::None if the given asset is not supported.
MUST NOT revert under any circumstances.

### `fn convert_to_assets(asset: AssetId, shares: u64) -> Option<u64>`
Helper method for converting shares to assets.
This function takes the asset's AssetId and the amount of shares as arguments and returns the amount of assets that would be transferred for the given amount of shares, in an ideal condition without slippage.

MUST return an Option::Some of the amount of assets that would be transferred for the given amount of shares, if the given asset is supported.
MUST return an Option::None if the asset is not supported.
MUST NOT revert under any circumstances.

### `fn preview_deposit(asset: AssetId, assets: u64) -> u64`
Helper method for previewing deposit.
This function takes the asset's AssetId and the amount of assets as arguments and returns the amount of shares that would have been minted for the given amount of assets.

MUST return the amount of shares that would have been minted for the given amount of assets.
MUST revert for any reason the `deposit` function would revert given the same conditions.

### `fn preview_withdraw(asset: AssetId, shares: u64) -> u64`
Helper method for previewing withdraw
This function takes the asset's AssetId and the amount of shares as arguments and returns the amount of assets that would have been transferred for the given amount of shares.

MUST return the amount of assets that would have been transferred for the given amount of shares.
MUST revert for any reason the `withdraw` function would revert given the same conditions.

### `fn max_depositable(asset: AssetId) -> Option<u64>`
Helper method for getting maximum depositable
This function takes the asset's AssetId as an argument and returns the maximum amount of assets that can be deposited into the contract, for the given asset.

MUST return the maximum amount of assets that can be deposited into the contract, for the given asset.

### `fn max_withdrawable(asset: AssetId) -> Option<u64>`
Helper method for getting maximum withdrawable
This function takes the asset's AssetId as an argument and returns the maximum amount of assets that can be withdrawn from the contract, for the given asset.

MUST return the maximum amount of assets that can be withdrawn from the contract, for the given asset.

## Required logs
The following logs MUST be emitted at the specified occasions

```
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
```
`caller` has called the `deposit` method sending `assets` assets of the `asset` AssetId, in exchange for `shares` shares sent to the receiver `receiver`

The `Deposit` struct MUST be logged whenever new shares are minted via the `deposit` method

```
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
```
`caller` has called the `withdraw` method sending `shares` shares in exchange for `assets` assets of the `asset` AssetId to the receiver `receiver`

The `Withdraw` struct MUST be logged whenever shares are redeemed for assets via the `withdraw` method

# Rationale
The ABI discussed is simple and covers the known use cases of token vaults while allowing safe implementations

# Backwards compatibility
This standard is fully compatible with the SRC-20 standard

# Security Considerations
Incorrect implementation of token vaults could allow attackers to steal underlying assets. It is recommended to properly audit any code using this standard to ensure exploits are not possible.

# Reference implementation
Full reference implementation can be seen [here](https://github.com/SwayStar123/vault-standard-reference-implementation/blob/master/src/main.sw)

