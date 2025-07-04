# SRC-15: Off-Chain Native Asset Metadata

The following standard attempts to define arbitrary offchain metadata for any [Native Asset](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) that is not required by other contracts onchain, in a stateless manner. Any contract that implements the SRC-15 standard MUST implement the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.

> **NOTE** If data is  needed onchain, use the [SRC-7; Onchain Asset Metadata Standard](https://docs.fuel.network/docs/sway-standards/src-7-asset-metadata/).

## Motivation

The SRC-15 standard seeks to enable data-rich assets on the Fuel Network while maintaining a stateless solution. All metadata queries are done off-chain using the indexer.

## Prior Art

The SRC-7 standard exists prior to the SRC-15 standard and is a stateful solution. The SRC-15 builds off the SRC-7 standard by using the `Metadata` enum however provides a stateless solution.

The use of generic metadata was originally found in the Sway-Lib's [NFT Library](https://github.com/FuelLabs/sway-libs/tree/v0.12.0/libs/nft) which did not use Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). This library has since been deprecated.

A previous definition for a metadata standard was written in the original edit of the now defunct [SRC-721](https://github.com/FuelLabs/sway-standards/issues/2). This has since been replaced with the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard as `SubId` was introduced to enable multiple assets to be minted from a single contract.

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

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) and the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard. This standard is also compatible with the SRC-7 standard which defines a stateful solution. It also maintains compatibility with existing standards in other ecosystems.

## Security Considerations

When indexing for SRC-15 metadata, developers should confirm that the contract that emitted the `SRC15MetadataEvent` is also the contract that minted the asset that the metadata associates with. Additionally, restrictions via access control on who may emit the Metadata should be considered.

## Example Implementation

### Single Native Asset

Example of the SRC-15 implementation where metadata exists for only a single asset with one `SubId`.

```sway
contract;

use src15::SRC15MetadataEvent;
use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src7::Metadata;
use std::string::String;
configurable {
    /// The total supply of coins for the asset minted by this contract.
    TOTAL_SUPPLY: u64 = 100_000_000,
    /// The decimals of the asset minted by this contract.
    DECIMALS: u8 = 9u8,
    /// The name of the asset minted by this contract.
    NAME: str[7] = __to_str_array("MyAsset"),
    /// The symbol of the asset minted by this contract.
    SYMBOL: str[5] = __to_str_array("MYTKN"),
    /// The metadata for the "social:x" key.
    SOCIAL_X: str[12] = __to_str_array("fuel_network"),
    /// The metadata for the "site:forum" key.
    SITE_FORUM: str[27] = __to_str_array("https://forum.fuel.network/"),
    /// The metadata for the "attr:health" key.
    ATTR_HEALTH: u64 = 100,
}
abi EmitSRC15Events {
    fn emit_src15_events();
}
impl EmitSRC15Events for Contract {
    fn emit_src15_events() {
        // NOTE: There are no checks for if the caller has permissions to emit the metadata.
        // NOTE: Nothing is stored in storage and there is no method to retrieve the configurables.
        let asset = AssetId::default();
        let metadata_1 = Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X)));
        let metadata_2 = Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM)));
        let metadata_3 = Metadata::Int(ATTR_HEALTH);
        SRC15MetadataEvent::new(asset, metadata_1).log();
        SRC15MetadataEvent::new(asset, metadata_2).log();
        SRC15MetadataEvent::new(asset, metadata_3).log();
    }
}
// SRC15 extends SRC20, so this must be included
impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        1
    }
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        if asset == AssetId::default() {
            Some(TOTAL_SUPPLY)
        } else {
            None
        }
    }
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        if asset == AssetId::default() {
            Some(String::from_ascii_str(from_str_array(NAME)))
        } else {
            None
        }
    }
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        if asset == AssetId::default() {
            Some(String::from_ascii_str(from_str_array(SYMBOL)))
        } else {
            None
        }
    }
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        if asset == AssetId::default() {
            Some(DECIMALS)
        } else {
            None
        }
    }
}
abi EmitSRC20Events {
    fn emit_src20_events();
}
impl EmitSRC20Events for Contract {
    fn emit_src20_events() {
        // Metadata that is stored as a configurable must be emitted once.
        let asset = AssetId::default();
        let sender = msg_sender().unwrap();
        let name = Some(String::from_ascii_str(from_str_array(NAME)));
        let symbol = Some(String::from_ascii_str(from_str_array(SYMBOL)));
        SetNameEvent::new(asset, name, sender).log();
        SetSymbolEvent::new(asset, symbol, sender).log();
        SetDecimalsEvent::new(asset, DECIMALS, sender).log();
        TotalSupplyEvent::new(asset, TOTAL_SUPPLY, sender).log();
    }
}
```

### Multi Native Asset

Example of the SRC-15 implementation where metadata exists for multiple assets with differing `SubId` values.

```sway
contract;

use src15::SRC15MetadataEvent;
use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src7::Metadata;
use std::{hash::Hash, storage::storage_string::*, string::String};
// In this example, all assets minted from this contract have the same decimals, name, and symbol
configurable {
    /// The decimals of every asset minted by this contract.
    DECIMALS: u8 = 0u8,
    /// The name of every asset minted by this contract.
    NAME: str[7] = __to_str_array("MyAsset"),
    /// The symbol of every asset minted by this contract.
    SYMBOL: str[5] = __to_str_array("MYAST"),
    /// The metadata for the "social:x" key.
    SOCIAL_X: str[12] = __to_str_array("fuel_network"),
    /// The metadata for the "site:forum" key.
    SITE_FORUM: str[27] = __to_str_array("https://forum.fuel.network/"),
}
storage {
    /// The total number of distinguishable assets this contract has minted.
    total_assets: u64 = 0,
    /// The total supply of a particular asset.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
}
abi EmitSRC15Events {
    #[storage(read)]
    fn emit_src15_events(asset: AssetId, svg_image: String, health_attribute: u64);
}
impl EmitSRC15Events for Contract {
    #[storage(read)]
    fn emit_src15_events(asset: AssetId, svg_image: String, health_attribute: u64) {
        // NOTE: There are no checks for if the caller has permissions to emit the metadata
        // NOTE: Nothing is stored in storage and there is no method to retrieve the configurables.

        // If this asset does not exist, revert
        if storage.total_supply.get(asset).try_read().is_none() {
            revert(0);
        }
        let metadata_1 = Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X)));
        let metadata_2 = Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM)));
        let metadata_3 = Metadata::String(svg_image);
        let metadata_4 = Metadata::Int(health_attribute);
        SRC15MetadataEvent::new(asset, metadata_1).log();
        SRC15MetadataEvent::new(asset, metadata_2).log();
        SRC15MetadataEvent::new(asset, metadata_3).log();
        SRC15MetadataEvent::new(asset, metadata_4).log();
    }
}
// SRC15 extends SRC20, so this must be included
impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        storage.total_assets.read()
    }
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        storage.total_supply.get(asset).try_read()
    }
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        match storage.total_supply.get(asset).try_read() {
            Some(_) => Some(String::from_ascii_str(from_str_array(NAME))),
            None => None,
        }
    }
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        match storage.total_supply.get(asset).try_read() {
            Some(_) => Some(String::from_ascii_str(from_str_array(SYMBOL))),
            None => None,
        }
    }
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        match storage.total_supply.get(asset).try_read() {
            Some(_) => Some(DECIMALS),
            None => None,
        }
    }
}
abi EmitSRC20Data {
    fn emit_src20_data(asset: AssetId, total_supply: u64);
}
impl EmitSRC20Data for Contract {
    fn emit_src20_data(asset: AssetId, supply: u64) {
        // NOTE: There are no checks for if the caller has permissions to update the metadata
        let sender = msg_sender().unwrap();
        let name = Some(String::from_ascii_str(from_str_array(NAME)));
        let symbol = Some(String::from_ascii_str(from_str_array(SYMBOL)));
        SetNameEvent::new(asset, name, sender).log();
        SetSymbolEvent::new(asset, symbol, sender).log();
        SetDecimalsEvent::new(asset, DECIMALS, sender).log();
        TotalSupplyEvent::new(asset, supply, sender).log();
    }
}
```

### Global

Example of the SRC-15 implementation where global metadata exists for all assets.

```sway
contract;

use src15::SRC15GlobalMetadataEvent;
use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src7::Metadata;
use std::{hash::Hash, storage::storage_string::*, string::String};
// In this example, all assets minted from this contract have the same decimals, name, and symbol
configurable {
    /// The decimals of every asset minted by this contract.
    DECIMALS: u8 = 0u8,
    /// The name of every asset minted by this contract.
    NAME: str[7] = __to_str_array("MyAsset"),
    /// The symbol of every asset minted by this contract.
    SYMBOL: str[5] = __to_str_array("MYAST"),
    /// The metadata for the "social:x" key.
    SOCIAL_X: str[12] = __to_str_array("fuel_network"),
    /// The metadata for the "site:forum" key.
    SITE_FORUM: str[27] = __to_str_array("https://forum.fuel.network/"),
}
storage {
    /// The total number of distinguishable assets this contract has minted.
    total_assets: u64 = 0,
    /// The total supply of a particular asset.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
}
abi EmitSRC15Events {
    #[storage(read)]
    fn emit_src15_events(svg_image: String, health_attribute: u64);
}
impl EmitSRC15Events for Contract {
    #[storage(read)]
    fn emit_src15_events(svg_image: String, health_attribute: u64) {
        // NOTE: There are no checks for if the caller has permissions to emit the metadata
        // NOTE: Nothing is stored in storage and there is no method to retrieve the configurables.
        let metadata_1 = Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X)));
        let metadata_2 = Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM)));
        let metadata_3 = Metadata::String(svg_image);
        let metadata_4 = Metadata::Int(health_attribute);
        SRC15GlobalMetadataEvent::new(metadata_1).log();
        SRC15GlobalMetadataEvent::new(metadata_2).log();
        SRC15GlobalMetadataEvent::new(metadata_3).log();
        SRC15GlobalMetadataEvent::new(metadata_4).log();
    }
}
// SRC15 extends SRC20, so this must be included
impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        storage.total_assets.read()
    }
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        storage.total_supply.get(asset).try_read()
    }
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        match storage.total_supply.get(asset).try_read() {
            Some(_) => Some(String::from_ascii_str(from_str_array(NAME))),
            None => None,
        }
    }
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        match storage.total_supply.get(asset).try_read() {
            Some(_) => Some(String::from_ascii_str(from_str_array(SYMBOL))),
            None => None,
        }
    }
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        match storage.total_supply.get(asset).try_read() {
            Some(_) => Some(DECIMALS),
            None => None,
        }
    }
}
abi EmitSRC20Data {
    fn emit_src20_data(asset: AssetId, total_supply: u64);
}
impl EmitSRC20Data for Contract {
    fn emit_src20_data(asset: AssetId, supply: u64) {
        // NOTE: There are no checks for if the caller has permissions to update the metadata
        let sender = msg_sender().unwrap();
        let name = Some(String::from_ascii_str(from_str_array(NAME)));
        let symbol = Some(String::from_ascii_str(from_str_array(SYMBOL)));
        SetNameEvent::new(asset, name, sender).log();
        SetSymbolEvent::new(asset, symbol, sender).log();
        SetDecimalsEvent::new(asset, DECIMALS, sender).log();
        TotalSupplyEvent::new(asset, supply, sender).log();
    }
}
```
