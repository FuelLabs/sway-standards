# SRC-7: Onchain Native Asset Metadata

The following standard attempts to define the retrieval of on-chain arbitrary metadata for any [Native Asset](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). This standard should be used if a stateful approach is needed. Any contract that implements the SRC-7 standard MUST implement the [SRC-20](./src-20-native-asset.md) standard.

## Motivation

The SRC-7 standard seeks to enable stateful data-rich assets on the Fuel Network while maintaining compatibility between multiple assets minted by the same contract. The standard ensures type safety with the use of an `enum` and an `Option`. All metadata queries are done through a single function to facilitate cross-contract calls.

## Prior Art

The use of generic metadata was originally found in the Sway-Lib's [NFT Library](https://github.com/FuelLabs/sway-libs/tree/v0.12.0/libs/nft) which did not use Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). This library has since been deprecated.

A previous definition for a metadata standard was written in the original edit of the now defunct [SRC-721](https://github.com/FuelLabs/sway-standards/issues/2). This has since been replaced with the [SRC-20](./src-20-native-asset.md) standard as `SubId` was introduced to enable multiple assets to be minted from a single contract.

The standard takes inspiration from [ENS's public resolver](https://docs.ens.domains/contract-api-reference/publicresolver) with the use of a `String` as the key. This should enable human-readable keys to help minimize errors and enable the standardization of certain keys, such as "image" as opposed to an `enum` or `u64` representation of keys.

We also take a look at existing common metadata practices such as [OpenSea's Metadata Standards](https://docs.opensea.io/docs/metadata-standards) and seek to stay backwards compatible with them while enabling more functionality. Through the combination of `String` keys and various return types, both pre-defined URIs or specific attributes may be stored and retrieved with the SRC-7 standard.

## Specification

### Metadata Type

The following describes an enum that wraps various metadata types into a single return type. There SHALL be the following variants in the `Metadata` enum:

#### `B256`

The `B256` variant SHALL be used when the stored metadata for the corresponding `AssetId` and `Sting` key pair is of the `b256` type.

#### `Bytes`

The `Bytes` variant SHALL be used when the stored metadata for the corresponding `AssetId` and `String` key pair is of the `Bytes` type. The `Bytes` variant should be used when storing custom data such as but not limited to structs and enums.

#### `Int`

The `Int` variant SHALL be used when the stored metadata for the corresponding `AssetId` and `Sting` key pair is of the `u64` type.

#### `String`

The `String` variant SHALL be used when the stored metadata for the corresponding `AssetId` and `String` key pair is of the `String` type. The `String` variant MUST be used when a URI is required but MAY contain any arbitrary `String` data.

### Required Functions

#### `fn metadata(asset: AssetId, key: String) -> Option<Metadata>`

This function MUST return valid metadata for the corresponding `asset` and `key`, where the data is either a `B256`, `Bytes`, `Int`, or `String` variant. If the asset does not exist or no metadata exists, the function MUST return `None`.

### Logging

The following logs MUST be implemented and emitted to follow the SRC-7 standard.

* IF a value is updated via a function call, a log MUST be emitted.
* IF a value is embedded in a contract as a constant, configurable, or other manner, an event MUST be emitted at least once.

#### SetMetadataEvent

The `SetMetadataEvent` MUST be emitted when the metadata of an asset has updated.

There SHALL be the following fields in the `SetMetadataEvent` struct:

* `asset`: The `asset` field SHALL be used for the corresponding `AssetId` for the asset that has been updated.
* `metadata`: The `metadata` field SHALL be used for the corresponding `Option<Metadata>` which represents the metadata of the asset.
* `key`: The `key` field SHALL be used for the corresponding `String` which represents the key used for storing the metadata.
* `sender`: The `sender` field SHALL be used for the corresponding `Identity` which made the function call that has updated the metadata of the asset.

Example:

```sway
pub struct SetMetadataEvent {
    pub asset: AssetId,
    pub metadata: Option<Metadata>,
    pub key: String,
    pub sender: Identity,
}
```

## Rationale

The SRC-7 standard should allow for stateful data-rich assets to interact with one another in a safe manner.

## Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) and the [SRC-20](./src-20-native-asset.md) standard. It also maintains compatibility with existing standards in other ecosystems.

## Security Considerations

This standard does not introduce any security concerns, as it does not call external contracts, nor does it define any mutations of the contract state.

## Example ABI

```sway
abi SRC7 {
     #[storage(read)]
     fn metadata(asset: AssetId, key: String) -> Option<Metadata>;
}
```

## Example Implementation

### Single Native Asset

Example of the SRC-7 implementation where metadata exists for only a single asset with one `SubId`.

```sway
{{#include ../examples/src7-metadata/single_asset/src/single_asset.sw}}
```

### Multi Native Asset

Example of the SRC-7 implementation where metadata exists for multiple assets with differing `SubId` values.

```sway
{{#include ../examples/src7-metadata/multi_asset/src/multi_asset.sw}}
```
