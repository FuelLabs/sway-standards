contract;

use standards::{
    src20::{
        SetDecimalsEvent,
        SetNameEvent,
        SetSymbolEvent,
        SRC20,
        UpdateTotalSupplyEvent,
    },
    src7::{
        Metadata,
        SetMetadataEvent,
        SRC7,
    },
};

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
        let sender = msg_sender().unwrap();

        log(SetMetadataEvent {
            asset,
            metadata: Some(Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X)))),
            key: String::from_ascii_str("social:x"),
            sender,
        });

        log(SetMetadataEvent {
            asset,
            metadata: Some(Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM)))),
            key: String::from_ascii_str("site:forum"),
            sender,
        });

        log(SetMetadataEvent {
            asset,
            metadata: Some(Metadata::String(svg_image)),
            key: String::from_ascii_str("image:svg"),
            sender,
        });

        log(SetMetadataEvent {
            asset,
            metadata: Some(Metadata::Int(health_attribute)),
            key: String::from_ascii_str("attr:health"),
            sender,
        });
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

        log(SetNameEvent {
            asset,
            name: Some(String::from_ascii_str(from_str_array(NAME))),
            sender,
        });

        log(SetSymbolEvent {
            asset,
            symbol: Some(String::from_ascii_str(from_str_array(SYMBOL))),
            sender,
        });

        log(SetDecimalsEvent {
            asset,
            decimals: DECIMALS,
            sender,
        });

        log(UpdateTotalSupplyEvent {
            asset,
            supply,
            sender,
        });
    }
}
