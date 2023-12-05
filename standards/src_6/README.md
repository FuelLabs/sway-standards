<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-6-logo-dark-theme.png">
        <img alt="SRC-6 logo" width="400px" src=".docs/src-6-logo-light-theme.png">
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

The following functions MUST be implemented to follow the SRC-6 standard. Any contract that implements the SRC-7 standard MUST implement the SRC-20 standard.

### `fn deposit(receiver: Identity, sub_id: SubId) -> u64`

Method that allows depositing of the underlying asset in exchange for shares of the vault.
This function takes the receiver's identity and the sub_id of the sub vault as an argument and returns the amount of shares minted to the receiver.

MUST revert if any unaccepted AssetId is forwarded.
MUST increase `managed_assets` by amount of deposited assets (through any means including `std::context::this_balance(ASSET_ID)` if applicable).
MUST mint a token representing the pro-rata share of the vault, with the AssetId of `sha256((asset, sub_id))`, a hash of the AssetId of the deposited asset, and the `sub_id` of the vault.
MUST increase `total_supply` of the share's AssetId by newly minted shares.
MUST increase `total_assets` by one if the the AssetId is minted for the first time.
MUST emit a `Deposit` log.
MUST return amount of minted shares.

### `fn withdraw(receiver: Identity, asset: AssetId, sub_id: SubId) -> u64`

Method that allows the redeeming of the vault shares in exchange for a pro-rata amount of the underlying asset
This function takes the asset's AssetId, the sub_id of the sub vault, and the receiver's identity as arguments and returns the amount of assets transferred to the receiver.
The AssetId of the asset, and the AssetId of the shares MUST be one-to-one, meaning every deposited AssetId shall have a unique corresponding shares AssetId.

MUST revert if any AssetId other than the AssetId representing the deposited asset's shares for the given sub vault at `sub_id` is forwarded.
MUST burn the received shares.
MUST reduce `total_supply` of the shares's AssetId by amount of burnt shares.
MUST emit a `Withdraw` log.
MUST return amount of assets transferred to the receiver.

### `fn managed_assets(asset: AssetId, sub_id: SubId) -> u64`

Method that returns the total assets under management by vault. Includes assets controlled by the vault but not directly possessed by vault.
This function takes the asset's AssetId and the sub_id of the sub vault as an argument and returns the total amount of assets of AssetId under management by vault.

MUST return total amount of assets of underlying AssetId under management by vault.
MUST return 0 if there are no assets of underlying AssetId under management by vault.
MUST NOT revert under any circumstances.

### `fn max_depositable(receiver: Identity, asset: AssetId, sub_id: SubId) -> Option<u64>`

Helper method for getting maximum depositable
This function takes the hypothetical receivers `Identity`, the asset's `AssetId`, and the `sub_id` of the sub vault as an argument and returns the maximum amount of assets that can be deposited into the contract, for the given asset.

MUST return the maximum amount of assets that can be deposited into the contract, for the given asset, if the given vault exists.
MUST return an `Option::Some(amount)` if the given vault exists.
MUST return an `Option::None` if the given vault does not exist.
MUST account for both global and user specific limits. For example: if deposits are disabled, even temporarily, MUST return 0.


### `fn max_withdrawable(receiver: Identity, asset: AssetId, sub_id: SubId) -> Option<u64>`

Helper method for getting maximum withdrawable
This function takes the hypothetical receive's `Identity`, the asset's `AssetId`, and the `sub_id`` of the sub vault as an argument and returns the maximum amount of assets that can be withdrawn from the contract, for the given asset.

MUST return the maximum amount of assets that can be withdrawn from the contract, for the given asset, if the given vault exists.
MUST return an `Option::Some(amount)` if the given vault exists.
MUST return an `Option::None` if the given vault does not exist.
MUST account for global limits. For example: if withdrawals are disabled, even temporarily, MUST return 0.

## Required logs

The following logs MUST be emitted at the specified occasions

```sway
/// Event logged when a deposit is made.
pub struct Deposit {
    /// The caller of the deposit function.
    caller: Identity,
    /// The receiver of the deposit.
    receiver: Identity,
    /// The asset being deposited.
    asset: AssetId,
    /// The SubId of the vault.
    sub_id: SubId,
    /// The amount of assets being deposited.
    assets: u64,
    /// The amount of shares being minted.
    shares: u64,
}
```
`caller` has called the `deposit` method sending `assets` assets of the `asset` AssetId to the subvault of `sub_id`, in exchange for `shares` shares sent to the receiver `receiver`

The `Deposit` struct MUST be logged whenever new shares are minted via the `deposit` method

```sway
/// Event logged when a withdrawal is made.
pub struct Withdraw {
    /// The caller of the withdrawal function.
    caller: Identity,
    /// The receiver of the withdrawal.
    receiver: Identity,
    /// The asset being withdrawn.
    asset: AssetId,
    /// The SubId of the vault.
    sub_id: SubId,
    /// The amount of assets being withdrawn.
    assets: u64,
    /// The amount of shares being burned.
    shares: u64,
}
```
`caller` has called the `withdraw` method sending `shares` shares in exchange for `assets` assets of the `asset` AssetId from the subvault of `sub_id` to the receiver `receiver`

The `Withdraw` struct MUST be logged whenever shares are redeemed for assets via the `withdraw` method

# Rationale

The ABI discussed and covers the known use cases of token vaults while allowing safe implementations

# Backwards Compatibility

This standard is fully compatible with the SRC-20 standard

# Security Considerations

Incorrect implementation of token vaults could allow attackers to steal underlying assets. It is recommended to properly audit any code using this standard to ensure exploits are not possible.

# Example ABI

```sway
abi SRC6 {
    #[storage(read, write)]
    fn deposit(receiver: Identity, sub_id: SubId) -> u64;

    #[storage(read, write)]
    fn withdraw(receiver: Identity, asset: AssetId, sub_id: SubId) -> u64;

    #[storage(read)]
    fn managed_assets(asset: AssetId, sub_id: SubId) -> u64;
    
    #[storage(read)]
    fn max_depositable(receiver: Identity, asset: AssetId, sub_id: SubId) -> Option<u64>;

    #[storage(read)]
    fn max_withdrawable(asset: AssetId, sub_id: SubId) -> Option<u64>;
}
```

# Example Implementation

## [Multi Token Vault](../../examples/src_6/multi_token_vault/)

A barebones implementation of the vault standard that supports any number of sub vaults being created for every AssetId.

## [Single Token Vault](../../examples/src_6/single_token_vault/)

A barebones implemenation of the vault standard demonstrating how to constrict deposits and withdrawals to a single AssetId.

## [Single Token Single Sub Vault](../../examples/src_6/single_token_single_sub_vault/)

A barebones implementation of the vault standard demonstrating how to constrict deposits and withdrawals to a single AssetId, and to a single Sub vault.