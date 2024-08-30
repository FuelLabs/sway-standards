# SRC-6: Vault

The following standard allows for the implementation of a standard API for asset vaults such as yield-bearing asset vaults or asset wrappers. This standard is an optional add-on to the [SRC-20](./src-20-native-asset.md) standard.

## Motivation

Asset vaults allow users to own shares of variable amounts of assets, such as lending protocols which may have growing assets due to profits from interest. This pattern is highly useful and would greatly benefit from standardization.

## Prior Art

Asset vaults have been thoroughly explored on Ethereum and with [EIP 4626](https://eips.ethereum.org/EIPS/eip-4626) they have their own standard for it. However as Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) are fundamentally different from Ethereum's ERC-20 tokens, the implementation will differ, but the interface may be used as a reference.

## Specification

### Required public functions

The following functions MUST be implemented to follow the SRC-6 standard. Any contract that implements the SRC-6 standard MUST implement the SRC-20 standard.

#### `fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64`

This function takes the `receiver` Identity and the SubId `vault_sub_id` of the sub-vault as an argument and returns the amount of shares minted to the `receiver`.

- This function MUST allow for depositing of the underlying asset in exchange for pro-rata shares of the vault.
- This function MAY reject arbitrary assets based on implementation and MUST revert if unaccepted assets are forwarded.
- This function MAY reject any arbitrary `receiver` based on implementation and MUST revert in the case of a blacklisted or non-whitelisted `receiver`.
- This function MUST mint an asset representing the pro-rata share of the vault, with the SubId of the `sha256((underlying_asset, vault_sub_id))` digest, where `underlying_asset` is the `AssetId` of the deposited asset and the `vault_sub_id` is the id of the vault.
- This function MUST emit a `Deposit` log.
- This function MUST return the amount of minted shares.

#### `fn withdraw(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> u64`

This function takes the `receiver` Identity, the `underlying_asset` `AssetId`, and the `vault_sub_id` of the sub vault, as arguments and returns the amount of assets transferred to the `receiver`.

- This function MUST allow for redeeming of the vault shares in exchange for a pro-rata amount of the underlying assets.
- This function MUST revert if any `AssetId` other than the `AssetId` representing the underlying asset's shares for the given sub vault at `vault_sub_id` is forwarded. (i.e. transferred share's `AssetId` must be equal to `AssetId::new(ContractId::this(), sha256((underlying_asset, vault_sub_id))`)
- This function MUST burn the received shares.
- This function MUST emit a `Withdraw` log.
- This function MUST return amount of assets transferred to the receiver.

#### `fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64`

This function returns the total assets under management by vault. Includes assets controlled by the vault but not directly possessed by vault. It takes the `underlying_asset` `AssetId` and the `vault_sub_id` of the sub vault as arguments and returns the total amount of assets of `AssetId` under management by vault.

- This function MUST return total amount of assets of `underlying_asset` `AssetId` under management by vault.
- This function MUST return 0 if there are no assets of `underlying_asset` `AssetId` under management by vault.
- This function MUST NOT revert under any circumstances.

#### `fn max_depositable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>`

This is a helper function for getting the maximum amount of assets that can be deposited. It takes the hypothetical `receiver` `Identity`, the `underlying_asset` `AssetId`, and the `vault_sub_id` `SubId` of the sub vault as an arguments and returns the maximum amount of assets that can be deposited into the contract, for the given asset.

- This function MUST return the maximum amount of assets that can be deposited into the contract, for the given `underlying_asset`, if the given `vault_sub_id` vault exists.
- This function MUST return an `Some(amount)` if the given `vault_sub_id` vault exists.
- This function MUST return an `None` if the given `vault_sub_id` vault does not exist.
- This function MUST account for both global and user specific limits. For example: if deposits are disabled, even temporarily, MUST return 0.

#### `fn max_withdrawable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>`

This is a helper function for getting maximum withdrawable. It takes the hypothetical `receiver` `Identity`, the `underlying_asset` `AssetId`, and the `vault_sub_id` SubId of the sub vault as an argument and returns the maximum amount of assets that can be withdrawn from the contract, for the given asset.

- This function MUST return the maximum amount of assets that can be withdrawn from the contract, for the given `underlying_asset`, if the given `vault_sub_id` vault exists.
- This function MUST return an `Some(amount)` if the given `vault_sub_id` vault exists.
- This function MUST return an `None` if the given `vault_sub_id` vault does not exist.
- This function MUST account for global limits. For example: if withdrawals are disabled, even temporarily, MUST return 0.

### Required logs

The following logs MUST be emitted at the specified occasions.

#### `Deposit`

`caller` has called the `deposit()` method sending `deposited_amount` assets of the `underlying_asset` Asset to the subvault of `vault_sub_id`, in exchange for `minted_shares` shares sent to the receiver `receiver`.

The `Deposit` struct MUST be logged whenever new shares are minted via the `deposit()` method.

The `Deposit` log SHALL have the following fields.

**`caller`: `Identity`**

The `caller` field MUST represent the `Identity` which called the deposit function.

**`receiver`: `Identity`**

The `receiver` field MUST represent the `Identity` which received the vault shares.

**`underlying_asset`: `AssetId`**

The `underlying_asset` field MUST represent the `AssetId` of the asset which was deposited into the vault.

**`vault_sub_id`: `SubId`**

The `vault_sub_id` field MUST represent the `SubId` of the vault which was deposited into.

**`deposited_amount`: `u64`**

The `deposited_amount` field MUST represent the `u64` amount of assets deposited into the vault.

**`minted_shares`: `u64`**

The `minted_shares` field MUST represent the `u64` amount of shares minted.

#### `Withdraw`

`caller` has called the `withdraw()` method sending `burned_shares` shares in exchange for `withdrawn_amount` assets of the `underlying_asset` Asset from the subvault of `vault_sub_id` to the receiver `receiver`.

The `Withdraw` struct MUST be logged whenever shares are redeemed for assets via the `withdraw()` method.

The `Withdraw` log SHALL have the following fields.

**`caller`: `Identity`**

The `caller` field MUST represent the Identity which called the withdraw function.

**`receiver`: `Identity`**

The `receiver` field MUST represent the Identity which received the withdrawn assets.

**`underlying_asset`: `AssetId`**

The `underlying_asset` field MUST represent the `AssetId` of the asset that was withdrawn.

**`vault_sub_id`: `SubId`**

The `vault_sub_id` field MUST represent the SubId of the vault from which was withdrawn.

**`withdrawn_amount`: `u64`**

The `withdrawn_amount` field MUST represent the `u64` amount of coins withdrawn.

**`burned_shares`: `u64`**

The `burned_shares` field MUST represent the `u64` amount of shares burned.

## Rationale

The ABI discussed covers the known use cases of asset vaults while allowing safe implementations.

## Backwards Compatibility

This standard is fully compatible with the [SRC-20 standard](./src-20-native-asset.md).

## Security Considerations

Incorrect implementation of asset vaults could allow attackers to steal underlying assets. It is recommended to properly audit any code using this standard to ensure exploits are not possible.

## Example ABI

```sway
abi SRC6 {
    #[payable]
    #[storage(read, write)]
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64;

    #[payable]
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

## Example Implementation

### Multi Asset Vault

A basic implementation of the vault standard that supports any number of sub vaults being created for every `AssetId`.

```sway
{{#include ../examples/src6-vault/multi_asset_vault/src/main.sw}}
```

### Single Asset Vault

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single `AssetId`.

```sway
{{#include ../examples/src6-vault/single_asset_vault/src/main.sw}}
```

## Single Asset Single Sub Vault

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single `AssetId`, and to a single Sub vault.

```sway
{{#include ../examples/src6-vault/single_asset_single_sub_vault/src/main.sw}}
```
