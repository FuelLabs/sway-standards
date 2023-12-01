contract;

use std::{
    auth::msg_sender,
    call_frames::msg_asset_id,
    context::msg_amount,
    hash::{
        Hash,
        sha256,
    },
    storage::{
        storage_map::*,
        storage_string::*,
    },
    token::{
        transfer,
    },
};

use src_6::{Deposit, SRC6, Withdraw};
use src_20::SRC20;
use std::string::String;

pub struct VaultInfo {
    /// Amount of assets currently managed by this vault
    managed_assets: u64,
    /// The sub_id of this vault.
    sub_id: SubId,
    /// The asset being managed by this vault
    asset: AssetId,
}

storage {
    /// Vault share AssetId -> VaultInfo
    vault_info: StorageMap<AssetId, VaultInfo> = StorageMap {},
    
    total_assets: u64 = 0,
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    decimals: StorageMap<AssetId, u8> = StorageMap {},
}

impl SRC6 for Contract {
    #[storage(read)]
    fn managed_assets(asset: AssetId, sub_id: SubId) -> u64 {
        let vault_share_asset = vault_asset_id(asset, sub_id).0;
        // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
        managed_assets(vault_share_asset)
    }

    #[storage(read, write)]
    fn deposit(receiver: Identity, sub_id: SubId) -> u64 {
        let asset_amount = msg_amount();
        let asset = msg_asset_id();
        let (shares, share_asset, share_asset_sub_id) = preview_deposit(asset, sub_id, assets);
        require(assets != 0, "ZERO_ASSETS");

        _mint(receiver, share_asset, share_asset_sub_id, shares);
        storage.total_supply.insert(asset, storage.total_supply.get(asset).read() + shares);

        let mut vault_info = storage.vault_info.get(share_asset).read();
        vault_info.managed_assets = vault_info.managed_assets + assets;
        storage.vault_info.insert(share_asset, vault_info);

        log(Deposit {
            caller: msg_sender().unwrap(),
            receiver: receiver,
            asset: asset,
            sub_id: sub_id,
            assets: assets,
            shares: shares,
        });

        shares
    }

    #[storage(read, write)]
    fn withdraw(asset: AssetId, sub_id: SubId, receiver: Identity) -> u64 {
        let shares = msg_amount();
        require(shares != 0, "ZERO_SHARES");

        let (share_asset_id, share_asset_sub_id) = vault_asset_id(asset, sub_id);

        require(msg_asset_id() == share_asset_id, "INVALID_ASSET_ID");
        let assets = preview_withdraw(share_asset_id, shares);

        _burn(share_asset_id, share_asset_sub_id, shares);
        storage.total_supply.insert(asset, storage.total_supply.get(asset).read() - shares);

        transfer(receiver, asset, assets);

        log(Withdraw {
            caller: msg_sender().unwrap(),
            receiver: receiver,
            asset: asset,
            sub_id: sub_id,
            assets: assets,
            shares: shares,
        });

        assets
    }

    #[storage(read)]
    fn convert_to_shares(asset: AssetId, sub_id: SubId, assets: u64) -> Option<u64> {
        Option::Some(preview_deposit(asset, sub_id, assets).0)
    }

    #[storage(read)]
    fn convert_to_assets(asset: AssetId, sub_id: SubId, shares: u64) -> Option<u64> {
        Option::Some(preview_withdraw(AssetId::new(ContractId::this(), sha256((asset.into(), sub_id))), shares))
    }

    #[storage(read)]
    fn max_depositable(asset: AssetId, sub_id: SubId) -> Option<u64> {
        // This is the max value of u64 minus the current managed_assets. Ensures that the sum will always be lower than u64::MAX.
        Option::Some(u64::MAX - managed_assets(asset))
    }

    #[storage(read)]
    fn max_withdrawable(asset: AssetId, sub_id: SubId) -> Option<u64> {
        // In this implementation total_assets and max_withdrawable are the same. However in case of lending out of assets, total_assets should be greater than max_withdrawable.
        Option::Some(managed_assets(asset))
    }

    #[storage(read)]
    fn vault_asset_id(asset: AssetId, sub_id: SubId) -> Option<(AssetId, SubId)> {
        Some(vault_asset_id(asset, sub_id))
    }

    #[storage(read)]
    fn asset_of_vault(vault_asset_id: AssetId) -> Option<(AssetId, SubId)> {
        let vault_info = storage.vault_info.get(vault_asset_id).read();
        Some((vault_info.asset, vault_info.sub_id))
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

/// Returns the vault shares assetid and subid for the given assets assetid and the vaults sub id
fn vault_asset_id(asset: AssetId, sub_id: SubId) -> (AssetId, SubId) {
    let share_asset_sub_id = sha256((asset.into(), sub_id));
    let share_asset_id = AssetId::new(ContractId::this(), share_asset_sub_id);
    (share_asset_id, share_asset_sub_id)
}

#[storage(read)]
fn managed_assets(share_asset: AssetId) -> u64 {
    storage.vault_info.get(share_asset).read().managed_assets
}

#[storage(read)]
fn preview_deposit(asset: AssetId, sub_id: SubId, assets: u64) -> (u64, AssetId, SubId) {
    let (share_asset_id, share_asset_sub_id) = vault_asset_id(asset, sub_id);

    let shares_supply = storage.total_supply.get(share_asset_id).read();
    if shares_supply == 0 {
        (assets, share_asset_id, share_asset_sub_id)
    } else {
        (
            assets * shares_supply / managed_assets(share_asset_id),
            share_asset_id,
            share_asset_sub_id,
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
    sub_id: SubId,
    amount: u64,
) {
    use std::token::mint_to;

    let supply = storage.total_supply.get(asset_id).try_read();
    // Only increment the number of assets minted by this contract if it hasn't been minted before.
    if supply.is_none() {
        storage.total_assets.write(storage.total_assets.read() + 1);
    }
    let current_supply = supply.unwrap_or(0);
    storage.total_supply.insert(asset_id, current_supply + amount);
    mint_to(recipient, sub_id, amount);
}

#[storage(read, write)]
pub fn _burn(asset_id: AssetId, sub_id: SubId, amount: u64) {
    use std::{context::this_balance, token::burn};

    require(this_balance(asset_id) >= amount, "BurnError::NotEnoughTokens");
    // If we pass the check above, we can assume it is safe to unwrap.
    let supply = storage.total_supply.get(asset_id).try_read().unwrap();
    storage.total_supply.insert(asset_id, supply - amount);
    burn(sub_id, amount);
}
