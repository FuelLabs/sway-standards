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
    src20::SRC20,
    src6::{
        Deposit,
        SetDecimalsEvent,
        SetNameEvent,
        SetSymbolEvent,
        SRC6,
        TotalSupplyEvent,
        Withdraw,
    },
};

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
            Some(String::from_ascii_str("Vault Shares"))
        } else {
            None
        }
    }

    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        if asset == vault_assetid() {
            Some(String::from_ascii_str("VLTSHR"))
        } else {
            None
        }
    }

    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        if asset == vault_assetid() {
            Some(9_u8)
        } else {
            None
        }
    }
}

abi SetSRC20Data {
    #[storage(read)]
    fn set_src20_data(
        asset: AssetId,
        name: Option<String>,
        symbol: Option<String>,
        decimals: u8,
    );
}

impl SetSRC20Data for Contract {
    #[storage(read)]
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

        SetNameEvent::new(asset, name, sender).log();
        SetSymbolEvent::new(asset, symbol, sender).log();
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
    storage.total_supply.write(supply + amount);
    mint_to(recipient, PRE_CALCULATED_SHARE_VAULT_SUB_ID, amount);
    TotalSupplyEvent::new(
        vault_assetid(),
        storage
            .total_supply
            .read(),
        msg_sender()
            .unwrap(),
    )
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
    storage.total_supply.write(supply - amount);
    burn(PRE_CALCULATED_SHARE_VAULT_SUB_ID, amount);
    TotalSupplyEvent::new(
        vault_assetid(),
        storage
            .total_supply
            .read(),
        msg_sender()
            .unwrap(),
    )
        .log();
}
