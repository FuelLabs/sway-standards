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
    fn emitSRC7Events();
}

impl EmitSRC7Events for Contract {
    fn emitSRC7Events() {
        let asset = AssetId::default();
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
            metadata: Some(Metadata::Int(ATTR_HEALTH)),
            key: String::from_ascii_str("attr:health"),
            sender,
        });
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
    fn emitSRC20Events();
}

impl EmitSRC20Events for Contract {
    fn emitSRC20Events() {
        // Metadata that is stored as a configurable should only be emitted once.
        let asset = AssetId::default();
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
            supply: TOTAL_SUPPLY,
            sender,
        });
    }
}
