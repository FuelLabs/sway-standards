# SRC-7: Onchain Native Asset Metadata

The following standard attempts to define the retrieval of onchain arbitrary metadata for any [Native Asset](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). This standard should be used if a stateful approach is needed. Any contract that implements the SRC-7 standard MUST implement the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.

> **NOTE** If data is not needed onchain, it is recommended to use the [SRC-15; Offchain Asset Metadata Standard](https://docs.fuel.network/docs/sway-standards/src-15-offchain-asset-metadata/).

## Motivation

The SRC-7 standard seeks to enable stateful data-rich assets on the Fuel Network while maintaining compatibility between multiple assets minted by the same contract. The standard ensures type safety with the use of an `enum` and an `Option`. All metadata queries are done through a single function to facilitate cross-contract calls.

## Prior Art

The use of generic metadata was originally found in the Sway-Lib's [NFT Library](https://github.com/FuelLabs/sway-libs/tree/v0.12.0/libs/nft) which did not use Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). This library has since been deprecated.

A previous definition for a metadata standard was written in the original edit of the now defunct [SRC-721](https://github.com/FuelLabs/sway-standards/issues/2). This has since been replaced with the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard as `SubId` was introduced to enable multiple assets to be minted from a single contract.

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

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) and the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard. It also maintains compatibility with existing standards in other ecosystems.

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
contract;

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src7::{Metadata, SetMetadataEvent, SRC7};

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

impl SRC7 for Contract {
    /// Returns metadata for the corresponding `asset` and `key`.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the metadata.
    /// * `key`: [String] - The key to the specific metadata.
    ///
    /// # Returns
    ///
    /// * [Option<Metadata>] - `Some` metadata that corresponds to the `key` or `None`.
    ///
    /// # Reverts
    ///
    /// * When the AssetId provided does not match the default SubId.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src7::{SRC7, Metadata};
    /// use std::string::String;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC7, contract_id);
    ///     let key = String::from_ascii_str("social:x");
    ///     let data = contract_abi.metadata(asset, key);
    ///     assert(data.unwrap() == Metadata::String(String::from_ascii_str("fuel_network")));
    /// }
    /// ```
    #[storage(read)]
    fn metadata(asset: AssetId, key: String) -> Option<Metadata> {
        require(asset == AssetId::default(), "Invalid AssetId provided");

        if key == String::from_ascii_str("social:x") {
            Some(Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X))))
        } else if key == String::from_ascii_str("site:forum") {
            Some(Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM))))
        } else if key == String::from_ascii_str("attr:health") {
            Some(Metadata::Int(ATTR_HEALTH))
        } else {
            None
        }
    }
}

abi EmitSRC7Events {
    fn emit_src7_events();
}

impl EmitSRC7Events for Contract {
    fn emit_src7_events() {
        let asset = AssetId::default();
        let sender = msg_sender().unwrap();
        let metadata_1 = Some(Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X))));
        let metadata_2 = Some(Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM))));
        let metadata_3 = Some(Metadata::Int(ATTR_HEALTH));
        let key_1 = String::from_ascii_str("social:x");
        let key_2 = String::from_ascii_str("site:forum");
        let key_3 = String::from_ascii_str("attr:health");

        SetMetadataEvent::new(asset, metadata_1, key_1, sender)
            .log();
        SetMetadataEvent::new(asset, metadata_2, key_2, sender)
            .log();
        SetMetadataEvent::new(asset, metadata_3, key_3, sender)
            .log();
    }
}

// SRC7 extends SRC20, so this must be included
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
        // Metadata that is stored as a configurable should only be emitted once.
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

Example of the SRC-7 implementation where metadata exists for multiple assets with differing `SubId` values.

```sway
contract;

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src7::{Metadata, SetMetadataEvent, SRC7};

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
    /// The metadata for the "image:svg" key.
    svg_images: StorageMap<AssetId, StorageString> = StorageMap {},
    /// The metadata for the "attr:health" key.
    health_attributes: StorageMap<AssetId, u64> = StorageMap {},
}

impl SRC7 for Contract {
    /// Returns metadata for the corresponding `asset` and `key`.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the metadata.
    /// * `key`: [String] - The key to the specific metadata.
    ///
    /// # Returns
    ///
    /// * [Option<Metadata>] - `Some` metadata that corresponds to the `key` or `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src7::{SRC7, Metadata};
    /// use std::string::String;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC7, contract_id);
    ///     let key = String::from_ascii_str("social:x");
    ///     let data = contract_abi.metadata(asset, key);
    ///     assert(data.unwrap() == Metadata::String(String::from_ascii_str("fuel_network")));
    /// }
    /// ```
    #[storage(read)]
    fn metadata(asset: AssetId, key: String) -> Option<Metadata> {
        // If this asset does not exist, return None
        if storage.total_supply.get(asset).try_read().is_none() {
            return None
        }

        if key == String::from_ascii_str("social:x") {
            // The "social:x" for all assets minted by this contract are the same.
            Some(Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X))))
        } else if key == String::from_ascii_str("site:forum") {
            // The "site:forums" for all assets minted by this contract are the same.
            Some(Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM))))
        } else if key == String::from_ascii_str("image:svg") {
            // The SVG image is stored as a String in storage for each asset
            let svg_image = storage.svg_images.get(asset).read_slice();

            match svg_image {
                Some(svg) => Some(Metadata::String(svg)),
                None => None,
            }
        } else if key == String::from_ascii_str("attr:health") {
            // The health attribute is stored as a u64 in storage for each asset
            let health_attribute = storage.health_attributes.get(asset).try_read();

            match health_attribute {
                Some(health) => Some(Metadata::Int(health)),
                None => None,
            }
        } else {
            None
        }
    }
}

abi SetSRC7Events {
    #[storage(read, write)]
    fn set_src7_events(asset: AssetId, svg_image: String, health_attribute: u64);
}

impl SetSRC7Events for Contract {
    #[storage(read, write)]
    fn set_src7_events(asset: AssetId, svg_image: String, health_attribute: u64) {
        // NOTE: There are no checks for if the caller has permissions to update the metadata
        // If this asset does not exist, revert
        if storage.total_supply.get(asset).try_read().is_none() {
            revert(0);
        }

        storage.svg_images.try_insert(asset, StorageString {});
        storage.svg_images.get(asset).write_slice(svg_image);
        storage.health_attributes.insert(asset, health_attribute);

        let sender = msg_sender().unwrap();
        let metadata_1 = Some(Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X))));
        let metadata_2 = Some(Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM))));
        let metadata_3 = Some(Metadata::String(svg_image));
        let metadata_4 = Some(Metadata::Int(health_attribute));
        let key_1 = String::from_ascii_str("social:x");
        let key_2 = String::from_ascii_str("site:forum");
        let key_3 = String::from_ascii_str("image:svg");
        let key_4 = String::from_ascii_str("attr:health");

        SetMetadataEvent::new(asset, metadata_1, key_1, sender)
            .log();
        SetMetadataEvent::new(asset, metadata_2, key_2, sender)
            .log();
        SetMetadataEvent::new(asset, metadata_3, key_3, sender)
            .log();
        SetMetadataEvent::new(asset, metadata_4, key_4, sender)
            .log();
    }
}

// SRC7 extends SRC20, so this must be included
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

abi SetSRC20Data {
    fn set_src20_data(asset: AssetId, total_supply: u64);
}

impl SetSRC20Data for Contract {
    fn set_src20_data(asset: AssetId, supply: u64) {
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
