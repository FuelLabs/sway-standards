contract;

use src_7::{Metadata, SRC7};
use src_20::SRC20;

use std::{
    call_frames::contract_id, 
    hash::Hash,
    string::String,
    storage::storage_string::*,
};

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
    /// use src_7::{SRC7, Metadata};
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
        if key == String::from_ascii_str("social:x") {
            Some(Metadata::String(String::from_ascii_str(from_str_array(SOCIAL_X))))
        } else if key == String::from_ascii_str("site:forum") {
            Some(Metadata::String(String::from_ascii_str(from_str_array(SITE_FORUM))))
        } else if key == String::from_ascii_str("image:svg") {
            let svg_image = storage.svg_images.get(asset).read_slice();

            match svg_image {
                Some(svg) => Some(Metadata::String(svg)),
                None => None,
            }
        } else if key == String::from_ascii_str("attr:health") {
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
        if asset == AssetId::default(contract_id()) {
            Some(String::from_ascii_str(from_str_array(NAME)))
        } else {
            None
        }
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        if asset == AssetId::default(contract_id()) {
            Some(String::from_ascii_str(from_str_array(SYMBOL)))
        } else {
            None
        }
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        if asset == AssetId::default(contract_id()) {
            Some(DECIMALS)
        } else {
            None
        }
    }
}
