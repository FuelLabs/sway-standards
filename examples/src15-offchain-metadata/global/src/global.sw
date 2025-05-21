contract;

use standards::{
    src15::{
        SRC15GlobalMetadataEvent,
    },
    src20::{
        SetDecimalsEvent,
        SetNameEvent,
        SetSymbolEvent,
        SRC20,
        TotalSupplyEvent,
    },
    src7::{
        Metadata,
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
