<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-6-logo-dark-theme.png">
        <img alt="SRC-6 logo" width="400px" src=".docs/src-6-logo-light-theme.png">
    </picture>
</p>

# Abstract

The following standard allows for the implementation of a standard API for token vaults such as yield-bearing token vaults or asset wrappers. This standard is an optional add-on to the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard.

# Motivation

Token vaults allow users to own shares of variable amounts of assets, such as lending protocols which may have growing assets due to profits from interest. This pattern is highly useful and would greatly benefit from standardization.

# Prior Art

Token vaults have been thoroughly explored on Ethereum and with [EIP 4626](https://eips.ethereum.org/EIPS/eip-4626) they have their own standard for it. However as Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) are fundamentally different from Ethereum's ERC-20 tokens, the implementation will differ, but the interface may be used as a reference.

# Specification

## Required public functions

The following functions MUST be implemented to follow the SRC-6 standard. Any contract that implements the SRC-6 standard MUST implement the SRC-20 standard.

### `fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64`

This function MUST allow for depositing of the underlying asset in exchange for pro-rata shares of the vault.
This function takes the `receiver` Identity and the SubId `vault_sub_id` of the sub-vault as an argument and returns the amount of shares minted to the `receiver`.

This function MAY reject arbitrary assets based on implementation and MUST revert if unaccepted assets are forwarded.
This function MUST mint an asset representing the pro-rata share of the vault, with the SubId of the `sha256((underlying_asset, vault_sub_id))` digest, where `underlying_asset` is the AssetId of the deposited asset and the `vault_sub_id` is the id of the vault.
This function MUST emit a `Deposit` log.
This function MUST return the amount of minted shares.

### `fn withdraw(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> u64`

This function MUST allow for redeeming of the vault shares in exchange for a pro-rata amount of the underlying assets.
This function takes the `receiver` Identity, the `underlying_asset` AssetId, and the `vault_sub_id` of the sub vault, as arguments and returns the amount of assets transferred to the `receiver`.

This function MUST revert if any AssetId other than the AssetId representing the deposited asset's shares for the given sub vault at `vault_sub_id` is forwarded. (i.e. transferred share's AssetId must be equal to `AssetId::new(ContractId::this(), sha256((underlying_asset, vault_sub_id))`)
This function MUST burn the received shares.
This function MUST emit a `Withdraw` log.
This function MUST return amount of assets transferred to the receiver.

### `fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64`

Method that returns the total assets under management by vault. Includes assets controlled by the vault but not directly possessed by vault.
This function takes the `underlying_asset` AssetId and the `vault_sub_id` of the sub vault as an argument and returns the total amount of assets of AssetId under management by vault.

This function MUST return total amount of assets of `underlying_asset` AssetId under management by vault.
This function MUST return 0 if there are no assets of `underlying_asset` AssetId under management by vault.
This function MUST NOT revert under any circumstances.

### `fn max_depositable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>`

Helper method for getting maximum depositable
This function takes the hypothetical `receiver` `Identity`, the `underlying_asset` `AssetId`, and the `vault_sub_id` of the sub vault as an argument and returns the maximum amount of assets that can be deposited into the contract, for the given asset.

This function MUST return the maximum amount of assets that can be deposited into the contract, for the given asset, if the given vault exists.
This function MUST return an `Option::Some(amount)` if the given vault exists.
This function MUST return an `Option::None` if the given vault does not exist.
This function MUST account for both global and user specific limits. For example: if deposits are disabled, even temporarily, MUST return 0.


### `fn max_withdrawable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>`

Helper method for getting maximum withdrawable
This function takes the hypothetical `receiver` `Identity`, the `underlying_asset` `AssetId`, and the `vault_sub_id` of the sub vault as an argument and returns the maximum amount of assets that can be withdrawn from the contract, for the given asset.

This function MUST return the maximum amount of assets that can be withdrawn from the contract, for the given asset, if the given vault exists.
This function MUST return an `Option::Some(amount)` if the given vault exists.
This function MUST return an `Option::None` if the given vault does not exist.
This function MUST account for global limits. For example: if withdrawals are disabled, even temporarily, MUST return 0.

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
    underlying_asset: AssetId,
    /// The SubId of the vault.
    vault_sub_id: SubId,
    /// The amount of assets being deposited.
    assets: u64,
    /// The amount of shares being minted.
    shares: u64,
}
```
`caller` has called the `deposit` method sending `assets` assets of the `underlying_asset` AssetId to the subvault of `vault_sub_id`, in exchange for `shares` shares sent to the receiver `receiver`

The `Deposit` struct MUST be logged whenever new shares are minted via the `deposit` method

```sway
/// Event logged when a withdrawal is made.
pub struct Withdraw {
    /// The caller of the withdrawal function.
    caller: Identity,
    /// The receiver of the withdrawal.
    receiver: Identity,
    /// The asset being withdrawn.
    underlying_asset: AssetId,
    /// The SubId of the vault.
    vault_sub_id: SubId,
    /// The amount of assets being withdrawn.
    assets: u64,
    /// The amount of shares being burned.
    shares: u64,
}
```

`caller` has called the `withdraw` method sending `shares` shares in exchange for `assets` assets of the `underlying_asset` AssetId from the subvault of `vault_sub_id` to the receiver `receiver`

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
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64;

    #[storage(read, write)]
    fn withdraw(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> u64;

    #[storage(read)]
    fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64;
    
    #[storage(read)]
    fn max_depositable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>;

    #[storage(read)]
    fn max_withdrawable(underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>;
}
```

# Example Implementation

## [Multi Token Vault](../../examples/src_6/multi_token_vault/)

A barebones implementation of the vault standard that supports any number of sub vaults being created for every AssetId.

## [Single Token Vault](../../examples/src_6/single_token_vault/)

A barebones implemenation of the vault standard demonstrating how to constrict deposits and withdrawals to a single AssetId.

## [Single Token Single Sub Vault](../../examples/src_6/single_token_single_sub_vault/)

A barebones implementation of the vault standard demonstrating how to constrict deposits and withdrawals to a single AssetId, and to a single Sub vault.