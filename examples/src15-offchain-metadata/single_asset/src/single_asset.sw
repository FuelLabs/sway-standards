contract;

use standards::{
    src15::{
        SRC15MetadataEvent,
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
        let sender = msg_sender().unwrap();
        let metadata_1 = Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X)));
        let metadata_2 = Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM)));
        let metadata_3 = Metadata::Int(ATTR_HEALTH);

        SRC15MetadataEvent::new(asset, metadata_1, sender).log();
        SRC15MetadataEvent::new(asset, metadata_2, sender).log();
        SRC15MetadataEvent::new(asset, metadata_3, sender).log();
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
