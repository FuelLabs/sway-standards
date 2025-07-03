# SRC-6: Vault

The following standard allows for the implementation of a standard API for asset vaults such as yield-bearing asset vaults or asset wrappers. This standard is an optional add-on to the [SRC-20](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) standard.

## Motivation

Asset vaults allow users to own shares of variable amounts of assets, such as lending protocols which may have growing assets due to profits from interest. This pattern is highly useful and would greatly benefit from standardization.

## Prior Art

Asset vaults have been thoroughly explored on Ethereum and with [EIP 4626](https://eips.ethereum.org/EIPS/eip-4626) they have their own standard for it. However as Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) are fundamentally different from Ethereum's ERC-20 tokens, the implementation will differ, but the interface may be used as a reference.

## Specification

### Required public functions

The following functions MUST be implemented to follow the SRC-6 standard. Any contract that implements the SRC-6 standard MUST implement the SRC-20 standard.

#### `fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64`

This function takes the `receiver` Identity and the SubId `vault_sub_id` of the sub-vault as an argument and returns the amount of shares minted to the `receiver`.

- This function MUST allow for depositing of the underlying asset in exchange for pro-rata shares of the vault.
- This function MAY reject arbitrary assets based on implementation and MUST revert if unaccepted assets are forwarded.
- This function MAY reject any arbitrary `receiver` based on implementation and MUST revert in the case of a blacklisted or non-whitelisted `receiver`.
- This function MUST mint an asset representing the pro-rata share of the vault, with the SubId of the `sha256((underlying_asset, vault_sub_id))` digest, where `underlying_asset` is the `AssetId` of the deposited asset and the `vault_sub_id` is the id of the vault.
- This function MUST emit a `Deposit` log.
- This function MUST return the amount of minted shares.

#### `fn withdraw(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> u64`

This function takes the `receiver` Identity, the `underlying_asset` `AssetId`, and the `vault_sub_id` of the sub vault, as arguments and returns the amount of assets transferred to the `receiver`.

- This function MUST allow for redeeming of the vault shares in exchange for a pro-rata amount of the underlying assets.
- This function MUST revert if any `AssetId` other than the `AssetId` representing the underlying asset's shares for the given sub vault at `vault_sub_id` is forwarded. (i.e. transferred share's `AssetId` must be equal to `AssetId::new(ContractId::this(), sha256((underlying_asset, vault_sub_id))`)
- This function MUST burn the received shares.
- This function MUST emit a `Withdraw` log.
- This function MUST return amount of assets transferred to the receiver.

#### `fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64`

This function returns the total assets under management by vault. Includes assets controlled by the vault but not directly possessed by vault. It takes the `underlying_asset` `AssetId` and the `vault_sub_id` of the sub vault as arguments and returns the total amount of assets of `AssetId` under management by vault.

- This function MUST return total amount of assets of `underlying_asset` `AssetId` under management by vault.
- This function MUST return 0 if there are no assets of `underlying_asset` `AssetId` under management by vault.
- This function MUST NOT revert under any circumstances.

#### `fn max_depositable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>`

This is a helper function for getting the maximum amount of assets that can be deposited. It takes the hypothetical `receiver` `Identity`, the `underlying_asset` `AssetId`, and the `vault_sub_id` `SubId` of the sub vault as an arguments and returns the maximum amount of assets that can be deposited into the contract, for the given asset.

- This function MUST return the maximum amount of assets that can be deposited into the contract, for the given `underlying_asset`, if the given `vault_sub_id` vault exists.
- This function MUST return an `Some(amount)` if the given `vault_sub_id` vault exists.
- This function MUST return an `None` if the given `vault_sub_id` vault does not exist.
- This function MUST account for both global and user specific limits. For example: if deposits are disabled, even temporarily, MUST return 0.

#### `fn max_withdrawable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>`

This is a helper function for getting maximum withdrawable. It takes the hypothetical `receiver` `Identity`, the `underlying_asset` `AssetId`, and the `vault_sub_id` SubId of the sub vault as an argument and returns the maximum amount of assets that can be withdrawn from the contract, for the given asset.

- This function MUST return the maximum amount of assets that can be withdrawn from the contract, for the given `underlying_asset`, if the given `vault_sub_id` vault exists.
- This function MUST return an `Some(amount)` if the given `vault_sub_id` vault exists.
- This function MUST return an `None` if the given `vault_sub_id` vault does not exist.
- This function MUST account for global limits. For example: if withdrawals are disabled, even temporarily, MUST return 0.

### Required logs

The following logs MUST be emitted at the specified occasions.

#### `Deposit`

`caller` has called the `deposit()` method sending `deposited_amount` assets of the `underlying_asset` Asset to the subvault of `vault_sub_id`, in exchange for `minted_shares` shares sent to the receiver `receiver`.

The `Deposit` struct MUST be logged whenever new shares are minted via the `deposit()` method.

The `Deposit` log SHALL have the following fields.

**`caller`: `Identity`**

The `caller` field MUST represent the `Identity` which called the deposit function.

**`receiver`: `Identity`**

The `receiver` field MUST represent the `Identity` which received the vault shares.

**`underlying_asset`: `AssetId`**

The `underlying_asset` field MUST represent the `AssetId` of the asset which was deposited into the vault.

**`vault_sub_id`: `SubId`**

The `vault_sub_id` field MUST represent the `SubId` of the vault which was deposited into.

**`deposited_amount`: `u64`**

The `deposited_amount` field MUST represent the `u64` amount of assets deposited into the vault.

**`minted_shares`: `u64`**

The `minted_shares` field MUST represent the `u64` amount of shares minted.

#### `Withdraw`

`caller` has called the `withdraw()` method sending `burned_shares` shares in exchange for `withdrawn_amount` assets of the `underlying_asset` Asset from the subvault of `vault_sub_id` to the receiver `receiver`.

The `Withdraw` struct MUST be logged whenever shares are redeemed for assets via the `withdraw()` method.

The `Withdraw` log SHALL have the following fields.

**`caller`: `Identity`**

The `caller` field MUST represent the Identity which called the withdraw function.

**`receiver`: `Identity`**

The `receiver` field MUST represent the Identity which received the withdrawn assets.

**`underlying_asset`: `AssetId`**

The `underlying_asset` field MUST represent the `AssetId` of the asset that was withdrawn.

**`vault_sub_id`: `SubId`**

The `vault_sub_id` field MUST represent the SubId of the vault from which was withdrawn.

**`withdrawn_amount`: `u64`**

The `withdrawn_amount` field MUST represent the `u64` amount of coins withdrawn.

**`burned_shares`: `u64`**

The `burned_shares` field MUST represent the `u64` amount of shares burned.

## Rationale

The ABI discussed covers the known use cases of asset vaults while allowing safe implementations.

## Backwards Compatibility

This standard is fully compatible with the [SRC-20 standard](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/).

## Security Considerations

Incorrect implementation of asset vaults could allow attackers to steal underlying assets. It is recommended to properly audit any code using this standard to ensure exploits are not possible.

## Example ABI

```sway
abi SRC6 {
    #[payable]
    #[storage(read, write)]
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64;

    #[payable]
    #[storage(read, write)]
    fn withdraw(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> u64;

    #[storage(read)]
    fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64;

    #[storage(read)]
    fn max_depositable(receiver: Identity, underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>;

    #[storage(read)]
    fn max_withdrawable(underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>;
}
```

## Example Implementation

### Multi Asset Vault

A basic implementation of the vault standard that supports any number of sub vaults being created for every `AssetId`.

```sway
contract;

use std::{
    asset::transfer,
    call_frames::msg_asset_id,
    context::msg_amount,
    hash::{
        Hash,
        sha256,
    },
    storage::storage_string::*,
    string::String,
};

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src6::{Deposit, SRC6, Withdraw};

pub struct VaultInfo {
    /// Amount of assets currently managed by this vault
    managed_assets: u64,
    /// The vault_sub_id of this vault.
    vault_sub_id: SubId,
    /// The asset being managed by this vault
    asset: AssetId,
}

storage {
    /// Vault share AssetId -> VaultInfo.
    vault_info: StorageMap<AssetId, VaultInfo> = StorageMap {},
    /// Number of different assets managed by this contract.
    total_assets: u64 = 0,
    /// Total supply of shares for each asset.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    /// Asset name.
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    /// Asset symbol.
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    /// Asset decimals.
    decimals: StorageMap<AssetId, u8> = StorageMap {},
}

impl SRC6 for Contract {
    #[payable]
    #[storage(read, write)]
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64 {
        let asset_amount = msg_amount();
        require(asset_amount != 0, "ZERO_ASSETS");

        let underlying_asset = msg_asset_id();
        let (shares, share_asset, share_asset_vault_sub_id) = preview_deposit(underlying_asset, vault_sub_id, asset_amount);

        _mint(receiver, share_asset, share_asset_vault_sub_id, shares);

        let mut vault_info = match storage.vault_info.get(share_asset).try_read() {
            Some(vault_info) => vault_info,
            None => VaultInfo {
                managed_assets: 0,
                vault_sub_id,
                asset: underlying_asset,
            },
        };
        vault_info.managed_assets = vault_info.managed_assets + asset_amount;
        storage.vault_info.insert(share_asset, vault_info);

        Deposit::new(
            msg_sender()
                .unwrap(),
            receiver,
            underlying_asset,
            vault_sub_id,
            asset_amount,
            shares,
        )
            .log();

        shares
    }

    #[payable]
    #[storage(read, write)]
    fn withdraw(
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> u64 {
        let shares = msg_amount();
        require(shares != 0, "ZERO_SHARES");

        let (share_asset_id, share_asset_vault_sub_id) = vault_asset_id(underlying_asset, vault_sub_id);

        require(msg_asset_id() == share_asset_id, "INVALID_ASSET_ID");
        let assets = preview_withdraw(share_asset_id, shares);

        let mut vault_info = storage.vault_info.get(share_asset_id).read();
        vault_info.managed_assets = vault_info.managed_assets - shares;
        storage.vault_info.insert(share_asset_id, vault_info);

        _burn(share_asset_id, share_asset_vault_sub_id, shares);

        transfer(receiver, underlying_asset, assets);

        Withdraw::new(
            msg_sender()
                .unwrap(),
            receiver,
            underlying_asset,
            vault_sub_id,
            assets,
            shares,
        )
            .log();

        assets
    }
    #[storage(read)]
    fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64 {
        let vault_share_asset = vault_asset_id(underlying_asset, vault_sub_id).0;
        // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
        managed_assets(vault_share_asset)
    }

    #[storage(read)]
    fn max_depositable(
        _receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> Option<u64> {
        let vault_share_asset = vault_asset_id(underlying_asset, vault_sub_id).0;
        // This is the max value of u64 minus the current managed_assets. Ensures that the sum will always be lower than u64::MAX.
        match storage.vault_info.get(vault_share_asset).try_read() {
            Some(vault_info) => Some(u64::max() - vault_info.managed_assets),
            None => None,
        }
    }

    #[storage(read)]
    fn max_withdrawable(underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64> {
        let vault_share_asset = vault_asset_id(underlying_asset, vault_sub_id).0;
        // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, total_assets should be greater than max_withdrawable.
        match storage.vault_info.get(vault_share_asset).try_read() {
            Some(vault_info) => Some(vault_info.managed_assets),
            None => None,
        }
    }
}

impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        storage.total_assets.try_read().unwrap_or(0)
    }

    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        storage.total_supply.get(asset).try_read()
    }

    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        storage.name.get(asset).read_slice()
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        storage.symbol.get(asset).read_slice()
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        storage.decimals.get(asset).try_read()
    }
}

abi SetSRC20Data {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
        name: Option<String>,
        symbol: Option<String>,
        decimals: u8,
    );
}

impl SetSRC20Data for Contract {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
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
    }
}

/// Returns the vault shares assetid and subid for the given assets assetid and the vaults sub id
fn vault_asset_id(asset: AssetId, vault_sub_id: SubId) -> (AssetId, SubId) {
    let share_asset_vault_sub_id = sha256((asset, vault_sub_id));
    let share_asset_id = AssetId::new(ContractId::this(), share_asset_vault_sub_id);
    (share_asset_id, share_asset_vault_sub_id)
}

#[storage(read)]
fn managed_assets(vault_share_asset_id: AssetId) -> u64 {
    match storage.vault_info.get(vault_share_asset_id).try_read() {
        Some(vault_info) => vault_info.managed_assets,
        None => 0,
    }
}

#[storage(read)]
fn preview_deposit(
    underlying_asset: AssetId,
    vault_sub_id: SubId,
    assets: u64,
) -> (u64, AssetId, SubId) {
    let (share_asset_id, share_asset_vault_sub_id) = vault_asset_id(underlying_asset, vault_sub_id);

    let shares_supply = storage.total_supply.get(share_asset_id).try_read().unwrap_or(0);
    if shares_supply == 0 {
        (assets, share_asset_id, share_asset_vault_sub_id)
    } else {
        (
            assets * shares_supply / managed_assets(share_asset_id),
            share_asset_id,
            share_asset_vault_sub_id,
        )
    }
}

#[storage(read)]
fn preview_withdraw(share_asset_id: AssetId, shares: u64) -> u64 {
    let supply = storage.total_supply.get(share_asset_id).read();
    if supply == shares {
        managed_assets(share_asset_id)
    } else {
        shares * (managed_assets(share_asset_id) / supply)
    }
}

#[storage(read, write)]
pub fn _mint(
    recipient: Identity,
    asset_id: AssetId,
    vault_sub_id: SubId,
    amount: u64,
) {
    use std::asset::mint_to;

    let supply = storage.total_supply.get(asset_id).try_read();
    // Only increment the number of assets minted by this contract if it hasn't been minted before.
    if supply.is_none() {
        storage.total_assets.write(storage.total_assets.read() + 1);
    }
    let new_supply = supply.unwrap_or(0) + amount;
    storage.total_supply.insert(asset_id, new_supply);
    mint_to(recipient, vault_sub_id, amount);
    TotalSupplyEvent::new(asset_id, new_supply, msg_sender().unwrap())
        .log();
}

#[storage(read, write)]
pub fn _burn(asset_id: AssetId, vault_sub_id: SubId, amount: u64) {
    use std::{asset::burn, context::this_balance};

    require(
        this_balance(asset_id) >= amount,
        "BurnError::NotEnoughCoins",
    );
    // If we pass the check above, we can assume it is safe to unwrap.
    let supply = storage.total_supply.get(asset_id).try_read().unwrap();
    let new_supply = supply - amount;
    storage.total_supply.insert(asset_id, new_supply);
    burn(vault_sub_id, amount);
    TotalSupplyEvent::new(asset_id, new_supply, msg_sender().unwrap())
        .log();
}
```

### Single Asset Vault

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single `AssetId`.

```sway
contract;

use std::{
    asset::transfer,
    call_frames::msg_asset_id,
    context::msg_amount,
    hash::{
        Hash,
        sha256,
    },
    storage::storage_string::*,
    string::String,
};

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src6::{Deposit, SRC6, Withdraw};

pub struct VaultInfo {
    /// Amount of assets currently managed by this vault
    managed_assets: u64,
    /// The vault_sub_id of this vault.
    vault_sub_id: SubId,
    /// The asset being managed by this vault
    asset: AssetId,
}

storage {
    /// Vault share AssetId -> VaultInfo.
    vault_info: StorageMap<AssetId, VaultInfo> = StorageMap {},
    /// Number of different assets managed by this contract.
    total_assets: u64 = 0,
    /// Total supply of shares.
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    /// Asset name.
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    /// Asset symbol.
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    /// Asset decimals.
    decimals: StorageMap<AssetId, u8> = StorageMap {},
}

impl SRC6 for Contract {
    #[payable]
    #[storage(read, write)]
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64 {
        let asset_amount = msg_amount();
        let underlying_asset = msg_asset_id();

        require(underlying_asset == AssetId::base(), "INVALID_ASSET_ID");
        let (shares, share_asset, share_asset_vault_sub_id) = preview_deposit(underlying_asset, vault_sub_id, asset_amount);
        require(asset_amount != 0, "ZERO_ASSETS");

        _mint(receiver, share_asset, share_asset_vault_sub_id, shares);

        let mut vault_info = match storage.vault_info.get(share_asset).try_read() {
            Some(vault_info) => vault_info,
            None => VaultInfo {
                managed_assets: 0,
                vault_sub_id,
                asset: underlying_asset,
            },
        };
        vault_info.managed_assets = vault_info.managed_assets + asset_amount;
        storage.vault_info.insert(share_asset, vault_info);

        Deposit::new(
            msg_sender()
                .unwrap(),
            receiver,
            underlying_asset,
            vault_sub_id,
            asset_amount,
            shares,
        )
            .log();

        shares
    }

    #[payable]
    #[storage(read, write)]
    fn withdraw(
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> u64 {
        let shares = msg_amount();
        require(shares != 0, "ZERO_SHARES");

        let (share_asset_id, share_asset_vault_sub_id) = vault_asset_id(underlying_asset, vault_sub_id);

        require(msg_asset_id() == share_asset_id, "INVALID_ASSET_ID");
        let assets = preview_withdraw(share_asset_id, shares);

        let mut vault_info = storage.vault_info.get(share_asset_id).read();
        vault_info.managed_assets = vault_info.managed_assets - shares;
        storage.vault_info.insert(share_asset_id, vault_info);

        _burn(share_asset_id, share_asset_vault_sub_id, shares);

        transfer(receiver, underlying_asset, assets);

        Withdraw::new(
            msg_sender()
                .unwrap(),
            receiver,
            underlying_asset,
            vault_sub_id,
            assets,
            shares,
        )
            .log();

        assets
    }

    #[storage(read)]
    fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64 {
        if underlying_asset == AssetId::base() {
            let vault_share_asset = vault_asset_id(underlying_asset, vault_sub_id).0;
            // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
            managed_assets(vault_share_asset)
        } else {
            0
        }
    }

    #[storage(read)]
    fn max_depositable(
        _receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> Option<u64> {
        let vault_share_asset = vault_asset_id(underlying_asset, vault_sub_id).0;

        match (
            underlying_asset == AssetId::base(),
            storage.vault_info.get(vault_share_asset).try_read(),
        ) {
            // This is the max value of u64 minus the current managed_assets. Ensures that the sum will always be lower than u64::MAX.
            (true, Some(vault_info)) => Some(u64::max() - vault_info.managed_assets),
            _ => None,
        }
    }

    #[storage(read)]
    fn max_withdrawable(underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64> {
        let vault_share_asset = vault_asset_id(underlying_asset, vault_sub_id).0;

        match (
            underlying_asset == AssetId::base(),
            storage.vault_info.get(vault_share_asset).try_read(),
        ) {
            // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
            (true, Some(vault_info)) => Some(vault_info.managed_assets),
            _ => None,
        }
    }
}

impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        storage.total_assets.try_read().unwrap_or(0)
    }

    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        storage.total_supply.get(asset).try_read()
    }

    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        storage.name.get(asset).read_slice()
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        storage.symbol.get(asset).read_slice()
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        storage.decimals.get(asset).try_read()
    }
}

abi SetSRC20Data {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
        name: Option<String>,
        symbol: Option<String>,
        decimals: u8,
    );
}

impl SetSRC20Data for Contract {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
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
    }
}

/// Returns the vault shares assetid and subid for the given assets assetid and the vaults sub id
fn vault_asset_id(underlying_asset: AssetId, vault_sub_id: SubId) -> (AssetId, SubId) {
    let share_asset_vault_sub_id = sha256((underlying_asset, vault_sub_id));
    let share_asset_id = AssetId::new(ContractId::this(), share_asset_vault_sub_id);
    (share_asset_id, share_asset_vault_sub_id)
}

#[storage(read)]
fn managed_assets(vault_share_asset_id: AssetId) -> u64 {
    match storage.vault_info.get(vault_share_asset_id).try_read() {
        Some(vault_info) => vault_info.managed_assets,
        None => 0,
    }
}

#[storage(read)]
fn preview_deposit(
    underlying_asset: AssetId,
    vault_sub_id: SubId,
    assets: u64,
) -> (u64, AssetId, SubId) {
    let (share_asset_id, share_asset_vault_sub_id) = vault_asset_id(underlying_asset, vault_sub_id);

    let shares_supply = storage.total_supply.get(share_asset_id).try_read().unwrap_or(0);
    if shares_supply == 0 {
        (assets, share_asset_id, share_asset_vault_sub_id)
    } else {
        (
            assets * shares_supply / managed_assets(share_asset_id),
            share_asset_id,
            share_asset_vault_sub_id,
        )
    }
}

#[storage(read)]
fn preview_withdraw(share_asset_id: AssetId, shares: u64) -> u64 {
    let supply = storage.total_supply.get(share_asset_id).read();
    if supply == shares {
        managed_assets(share_asset_id)
    } else {
        shares * (managed_assets(share_asset_id) / supply)
    }
}

#[storage(read, write)]
pub fn _mint(
    recipient: Identity,
    asset_id: AssetId,
    vault_sub_id: SubId,
    amount: u64,
) {
    use std::asset::mint_to;

    let supply = storage.total_supply.get(asset_id).try_read();
    // Only increment the number of assets minted by this contract if it hasn't been minted before.
    if supply.is_none() {
        storage.total_assets.write(storage.total_assets.read() + 1);
    }
    let new_supply = supply.unwrap_or(0) + amount;
    storage.total_supply.insert(asset_id, new_supply);
    mint_to(recipient, vault_sub_id, amount);
    TotalSupplyEvent::new(asset_id, new_supply, msg_sender().unwrap())
        .log();
}

#[storage(read, write)]
pub fn _burn(asset_id: AssetId, vault_sub_id: SubId, amount: u64) {
    use std::{asset::burn, context::this_balance};

    require(
        this_balance(asset_id) >= amount,
        "BurnError::NotEnoughCoins",
    );
    // If we pass the check above, we can assume it is safe to unwrap.
    let supply = storage.total_supply.get(asset_id).try_read().unwrap();
    let new_supply = supply - amount;
    storage.total_supply.insert(asset_id, new_supply);
    burn(vault_sub_id, amount);
    TotalSupplyEvent::new(asset_id, new_supply, msg_sender().unwrap())
        .log();
}
```

## Single Asset Single Sub Vault

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single `AssetId`, and to a single Sub vault.

```sway
contract;

use std::{
    asset::transfer,
    call_frames::msg_asset_id,
    context::msg_amount,
    hash::{
        Hash,
        sha256,
    },
    storage::storage_string::*,
    string::String,
};

use src20::{SetDecimalsEvent, SetNameEvent, SetSymbolEvent, SRC20, TotalSupplyEvent};
use src6::{Deposit, SRC6, Withdraw};

configurable {
    /// The only sub vault that can be deposited and withdrawn from this vault.
    ACCEPTED_SUB_VAULT: SubId = SubId::zero(),
    PRE_CALCULATED_SHARE_VAULT_SUB_ID: SubId = 0xf5a5fd42d16a20302798ef6ed309979b43003d2320d9f0e8ea9831a92759fb4b,
}

storage {
    /// The total amount of assets managed by this vault.
    managed_assets: u64 = 0,
    /// The total amount of shares minted by this vault.
    total_supply: u64 = 0,
    /// The name of a specific asset minted by this contract.
    name: StorageString = StorageString {},
    /// The symbol of a specific asset minted by this contract.
    symbol: StorageString = StorageString {},
    /// The decimals of a specific asset minted by this contract.
    decimals: u8 = 9,
}

impl SRC6 for Contract {
    #[payable]
    #[storage(read, write)]
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64 {
        require(vault_sub_id == ACCEPTED_SUB_VAULT, "INVALID_vault_sub_id");

        let underlying_asset = msg_asset_id();
        require(underlying_asset == AssetId::base(), "INVALID_ASSET_ID");

        let asset_amount = msg_amount();
        require(asset_amount != 0, "ZERO_ASSETS");
        let shares = preview_deposit(asset_amount);

        _mint(receiver, shares);

        storage
            .managed_assets
            .write(storage.managed_assets.read() + asset_amount);

        Deposit::new(
            msg_sender()
                .unwrap(),
            receiver,
            underlying_asset,
            vault_sub_id,
            asset_amount,
            shares,
        )
            .log();

        shares
    }

    #[payable]
    #[storage(read, write)]
    fn withdraw(
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> u64 {
        require(underlying_asset == AssetId::base(), "INVALID_ASSET_ID");
        require(vault_sub_id == ACCEPTED_SUB_VAULT, "INVALID_vault_sub_id");

        let shares = msg_amount();
        require(shares != 0, "ZERO_SHARES");

        let share_asset_id = vault_assetid();

        require(msg_asset_id() == share_asset_id, "INVALID_ASSET_ID");
        let assets = preview_withdraw(shares);

        storage
            .managed_assets
            .write(storage.managed_assets.read() - shares);

        _burn(share_asset_id, shares);

        transfer(receiver, underlying_asset, assets);

        Withdraw::new(
            msg_sender()
                .unwrap(),
            receiver,
            underlying_asset,
            vault_sub_id,
            assets,
            shares,
        )
            .log();

        assets
    }

    #[storage(read)]
    fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64 {
        if underlying_asset == AssetId::base() && vault_sub_id == ACCEPTED_SUB_VAULT {
            // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
            storage.managed_assets.read()
        } else {
            0
        }
    }

    #[storage(read)]
    fn max_depositable(
        _receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> Option<u64> {
        if underlying_asset == AssetId::base() && vault_sub_id == ACCEPTED_SUB_VAULT {
            // This is the max value of u64 minus the current managed_assets. Ensures that the sum will always be lower than u64::MAX.
            Some(u64::max() - storage.managed_assets.read())
        } else {
            None
        }
    }

    #[storage(read)]
    fn max_withdrawable(underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64> {
        if underlying_asset == AssetId::base() && vault_sub_id == ACCEPTED_SUB_VAULT {
            // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
            Some(storage.managed_assets.read())
        } else {
            None
        }
    }
}

impl SRC20 for Contract {
    #[storage(read)]
    fn total_assets() -> u64 {
        1
    }

    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        if asset == vault_assetid() {
            Some(storage.total_supply.read())
        } else {
            None
        }
    }

    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        if asset == vault_assetid() {
            match storage.name.read_slice() {
                Some(name) => Some(name),
                None => None,
            }
        } else {
            None
        }
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        if asset == vault_assetid() {
            match storage.symbol.read_slice() {
                Some(symbol) => Some(symbol),
                None => None,
            }
        } else {
            None
        }
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        if asset == vault_assetid() {
            Some(storage.decimals.read())
        } else {
            None
        }
    }
}

abi SetSRC20Data {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
        name: Option<String>,
        symbol: Option<String>,
        decimals: u8,
    );
}

impl SetSRC20Data for Contract {
    #[storage(read, write)]
    fn set_src20_data(
        asset: AssetId,
        name: Option<String>,
        symbol: Option<String>,
        decimals: u8,
    ) {
        // NOTE: There are no checks for if the caller has permissions to update the metadata
        require(asset == vault_assetid(), "INVALID_ASSET_ID");
        let sender = msg_sender().unwrap();

        match name {
            Some(unwrapped_name) => {
                storage.name.write_slice(unwrapped_name);
                SetNameEvent::new(asset, name, sender).log();
            },
            None => {
                let _ = storage.name.clear();
                SetNameEvent::new(asset, name, sender).log();
            }
        }

        match symbol {
            Some(unwrapped_symbol) => {
                storage.symbol.write_slice(unwrapped_symbol);
                SetSymbolEvent::new(asset, symbol, sender).log();
            },
            None => {
                let _ = storage.symbol.clear();
                SetSymbolEvent::new(asset, symbol, sender).log();
            }
        }

        storage.decimals.write(decimals);
        SetDecimalsEvent::new(asset, decimals, sender).log();
    }
}

/// Returns the vault shares assetid for the given assets assetid and the vaults sub id
fn vault_assetid() -> AssetId {
    let share_asset_id = AssetId::new(ContractId::this(), PRE_CALCULATED_SHARE_VAULT_SUB_ID);
    share_asset_id
}

#[storage(read)]
fn preview_deposit(assets: u64) -> u64 {
    let shares_supply = storage.total_supply.try_read().unwrap_or(0);
    if shares_supply == 0 {
        assets
    } else {
        assets * shares_supply / storage.managed_assets.try_read().unwrap_or(0)
    }
}

#[storage(read)]
fn preview_withdraw(shares: u64) -> u64 {
    let supply = storage.total_supply.read();
    if supply == shares {
        storage.managed_assets.read()
    } else {
        shares * (storage.managed_assets.read() / supply)
    }
}

#[storage(read, write)]
pub fn _mint(recipient: Identity, amount: u64) {
    use std::asset::mint_to;

    let supply = storage.total_supply.read();
    let new_supply = supply + amount;
    storage.total_supply.write(new_supply);
    mint_to(recipient, PRE_CALCULATED_SHARE_VAULT_SUB_ID, amount);
    TotalSupplyEvent::new(vault_assetid(), new_supply, msg_sender().unwrap())
        .log();
}

#[storage(read, write)]
pub fn _burn(asset_id: AssetId, amount: u64) {
    use std::{asset::burn, context::this_balance};

    require(
        this_balance(asset_id) >= amount,
        "BurnError::NotEnoughCoins",
    );
    // If we pass the check above, we can assume it is safe to unwrap.
    let supply = storage.total_supply.read();
    let new_supply = supply - amount;
    storage.total_supply.write(new_supply);
    burn(PRE_CALCULATED_SHARE_VAULT_SUB_ID, amount);
    TotalSupplyEvent::new(vault_assetid(), new_supply, msg_sender().unwrap())
        .log();
}
```
