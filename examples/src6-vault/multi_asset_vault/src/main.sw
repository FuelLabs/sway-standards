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

use standards::{
    src20::{
        SetDecimalsEvent,
        SetNameEvent,
        SetSymbolEvent,
        SRC20,
        TotalSupplyEvent,
    },
    src6::{
        Deposit,
        SRC6,
        Withdraw,
    },
};

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
