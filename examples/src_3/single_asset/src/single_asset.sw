contract;

use src_3::SRC3;
use src_20::SRC20;
use std::{
    call_frames::{
        contract_id,
        msg_asset_id,
    },
    constants::ZERO_B256,
    context::msg_amount,
    string::String,
    token::{
        burn,
        mint_to,
    },
};

configurable {
    /// The decimals of the asset minted by this contract.
    DECIMALS: u8 = 9u8,
    /// The name of the asset minted by this contract.
    NAME: str[7] = __to_str_array("MyToken"),
    /// The symbol of the asset minted by this contract.
    SYMBOL: str[5] = __to_str_array("MYTKN"),
}

storage {
    /// The total supply of the asset minted by this contract.
    total_supply: u64 = 0,
}

impl SRC3 for Contract {
    /// Unconditionally mints new tokens using the default SubId.
    ///
    /// # Arguments
    ///
    /// * `recipient`: [Identity] - The user to which the newly minted tokens are transferred to.
    /// * `sub_id`: [SubId] - The default SubId.
    /// * `amount`: [u64] - The quantity of tokens to mint.
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
    /// use std::constants::ZERO_B256;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SR3, contract);
    ///     contract_abi.mint(Identity::ContractId(contract_id), ZERO_B256, 100);
    /// }
    /// ```
    #[storage(read, write)]
    fn mint(recipient: Identity, sub_id: SubId, amount: u64) {
        require(sub_id == ZERO_B256, "Incorrect Sub Id");

        // Increment total supply of the asset and mint to the recipient.
        storage.total_supply.write(amount + storage.total_supply.read());
        mint_to(recipient, ZERO_B256, amount);
    }

    /// Unconditionally burns tokens sent with the default SubId.
    ///
    /// # Arguments
    ///
    /// * `sub_id`: [SubId] - The default SubId.
    /// * `amount`: [u64] - The quantity of tokens to burn.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `1`
    ///
    /// # Reverts
    ///
    /// * When the `sub_id` is not the default SubId.
    /// * When the transaction did not include at least `amount` tokens.
    /// * When the transaction did not include the asset minted by this contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    /// use std::constants::ZERO_B256;
    ///
    /// fn foo(contract_id: ContractId, asset_id: AssetId) {
    ///     let contract_abi = abi(SR3, contract_id);
    ///     contract_abi {
    ///         gas: 10000,
    ///         coins: 100,
    ///         asset_id: asset_id,
    ///     }.burn(ZERO_B256, 100);
    /// }
    /// ```
    #[storage(read, write)]
    fn burn(sub_id: SubId, amount: u64) {
        require(sub_id == ZERO_B256, "Incorrect Sub Id");
        require(msg_amount() >= amount, "Incorrect amount provided");
        require(msg_asset_id() == AssetId::default(contract_id()), "Incorrect asset provided");

        // Decrement total supply of the asset and burn.
        storage.total_supply.write(storage.total_supply.read() - amount);
        burn(ZERO_B256, amount);
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
        if asset == AssetId::default(contract_id()) {
            Some(storage.total_supply.read())
        } else {
            None
        }
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
