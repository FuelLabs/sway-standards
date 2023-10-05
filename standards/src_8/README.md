<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-8-logo-dark-theme.png">
        <img alt="SRC-8 logo" width="400px" src=".docs/src-8-logo-light-theme.png">
    </picture>
</p>


# Abstract

The following standard attempts to define the retrieval of relevant on-chain metadata for any bridged [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). Any contract that implements the SRC-8 standard MUST implement the [SRC-7](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_7) standard. 

# Motivation

The SRC-8 standard seeks to enable relevant data for bridged assets on the Fuel Network. This data includes the origin chain, address, ID, decimals, and any arbitrary data. All metadata queries are done through a single function to facilitate cross-contract calls.

# Prior Art

The use of generic metadata for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) is defined in the [SRC-7](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_7) standard. This standard integrates into the existing [SRC-7](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_7) standard.

# Specification

## Token Creation

The `SubId` of the token MUST be the digest of the `sha256(origin_chain_id, origin_asset_address, origin_asset_id)` hash where:

- `origin_chain_id` is a `u64` of the chain ID where the asset was originally minted.
- `origin_asset_address` is a `b256` of the asset's address on the chain where the asset was originally minted.
- `origin_asset_id` is a `b256` of the asset's ID such as an NFT's ID on the chain where the asset was originally minted. IF there is no ID, `ZERO_B256` SHALL be used.

## SRC-20 Metadata

Any bridged assets MUST use the name and symbol of the asset on the chain where the asset was originally minted. 

## SRC-7 Metadata

### - `bridged:chain`

The key `bridged:chain` SHALL return an `Int` variant the chain ID where the asset was originally minted.

### - `bridged:address`

The key `bridged:address` SHALL return a `B256` variant of the asset's address on the chain where the asset was originally minted.

### - `bridged:id`

The key `bridged:id` MAY return a `B256` variant of the asset's ID such as an NFT's ID on the chain where the asset was originally minted. IF there is no ID, `None` SHALL be returned.

### - `bridged:decimals`

The key `bridged:decimals` MAY return an `Int` variant of the asset's decimals on the chain where the asset was originally minted. IF there are no decimals, `None` SHALL be returned.

# Rationale

The SRC-8 standard should allow for data on any bridged assets on the Fuel Network. This standard builds off existing standards and should allow other contracts to query any relevant information on the bridged asset.

# Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets), the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard, and the [SRC-7](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_7) standard. 

The standard is also compatible with both tokens and NFTs native to other ecosystems by introducing a token ID element of the original chain.

# Security Considerations

This standard does not call external contracts, nor does it define any mutations of the contract state.

# Example

```rust
impl SRC7 for Contract {
    fn metadata(asset: AssetId, key: String) -> Option<Metadata> {
        if (asset != AssetId::from(ZERO_B256)) {
            return Option::None;
        }

        match key {
            String::from_ascii_str("bridged:chain") => {
                Option::Some(Metadata::Int(1))
            },
            String::from_ascii_str("bridged:address") => {
                let origin_asset_address = ZERO_B256;
                Option::Some(Metadata::B256(origin_asset_address))
            },
            String::from_ascii_str("bridged:id") => {
                let origin_asset_id = ZERO_B256;
                Option::Some(Metadata::B256(origin_asset_id))
            },
            String::from_ascii_str("bridged:decimals") => {
                Option::Some(Metadata::Int(1))
            },
            _ => Option::None,
        }
    }
}

impl SRC20 for Contract {
    fn total_assets() -> u64 {
        1
    }         

    fn total_supply(asset: AssetId) -> Option<u64> {
        match asset { 
            AssetId::from(ZERO_B256) => Option::Some(1),
            _ => Option::None,
        }
    }

    fn name(asset: AssetId) -> Option<String> {
        match asset { 
            AssetId::from(ZERO_B256) => Option::Some(String::from_ascii_str("Name")),
            _ => Option::None,
        }
    }

    fn symbol(asset: AssetId) -> Option<String> {
        match asset { 
            AssetId::from(ZERO_B256) => Option::Some(String::from_ascii_str("Symbol")),
            _ => Option::None,
        }
    }

    fn decimals(asset: AssetId) -> Option<u8> {
        match asset { 
            AssetId::from(ZERO_B256) => Option::Some(0u8),
            _ => Option::None,
        }
    }
}
```