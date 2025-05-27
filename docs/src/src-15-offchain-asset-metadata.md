# SRC-15: Off-Chain Native Asset Metadata

The following standard attempts to define arbitrary offchain metadata for any [Native Asset](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) that is not required by other contracts onchain, in a stateless manner. Any contract that implements the SRC-15 standard MUST implement the [SRC-20](./src-20-native-asset.md) standard.

> **NOTE** If data is  needed onchain, use the [SRC-7; Onchain Asset Metadata Standard](./src-7-asset-metadata.md).

## Motivation

The SRC-15 standard seeks to enable data-rich assets on the Fuel Network while maintaining a stateless solution. All metadata queries are done off-chain using the indexer.

## Prior Art

The SRC-7 standard exists prior to the SRC-15 standard and is a stateful solution. The SRC-15 builds off the SRC-7 standard by using the `Metadata` enum however provides a stateless solution.

The use of generic metadata was originally found in the Sway-Lib's [NFT Library](https://github.com/FuelLabs/sway-libs/tree/v0.12.0/libs/nft) which did not use Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). This library has since been deprecated.

A previous definition for a metadata standard was written in the original edit of the now defunct [SRC-721](https://github.com/FuelLabs/sway-standards/issues/2). This has since been replaced with the [SRC-20](./src-20-native-asset.md) standard as `SubId` was introduced to enable multiple assets to be minted from a single contract.

## Specification

### Metadata Type

The `Metadata` enum from the SRC-7 standard is also used to represent the metadata in the SRC-15 standard.

### Logging

The following logs MUST be implemented and emitted to follow the SRC-15 standard. Logging MUST be emitted from the contract which minted the asset.

#### SRC15MetadataEvent

The `SRC15MetadataEvent` MUST be emitted at least once for each distinct piece of metadata and each distinct asset. The latest emitted `SRC15MetadataEvent` is determined to be the current metadata.

There SHALL be the following fields in the `SRC15MetadataEvent` struct:

* `asset`: The `asset` field SHALL be used for the corresponding `AssetId` for the metadata.
* `metadata`: The `metadata` field SHALL be used for the corresponding `Metadata` which represents the metadata of the asset.

Example:

```sway
pub struct SRC15MetadataEvent {
    pub asset: AssetId,
    pub metadata: Metadata,
}
```

#### SRC15GlobalMetadataEvent

The `SRC15GlobalMetadataEvent` MUST be emitted at least once for each distinct piece of metadata for *all* assets minted by a contract. The latest emitted `SRC15GlobalMetadataEvent` is determined to be the current metadata.

There SHALL be the following fields in the `SRC15GlobalMetadataEvent` struct:

* `metadata`: The `metadata` field SHALL be used for the corresponding `Metadata` which represents the metadata associated with all assets minted by the contract.

Example:

```sway
pub struct SRC15GlobalMetadataEvent {
    pub metadata: Metadata,
}
```

## Rationale

The SRC-15 standard allows for data-rich assets in a stateless manner by associating an asset with some metadata that may later be fetched by the indexer.

## Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) and the [SRC-20](./src-20-native-asset.md) standard. This standard is also compatible with the SRC-7 standard which defines a stateful solution. It also maintains compatibility with existing standards in other ecosystems.

## Security Considerations

When indexing for SRC-15 metadata, developers should confirm that the contract that emitted the `SRC15MetadataEvent` is also the contract that minted the asset that the metadata associates with. Additionally, restrictions via access control on who may emit the Metadata should be considered.

## Example Implementation

### Single Native Asset

Example of the SRC-15 implementation where metadata exists for only a single asset with one `SubId`.

```sway
{{#include ../examples/src15-offchain-metadata/single_asset/src/single_asset.sw}}
```

### Multi Native Asset

Example of the SRC-15 implementation where metadata exists for multiple assets with differing `SubId` values.

```sway
{{#include ../examples/src15-offchain-metadata/multi_asset/src/multi_asset.sw}}
```

### Global

Example of the SRC-15 implementation where global metadata exists for all assets.

```sway
{{#include ../examples/src15-offchain-metadata/global/src/global.sw}}
```
