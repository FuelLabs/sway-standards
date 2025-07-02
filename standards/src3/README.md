# SRC-3: Minting and Burning Native Assets

The following standard enables the minting and burning of native assets for any fungible assets within the Sway Language. It seeks to define mint and burn functions defined separately from the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.

## Motivation

The intent of this standard is to separate the extensions of minting and burning from the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.

## Prior Art

Minting and burning were initially added to the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.

## Specification

### Required Public Functions

The following functions MUST be implemented to follow the SRC-3 standard:

#### `fn mint(recipient: Identity, sub_id: Option<SubId>, amount: u64)`

This function MUST mint `amount` coins with a sub-identifier and transfer them to the `recipient`.
This function MUST use the `sub_id` as the sub-identifier IF `sub_id` is `Some`, otherwise this function MUST assign a `SubId` if the `sub_id` argument is `None`.
This function MAY contain arbitrary conditions for minting, and revert if those conditions are not met.

##### Mint Arguments

* `recipient` - The `Identity` to which the newly minted asset is transferred to.
* `sub_id` - The sub-identifier of the asset to mint. If this is `None`, a `SubId` MUST be assigned.
* `amount` - The quantity of coins to mint.

#### `fn burn(sub_id: SubId, amount: u64)`

This function MUST burn `amount` coins with the sub-identifier `sub_id` and MUST ensure the `AssetId` of the asset is the sha-256 hash of `(ContractId, SubId)` for the implementing contract.
This function MUST ensure at least `amount` coins have been transferred to the implementing contract.
This function MUST update the total supply defined in the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.
This function MAY contain arbitrary conditions for burning, and revert if those conditions are not met.

##### Burn Arguments

* `sub_id` - The sub-identifier of the asset to burn.
* `amount` - The quantity of coins to burn.

## Rationale

This standard has been added to enable compatibility between applications and allow minting and burning native assets per use case. This standard has been separated from the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard to allow for the minting and burning for all fungible assets, irrelevant of whether they are [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) or not.

## Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) ensuring its compatibility with the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.

## Security Considerations

This standard may introduce security considerations if no checks are implemented to ensure the calling of the `mint()` function is deemed valid or permitted. Checks are highly encouraged.
The burn function may also introduce a security consideration if the total supply within the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard is not modified.

## Example ABI

```sway
abi SRC3 {
    #[storage(read, write)]
    fn mint(recipient: Identity, sub_id: Option<SubId>, amount: u64);
    #[payable]
    #[storage(read, write)]
    fn burn(sub_id: SubId, amount: u64);
}
```

## Example Implementation

### Single Native Asset

Example of the SRC-3 implementation where a contract only mints a single asset with one `SubId`.

```sway
contract;

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src3::SRC3;
use std::{
    asset::{
        burn,
        mint_to,
    },
    auth::msg_sender,
    call_frames::msg_asset_id,
    constants::DEFAULT_SUB_ID,
    context::msg_amount,
    string::String,
};

configurable {
    /// The decimals of the asset minted by this contract.
    DECIMALS: u8 = 9u8,
    /// The name of the asset minted by this contract.
    NAME: str[7] = __to_str_array("MyAsset"),
    /// The symbol of the asset minted by this contract.
    SYMBOL: str[5] = __to_str_array("MYTKN"),
}

storage {
    /// The total supply of the asset minted by this contract.
    total_supply: u64 = 0,
}

impl SRC3 for Contract {
    /// Unconditionally mints new assets using the default SubId.
    ///
    /// # Arguments
    ///
    /// * `recipient`: [Identity] - The user to which the newly minted asset is transferred to.
    /// * `sub_id`: [SubId] - The default SubId.
    /// * `amount`: [u64] - The quantity of coins to mint.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `1`
    ///
    /// # Reverts
    ///
    /// * When the `sub_id` is not the default SubId.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC3, contract);
    ///     contract_abi.mint(Identity::ContractId(contract_id), Some(DEFAULT_SUB_ID), 100);
    /// }
    /// ```
    #[storage(read, write)]
    fn mint(recipient: Identity, sub_id: Option<SubId>, amount: u64) {
        require(
            sub_id
                .is_some() && sub_id
                .unwrap() == DEFAULT_SUB_ID,
            "Incorrect Sub Id",
        );

        // Increment total supply of the asset and mint to the recipient.
        let new_supply = amount + storage.total_supply.read();
        storage.total_supply.write(new_supply);

        mint_to(recipient, DEFAULT_SUB_ID, amount);

        TotalSupplyEvent::new(AssetId::default(), new_supply, msg_sender().unwrap())
            .log();
    }

    /// Unconditionally burns assets sent with the default SubId.
    ///
    /// # Arguments
    ///
    /// * `sub_id`: [SubId] - The default SubId.
    /// * `amount`: [u64] - The quantity of coins to burn.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `1`
    ///
    /// # Reverts
    ///
    /// * When the `sub_id` is not the default SubId.
    /// * When the transaction did not include at least `amount` coins.
    /// * When the transaction did not include the asset minted by this contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId, asset_id: AssetId) {
    ///     let contract_abi = abi(SRC3, contract_id);
    ///     contract_abi {
    ///         gas: 10000,
    ///         coins: 100,
    ///         asset_id: asset_id,
    ///     }.burn(DEFAULT_SUB_ID, 100);
    /// }
    /// ```
    #[payable]
    #[storage(read, write)]
    fn burn(sub_id: SubId, amount: u64) {
        require(sub_id == DEFAULT_SUB_ID, "Incorrect Sub Id");
        require(msg_amount() >= amount, "Incorrect amount provided");
        require(
            msg_asset_id() == AssetId::default(),
            "Incorrect asset provided",
        );

        // Decrement total supply of the asset and burn.
        let new_supply = storage.total_supply.read() - amount;
        storage.total_supply.write(new_supply);

        burn(DEFAULT_SUB_ID, amount);

        TotalSupplyEvent::new(AssetId::default(), new_supply, msg_sender().unwrap())
            .log();
    }
}

// SRC3 extends SRC20, so this must be included
impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        1
    }

    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        if asset == AssetId::default() {
            Some(storage.total_supply.read())
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
    }
}
```

### Multi Native Asset

Example of the SRC-3 implementation where a contract mints multiple assets with differing `SubId` values.

```sway
contract;

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src3::SRC3;
use std::{
    asset::{
        burn,
        mint_to,
    },
    auth::msg_sender,
    call_frames::msg_asset_id,
    constants::DEFAULT_SUB_ID,
    context::msg_amount,
    hash::Hash,
    storage::storage_string::*,
    string::String,
};

// In this example, all assets minted from this contract have the same decimals, name, and symbol
configurable {
    /// The decimals of every asset minted by this contract.
    DECIMALS: u8 = 9u8,
    /// The name of every asset minted by this contract.
    NAME: str[12] = __to_str_array("ExampleAsset"),
    /// The symbol of every asset minted by this contract.
    SYMBOL: str[2] = __to_str_array("EA"),
}

storage {
    /// The total number of distinguishable assets this contract has minted.
    total_assets: u64 = 0,
    /// The total supply of a particular asset.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
}

impl SRC3 for Contract {
    /// Unconditionally mints new assets using the `sub_id` sub-identifier.
    ///
    /// # Arguments
    ///
    /// * `recipient`: [Identity] - The user to which the newly minted asset is transferred to.
    /// * `sub_id`: [Option<SubId>] - The sub-identifier of the newly minted asset.
    /// * `amount`: [u64] - The quantity of coins to mint.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `2`
    /// * Writes: `2`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC3, contract_id);
    ///     contract_abi.mint(Identity::ContractId(contract_id), Some(DEFAULT_SUB_ID), 100);
    /// }
    /// ```
    #[storage(read, write)]
    fn mint(recipient: Identity, sub_id: Option<SubId>, amount: u64) {
        let sub_id = match sub_id {
            Some(s) => s,
            None => DEFAULT_SUB_ID,
        };
        let asset_id = AssetId::new(ContractId::this(), sub_id);

        // If this SubId is new, increment the total number of distinguishable assets this contract has minted.
        let asset_supply = storage.total_supply.get(asset_id).try_read();
        match asset_supply {
            None => {
                storage.total_assets.write(storage.total_assets.read() + 1)
            },
            _ => {},
        }

        // Increment total supply of the asset and mint to the recipient.
        let new_supply = amount + asset_supply.unwrap_or(0);
        storage.total_supply.insert(asset_id, new_supply);

        mint_to(recipient, sub_id, amount);

        TotalSupplyEvent::new(asset_id, new_supply, msg_sender().unwrap())
            .log();
    }

    /// Unconditionally burns assets sent with the `sub_id` sub-identifier.
    ///
    /// # Arguments
    ///
    /// * `sub_id`: [SubId] - The sub-identifier of the asset to burn.
    /// * `amount`: [u64] - The quantity of coins to burn.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `1`
    ///
    /// # Reverts
    ///
    /// * When the transaction did not include at least `amount` coins.
    /// * When the asset included in the transaction does not have the SubId `sub_id`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId, asset_id: AssetId) {
    ///     let contract_abi = abi(SRC3, contract_id);
    ///     contract_abi {
    ///         gas: 10000,
    ///         coins: 100,
    ///         asset_id: asset_id,
    ///     }.burn(DEFAULT_SUB_ID, 100);
    /// }
    /// ```
    #[payable]
    #[storage(read, write)]
    fn burn(sub_id: SubId, amount: u64) {
        let asset_id = AssetId::new(ContractId::this(), sub_id);
        require(msg_amount() == amount, "Incorrect amount provided");
        require(msg_asset_id() == asset_id, "Incorrect asset provided");

        // Decrement total supply of the asset and burn.
        let new_supply = storage.total_supply.get(asset_id).read() - amount;
        storage.total_supply.insert(asset_id, new_supply);

        burn(sub_id, amount);

        TotalSupplyEvent::new(asset_id, new_supply, msg_sender().unwrap())
            .log();
    }
}

// SRC3 extends SRC20, so this must be included
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
    #[storage(read)]
    fn set_src20_data(asset: AssetId);
}

impl SetSRC20Data for Contract {
    #[storage(read)]
    fn set_src20_data(asset: AssetId) {
        // NOTE: There are no checks for if the caller has permissions to update the metadata
        // If this asset does not exist, revert
        if storage.total_supply.get(asset).try_read().is_none() {
            revert(0);
        }
        let sender = msg_sender().unwrap();
        let name = Some(String::from_ascii_str(from_str_array(NAME)));
        let symbol = Some(String::from_ascii_str(from_str_array(SYMBOL)));

        SetNameEvent::new(asset, name, sender).log();
        SetSymbolEvent::new(asset, symbol, sender).log();
        SetDecimalsEvent::new(asset, DECIMALS, sender).log();
    }
}
```
