<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-7-logo-dark-theme.png">
        <img alt="SRC-7 logo" width="400px" src=".docs/src-7-logo-light-theme.png">
    </picture>
</p>

# Abstract

The following standard attempts to define the retrieval of on-chain arbitrary metadata for any [Native Asset](https://fuellabs.github.io/sway/v0.45.0/book/blockchain-development/native_assets.html). Any contract that implements the SRC-7 standard MUST implement the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard. 

# Motivation

The SRC-7 standard seeks to enable data-rich assets on the Fuel Network while maintaining compatibility between multiple assets minted by the same contract. The standard ensures type safety with the use of an `enum` and an `Option`. All metadata queries are done through a single function to facilitate cross-contract calls.

# Prior Art

The use of generic metadata was originally found in the Sway-Lib's [NFT Library](https://github.com/FuelLabs/sway-libs/tree/v0.12.0/libs/nft) which did not use Fuel's [Native Assets](https://fuellabs.github.io/sway/v0.45.0/book/blockchain-development/native_assets.html). This library has since been deprecated. 

A previous definition for a metadata standard was written in the original edit of the now defunct [SRC-721](https://github.com/FuelLabs/sway-standards/issues/2). This has since been replaced with the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard as `SubId` was introduced to enable multiple assets to be minted from a single contract. 

The standard takes inspiration from [ENS's public resolver](https://docs.ens.domains/contract-api-reference/publicresolver) with the use of a `String` as the key. This should enable human-readable keys to help minimize errors and enable the standardization of certain keys, such as "image" as opposed to an `enum` or `u64` representation of keys.

We also take a look at existing common metadata practices such as [OpenSea's Metadata Standards](https://docs.opensea.io/docs/metadata-standards) and seek to stay backwards compatible with them while enabling more functionality. Through the combination of `String` keys and various return types, both pre-defined URIs or specific attributes may be stored and retrieved with the SRC-7 standard. 

# Specification

## Metadata Type

The following describes an enum that wraps various metadata types into a single return type. There SHALL be the following variants in the `Metadata` enum:

### - `StringData: String`

The `StringData` variant SHALL be used when the stored metadata for the corresponding asset and `String` key pair is of the `String` type. The `StringData` variant MUST be used when a URI is required but MAY contain any arbitrary `String`. 

### - `IntData: u64`

The `IntData` variant SHALL be used when the stored metadata for the corresponding asset and `Sting` key pair is of the `u64` type.

### - `BytesData: Bytes`

The `BytesData` variant SHALL be used when the stored metadata for the corresponding asset and `String` key pair is of the `Bytes` type. The `BytesData` variant should be used when storing custom data such as but not limited to structs and enums.

## Require Functions

### `fn metadata(asset: AssetId, key: String) -> Option<Metadata>`

This function MUST return valid metadata for the corresponding `asset` and `key`, where the data is either a `StringData`, `IntData`, or `BytesData` variant. If the asset does not exist or no metadata exists, the function MUST return `None`.

# Rationale

The SRC-7 standard should allow for data-rich assets to interact with one another in a safe manner. 

# Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://fuellabs.github.io/sway/v0.45.0/book/blockchain-development/native_assets.html) and the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard. It also maintains compatibility with existing standards in other ecosystems.

# Security Considerations

This standard does not introduce any security concerns, as it does not call external contracts, nor does it define any mutations of the contract state.

# Example ABI

```rust
abi SRC7Metadata {
     #[storage(read)]
     fn metadata(asset: AssetId, key: String) -> Option<Metadata>;
}
```