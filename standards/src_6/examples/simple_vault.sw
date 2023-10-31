contract;

use std::{
    auth::msg_sender,
    call_frames::msg_asset_id,
    context::msg_amount,
    hash::Hash,
    storage::{
        storage_map::*,
        storage_string::StorageString,
    },
    token::{
        burn,
        mint,
        transfer,
    },
};

use src_6::{Deposit, SRC6, Withdraw};
use src_20::SRC20;
use std::string::String;

storage {
    total_assets: u64 = 0,
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    decimals: StorageMap<AssetId, u8> = StorageMap {},
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

impl SRC6 for Contract {
    #[storage(read)]
    fn managed_assets(asset: AssetId) -> u64 {
        managed_assets(asset) // In this implementation managed_assets and max_withdrawable are the same. However in case of lending out of assets, managed_assets should be greater than max_withdrawable.
    }

    #[storage(read, write)]
    fn deposit(receiver: Identity) -> u64 {
        let assets = msg_amount();
        let asset = msg_asset_id();
        let shares = preview_deposit(asset, assets);
        require(assets != 0, "ZERO_ASSETS");

        let _ = _mint(receiver, asset.into(), shares); // Using the asset_id as the sub_id for shares.
        storage.total_supply.insert(asset, storage.total_supply.get(asset).read() + shares);
        after_deposit();

        log(Deposit {
            caller: msg_sender().unwrap(),
            receiver: receiver,
            asset: asset,
            assets: assets,
            shares: shares,
        });

        shares
    }

    #[storage(read, write)]
    fn withdraw(asset: AssetId, receiver: Identity) -> u64 {
        let shares = msg_amount();
        require(shares != 0, "ZERO_SHARES");
        require(msg_asset_id() == AssetId::new(ContractId::this(), asset.into()), "INVALID_ASSET_ID");
        let assets = preview_withdraw(asset, shares);

        _burn(asset.into(), shares);
        storage.total_supply.insert(asset, storage.total_supply.get(asset).read() - shares);
        after_withdraw();

        transfer(receiver, asset, assets);

        log(Withdraw {
            caller: msg_sender().unwrap(),
            receiver: receiver,
            asset: asset,
            assets: assets,
            shares: shares,
        });

        assets
    }

    #[storage(read)]
    fn convert_to_shares(asset: AssetId, assets: u64) -> Option<u64> {
        Option::Some(preview_deposit(asset, assets))
    }

    #[storage(read)]
    fn convert_to_assets(asset: AssetId, shares: u64) -> Option<u64> {
        Option::Some(preview_withdraw(asset, shares))
    }

    #[storage(read)]
    fn max_depositable(asset: AssetId) -> Option<u64> {
        Option::Some(18_446_744_073_709_551_615 - managed_assets(asset)) // This is the max value of u64 minus the current managed_assets. Ensures that the sum will always be lower than u64::MAX.
    }

    #[storage(read)]
    fn max_withdrawable(asset: AssetId) -> Option<u64> {
        Option::Some(managed_assets(asset)) // In this implementation total_assets and max_withdrawable are the same. However in case of lending out of assets, total_assets should be greater than max_withdrawable.
    }
}

fn managed_assets(asset: AssetId) -> u64 {
    std::context::this_balance(asset)
}

#[storage(read)]
fn preview_deposit(asset: AssetId, assets: u64) -> u64 {
    let shares_supply = storage.total_supply.get(AssetId::new(ContractId::this(), asset.into())).read();
    if shares_supply == 0 {
        assets
    } else {
        assets * shares_supply / managed_assets(asset)
    }
}

#[storage(read)]
fn preview_withdraw(asset: AssetId, shares: u64) -> u64 {
    let supply = storage.total_supply.get(AssetId::new(ContractId::this(), asset.into())).read();
    if supply == shares {
        managed_assets(asset)
    } else {
        shares * (managed_assets(asset) / supply)
    }
}

fn after_deposit() {
    // Does nothing, only for demonstration purposes.
}

fn after_withdraw() {
    // Does nothing, only for demonstration purposes.
}

#[storage(read, write)]
pub fn _mint(recipient: Identity, sub_id: SubId, amount: u64) -> AssetId {
    let asset_id = AssetId::new(contract_id(), sub_id);
    let supply = storage.total_supply.get(asset).try_read();
    // Only increment the number of assets minted by this contract if it hasn't been minted before.
    if supply.is_none() {
        storage.total_assets.write(_total_assets(storage.total_assets) + 1);
    }
    let current_supply = supply.unwrap_or(0);
    storage.total_supply.insert(asset_id, current_supply + amount);
    mint_to(recipient, sub_id, amount);
    asset_id
}

#[storage(read, write)]
pub fn _burn(sub_id: SubId, amount: u64) {
    let asset_id = AssetId::new(contract_id(), sub_id);
    require(this_balance(asset_id) >= amount, BurnError::NotEnoughTokens);
    // If we pass the check above, we can assume it is safe to unwrap.
    let supply = storage.total_supply.get(asset).try_read().unwrap();
    storage.total_supply.insert(asset_id, supply - amount);
    burn(sub_id, amount);
}
