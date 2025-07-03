# SRC-20: Native Asset

The following standard allows for the implementation of a standard API for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) using the Sway Language. This standard provides basic functionality as well as on-chain metadata for other applications to use.

## Motivation

A standard interface for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) on Fuel allows external applications to interact with the native asset, whether that be decentralized exchanges, wallets, or Fuel's [Scripts](https://docs.fuel.network/docs/sway/sway-program-types/scripts/) and [Predicates](https://docs.fuel.network/docs/sway/sway-program-types/predicates/).

## Prior Art

The SRC-20 Native Asset Standard naming pays homage to the [ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20) seen on Ethereum. While there is functionality we may use as a reference, it is noted that Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) are fundamentally different than Ethereum's tokens.

There has been a discussion of the Fungible Token Standard on the [Fuel Forum](https://forum.fuel.network/). This discussion can be found [here](https://forum.fuel.network/t/src-20-fungible-token-standard/186).

There has also been a Fungible Token Standard and Non-Fungible Token Standard implementations added to the [Sway-Libs](https://github.com/FuelLabs/sway-libs) repository before the creation of the [Sway-Standards](https://github.com/FuelLabs/sway-standards) repository. The introduction of this standard in the [Sway-Standards](https://github.com/FuelLabs/sway-standards) repository will deprecate the Sway-Libs Fungible Token Standard.

## Specification

### Required Public Functions

The following functions MUST be implemented to follow the SRC-20 standard:

#### `fn total_assets() -> u64`

This function MUST return the total number of individual assets for a contract.

#### `fn total_supply(asset: AssetId) -> Option<u64>`

This function MUST return the total supply of coins for an asset. This function MUST return `Some` for any assets minted by the contract.

#### `fn name(asset: AssetId) -> Option<String>`

This function MUST return the name of the asset, such as “Ether”. This function MUST return `Some` for any assets minted by the contract.

#### `fn symbol(asset: AssetId) -> Option<String>`

This function must return the symbol of the asset, such as “ETH”. This function MUST return `Some` for any assets minted by the contract.

#### `fn decimals(asset: AssetId) -> Option<u8>`

This function must return the number of decimals the asset uses - e.g. 8, which means to divide the coin amount by 100000000 to get its user representation. This function MUST return `Some` for any assets minted by the contract.

### Non-Fungible Asset Restrictions

Non-Fungible Tokens (NFT) or Non-Fungible Assets on Fuel are Native Assets and thus follow the same standard as Fungible Native Assets with some restrictions. For a Native Asset on Fuel to be deemed an NFT, the following must be applied:

* Non-Fungible Assets SHALL have a total supply of one per asset.
* Non-Fungible Assets SHALL have a decimal of `0u8`.

### Logging

The following logs MUST be implemented and emitted to follow the SRC-20 standard.

* IF a value is updated via a function call, a log MUST be emitted.
* IF a value is embedded in a contract as a constant, configurable, or other manner, an event MUST be emitted at least once.

#### SetNameEvent

The `SetNameEvent` MUST be emitted when the name of an asset has updated.

There SHALL be the following fields in the `SetNameEvent` struct:

* `asset`: The `asset` field SHALL be used for the corresponding `AssetId` of the asset has been updated.
* `name`: The `name` field SHALL be used for the corresponding `Option<String>` which represents the name of the asset.
* `sender`: The `sender` field SHALL be used for the corresponding `Identity` which made the function call that has updated the name of the asset.

Example:

```sway
pub struct SetNameEvent {
    pub asset: AssetId,
    pub name: Option<String>,
    pub sender: Identity,
}
```

#### SetSymbolEvent

The `SetSymbolEvent` MUST be emitted when the symbol of an asset has updated.

There SHALL be the following fields in the `SetSymbolEvent` struct:

* `asset`: The `asset` field SHALL be used for the corresponding `AssetId` of the asset has been updated.
* `symbol`: The `symbol` field SHALL be used for the corresponding `Option<String>` which represents the symbol of the asset.
* `sender`: The `sender` field SHALL be used for the corresponding `Identity` which made the function call that has updated the symbol of the asset.

Example:

```sway
pub struct SetSymbolEvent {
    pub asset: AssetId,
    pub symbol: Option<String>,
    pub sender: Identity,
}
```

#### SetDecimalsEvent

The `SetDecimalsEvent` MUST be emitted when the decimals of an asset has updated.

There SHALL be the following fields in the `SetDecimalsEvent` struct:

* `asset`: The `asset` field SHALL be used for the corresponding `AssetId` of the asset has been updated.
* `decimals`: The `decimals` field SHALL be used for the corresponding `u8` which represents the decimals of the asset.
* `sender`: The `sender` field SHALL be used for the corresponding `Identity` which made the function call that has updated the decimals of the asset.

Example:

```sway
pub struct SetDecimalsEvent {
    pub asset: AssetId,
    pub decimals: u8,
    pub sender: Identity,
}
```

#### UpdateTotalSupplyEvent

The `UpdateTotalSupplyEvent` MUST be emitted when the total supply of an asset has updated.

There SHALL be the following fields in the `UpdateTotalSupplyEvent` struct:

* `asset`: The `asset` field SHALL be used for the corresponding `AssetId` of the asset has been updated.
* `supply`: The `supply` field SHALL be used for the corresponding `u64` which represents the total supply of the asset.
* `sender`: The `sender` field SHALL be used for the corresponding `Identity` which made the function call that has updated the total supply of the asset.

Example:

```sway
pub struct UpdateTotalSupplyEvent {
    pub asset: AssetId,
    pub supply: u64,
    pub sender: Identity,
}
```

## Rationale

As the SRC-20 Native Asset Standard leverages Native Assets on Fuel, we do not require the implementation of certain functions such as transfer or approval. This is done directly within the FuelVM and there is no smart contract that requires updating of balances. As Fuel is UTXO based, any transfer events may be indexed on transaction receipts.

Following this, we have omitted the inclusion of any transfer functions or events. The provided specification outlines only the functions necessary to implement fully functional native assets on the Fuel Network. Additional functionality and properties may be added as needed.

## Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). There are no other standards that require compatibility.

## Security Considerations

This standard does not introduce any security concerns, as it does not call external contracts, nor does it define any mutations of the contract state.

## Example ABI

```sway
abi SRC20 {
    #[storage(read)]
    fn total_assets() -> u64;
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64>;
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String>;
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String>;
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8>;
}
```

## Example Implementation

### Single Native Asset

Example of the SRC-20 implementation where a contract contains a single asset with one `SubId`. This implementation is recommended for users that intend to deploy a single asset with their contract.

```sway
contract;

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use std::{auth::msg_sender, string::String};

configurable {
    /// The total supply of coins for the asset minted by this contract.
    TOTAL_SUPPLY: u64 = 100_000_000,
    /// The decimals of the asset minted by this contract.
    DECIMALS: u8 = 9u8,
    /// The name of the asset minted by this contract.
    NAME: str[7] = __to_str_array("MyAsset"),
    /// The symbol of the asset minted by this contract.
    SYMBOL: str[5] = __to_str_array("MYTKN"),
}

impl SRC20 for Contract {
    /// Returns the total number of individual assets minted by a contract.
    ///
    /// # Additional Information
    ///
    /// For this single asset contract, this is always one.
    ///
    /// # Returns
    ///
    /// * [u64] - The number of assets that this contract has minted.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let assets = src_20_abi.total_assets();
    ///     assert(assets == 1);
    /// }
    /// ```
    #[storage(read)]
    fn total_assets() -> u64 {
        1
    }

    /// Returns the total supply of coins for the asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the total supply, this should be the default `SubId`.
    ///
    /// # Returns
    ///
    /// * [Option<u64>] - The total supply of an `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let supply = src_20_abi.total_supply(DEFAULT_SUB_ID);
    ///     assert(supply.unwrap() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        if asset == AssetId::default() {
            Some(TOTAL_SUPPLY)
        } else {
            None
        }
    }

    /// Returns the name of the asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the name, this should be the default `SubId`.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The name of `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let name = src_20_abi.name(DEFAULT_SUB_ID);
    ///     assert(name.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        if asset == AssetId::default() {
            Some(String::from_ascii_str(from_str_array(NAME)))
        } else {
            None
        }
    }

    /// Returns the symbol of the asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the symbol, this should be the default `SubId`.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The symbol of `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let symbol = src_20_abi.symbol(DEFAULT_SUB_ID);
    ///     assert(symbol.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        if asset == AssetId::default() {
            Some(String::from_ascii_str(from_str_array(SYMBOL)))
        } else {
            None
        }
    }

    /// Returns the number of decimals the asset uses.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the decimals, this should be the default `SubId`.
    ///
    /// # Returns
    ///
    /// * [Option<u8>] - The decimal precision used by `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let decimals = src_20_abi.decimals(DEFAULT_SUB_ID);
    ///     assert(decimals.unwrap() == 9u8);
    /// }
    /// ```
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

Example of the SRC-20 implementation where a contract contains multiple assets with differing `SubId`s. This implementation is recommended for users that intend to deploy multiple assets with their contract.

```sway
contract;

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use std::{hash::Hash, storage::storage_string::*, string::String};

storage {
    /// The total number of distinguishable assets minted by this contract.
    total_assets: u64 = 0,
    /// The total supply of coins for a specific asset minted by this contract.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    /// The name of a specific asset minted by this contract.
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    /// The symbol of a specific asset minted by this contract.
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    /// The decimals of a specific asset minted by this contract.
    decimals: StorageMap<AssetId, u8> = StorageMap {},
}

impl SRC20 for Contract {
    /// Returns the total number of individual assets minted  by this contract.
    ///
    /// # Additional Information
    ///
    /// For this single asset contract, this is always one.
    ///
    /// # Returns
    ///
    /// * [u64] - The number of assets that this contract has minted.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let assets = src_20_abi.total_assets();
    ///     assert(assets == 1);
    /// }
    /// ```
    #[storage(read)]
    fn total_assets() -> u64 {
        storage.total_assets.read()
    }

    /// Returns the total supply of coins for an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the total supply.
    ///
    /// # Returns
    ///
    /// * [Option<u64>] - The total supply of an `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let supply = src_20_abi.total_supply(DEFAULT_SUB_ID);
    ///     assert(supply.unwrap() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        storage.total_supply.get(asset).try_read()
    }

    /// Returns the name of an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the name.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The name of `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let name = src_20_abi.name(DEFAULT_SUB_ID);
    ///     assert(name.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        storage.name.get(asset).read_slice()
    }

    /// Returns the symbol of am asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the symbol.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The symbol of `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let symbol = src_20_abi.symbol(DEFAULT_SUB_ID);
    ///     assert(symbol.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        storage.symbol.get(asset).read_slice()
    }

    /// Returns the number of decimals an asset uses.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the decimals.
    ///
    /// # Returns
    ///
    /// * [Option<u8>] - The decimal precision used by `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::constants::DEFAULT_SUB_ID;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let decimals = src_20_abi.decimals(DEFAULT_SUB_ID);
    ///     assert(decimals.unwrap() == 9u8);
    /// }
    /// ```
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        storage.decimals.get(asset).try_read()
    }
}

abi SetSRC20Data {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
        total_supply: u64,
        name: Option<String>,
        symbol: Option<String>,
        decimals: u8,
    );
}

impl SetSRC20Data for Contract {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
        supply: u64,
        name: Option<String>,
        symbol: Option<String>,
        decimals: u8,
    ) {
        // NOTE: There are no checks for if the caller has permissions to update the metadata
        // If this asset does not exist, revert
        if storage.total_supply.get(asset).try_read().is_none() {
            revert(0);
        }
        let sender = msg_sender().unwrap();

        match name {
            Some(unwrapped_name) => {
                storage.name.get(asset).write_slice(unwrapped_name);
                SetNameEvent::new(asset, name, sender).log();
            },
            None => {
                let _ = storage.name.get(asset).clear();
                SetNameEvent::new(asset, name, sender).log();
            }
        }

        match symbol {
            Some(unwrapped_symbol) => {
                storage.symbol.get(asset).write_slice(unwrapped_symbol);
                SetSymbolEvent::new(asset, symbol, sender).log();
            },
            None => {
                let _ = storage.symbol.get(asset).clear();
                SetSymbolEvent::new(asset, symbol, sender).log();
            }
        }

        storage.decimals.get(asset).write(decimals);
        SetDecimalsEvent::new(asset, decimals, sender).log();

        storage.total_supply.get(asset).write(supply);
        TotalSupplyEvent::new(asset, supply, sender).log();
    }
}
```
