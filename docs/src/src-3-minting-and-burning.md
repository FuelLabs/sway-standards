# SRC-3: Minting and Burning Native Assets

The following standard enables the minting and burning of native assets for any fungible assets within the Sway Language. It seeks to define mint and burn functions defined separately from the [SRC-20](./src-20-native-asset.md) standard.

## Motivation

The intent of this standard is to separate the extensions of minting and burning from the [SRC-20](./src-20-native-asset.md) standard.

## Prior Art

Minting and burning were initially added to the [SRC-20](./src-20-native-asset.md) standard.

## Specification

### Required Public Functions

The following functions MUST be implemented to follow the SRC-3 standard:

#### `fn mint(recipient: Identity, sub_id: Option<SubId>, amount: u64)`

This function MUST mint `amount` coins with a sub-identifier and transfer them to the `recipient`.
This function MUST use the `sub_id` as the sub-identifier IF `sub_id` is `Some`, otherwise this function MUST assign a `SubId` if the `sub_id` argument is `None`.
This function MAY contain arbitrary conditions for minting, and revert if those conditions are not met.

##### Mint Arguments

* `recipient` - The `Identity` to which the newly minted asset is transferred to.
* `sub_id` - The sub-identifier of the asset to mint. If this is `None`, a `SubId` MUST be assigned.
* `amount` - The quantity of coins to mint.

#### `fn burn(sub_id: SubId, amount: u64)`

This function MUST burn `amount` coins with the sub-identifier `sub_id` and MUST ensure the `AssetId` of the asset is the sha-256 hash of `(ContractId, SubId)` for the implementing contract.
This function MUST ensure at least `amount` coins have been transferred to the implementing contract.
This function MUST update the total supply defined in the [SRC-20](./src-20-native-asset.md) standard.
This function MAY contain arbitrary conditions for burning, and revert if those conditions are not met.

##### Burn Arguments

* `sub_id` - The sub-identifier of the asset to burn.
* `amount` - The quantity of coins to burn.

## Rationale

This standard has been added to enable compatibility between applications and allow minting and burning native assets per use case. This standard has been separated from the [SRC-20](./src-20-native-asset.md) standard to allow for the minting and burning for all fungible assets, irrelevant of whether they are [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) or not.

## Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) ensuring its compatibility with the [SRC-20](./src-20-native-asset.md) standard.

## Security Considerations

This standard may introduce security considerations if no checks are implemented to ensure the calling of the `mint()` function is deemed valid or permitted. Checks are highly encouraged.
The burn function may also introduce a security consideration if the total supply within the [SRC-20](./src-20-native-asset.md) standard is not modified.

## Example ABI

```sway
abi SRC3 {
    #[storage(read, write)]
    fn mint(recipient: Identity, sub_id: Option<SubId>, amount: u64);
    #[payable]
    #[storage(read, write)]
    fn burn(sub_id: SubId, amount: u64);
}
```

## Example Implementation

### Single Native Asset

Example of the SRC-3 implementation where a contract only mints a single asset with one `SubId`.

```sway
{{#include ../examples/src3-mint-burn/single_asset/src/single_asset.sw}}
```

### Multi Native Asset

Example of the SRC-3 implementation where a contract mints multiple assets with differing `SubId` values.

```sway
{{#include ../examples/src3-mint-burn/multi_asset/src/multi_asset.sw}}
```
