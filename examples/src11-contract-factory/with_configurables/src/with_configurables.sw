contract;

mod bytecode;

use bytecode::{_compute_bytecode_root, _swap_configurables};
use src11::*;
use std::{
    constants::ZERO_B256,
    external::bytecode_root,
    hash::{
        Hash,
        sha256,
    },
    storage::storage_vec::*,
};

configurable {
    TEMPLATE_BYTECODE_ROOT: b256 = ZERO_B256,
}

storage {
    /// Contracts that have registered with this contract.
    registered_contracts: StorageMap<ContractId, bool> = StorageMap {},
    /// Maps the hash digest of configurables to the contract id.
    contract_configurables: StorageMap<b256, ContractId> = StorageMap {},
    /// The template contract's bytecode
    bytecode: StorageVec<u8> = StorageVec {},
}

abi MyRegistryContract {
    #[storage(read, write)]
    fn set_bytecode(bytecode: Vec<u8>);
}

impl MyRegistryContract for Contract {
    /// Special helper function to store the template contract's bytecode
    ///
    /// # Additional Information
    ///
    /// Real world implementations should apply restrictions on this function such that it cannot
    /// be change by anyone or only once.
    #[storage(read, write)]
    fn set_bytecode(bytecode: Vec<u8>) {
        storage.bytecode.store_vec(bytecode);
    }
}

impl SRC11 for Contract {
    /// Verifies that a newly deployed contract is the child of a contract factory and registers it.
    ///
    /// # Additional Information
    ///
    /// This example does not check whether a contract has already been registered and will overwrite any values.
    ///
    /// # Arguments
    ///
    /// * `child_contract`: [ContractId] - The deployed factory child contract which to verify the bytecode root.
    /// * `configurables`: [Option<ContractConfigurables>] - The configurables value set for the `child_contract`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Writes: `2`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src11::SRC11;
    ///
    /// fn foo(my_src_11_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_11_contract_abi = abi(SRC11, my_src_11_contract.bits());
    ///     src_11_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///     assert(src_11_contract_abi.is_valid(my_deployed_contract));
    /// }
    /// ```
    #[storage(read, write)]
    fn register_contract(
        child_contract: ContractId,
        configurables: Option<ContractConfigurables>,
    ) {
        let returned_root = bytecode_root(child_contract);

        // If there are no configurables just use the default template
        let computed_root = match configurables {
            Some(config) => {
                let bytecode = storage.bytecode.load_vec();
                compute_bytecode_root(bytecode, config)
            },
            None => {
                TEMPLATE_BYTECODE_ROOT
            }
        };

        // Verify the roots match
        require(
            returned_root == computed_root,
            "The deployed contract's bytecode root and expected contract bytecode root do not match",
        );

        storage.registered_contracts.insert(child_contract, true);
        storage
            .contract_configurables
            .insert(sha256(configurables.unwrap_or(Vec::new())), child_contract);
    }

    /// Returns a boolean representing the state of whether a contract is a valid child of the contract factory.
    ///
    /// # Arguments
    ///
    /// * `child_contract`: [ContractId] - The deployed factory child contract which to check the registry status.
    ///
    /// # Returns
    ///
    /// * [bool] - `true` if the contract has registered and is valid, otherwise `false`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src11::SRC11;
    ///
    /// fn foo(my_src_11_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_11_contract_abi = abi(SRC11, my_src_11_contract.bits());
    ///     src_11_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///     assert(src_11_contract_abi.is_valid(my_deployed_contract));
    /// }
    /// ```
    #[storage(read)]
    fn is_valid(child_contract: ContractId) -> bool {
        storage.registered_contracts.get(child_contract).try_read().unwrap_or(false)
    }

    /// Returns the bytecode root of the default template contract.
    ///
    /// # Returns
    ///
    /// * [Option<b256>] - The bytecode root of the default template contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src11::SRC11;
    /// use std::constants::ZERO_B256;
    ///
    /// fn foo(my_src_11_contract: ContractId) {
    ///     let src_11_contract_abi = abi(SRC11, my_src_11_contract.bits());
    ///     let root = src_11_contract_abi.factory_bytecode_root();
    ///     assert(root.unwrap() != ZERO_B256);
    /// }
    /// ```
    #[storage(read)]
    fn factory_bytecode_root() -> Option<b256> {
        Some(TEMPLATE_BYTECODE_ROOT)
    }
}

impl SRC11_Extension for Contract {
    /// Return a registered contract factory child contract with specific implementation details specified by it's configurables.
    ///
    /// # Arguments
    ///
    /// * `configurables`: [Option<ContractConfigurables>] - The configurables value set for the `child_contract`.
    ///
    /// # Returns
    ///
    /// * [Option<ContractId>] - The id of the contract which has registered with the specified configurables.
    ///
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src11::SRC11;
    ///
    /// fn foo(my_src_11_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_11_contract_abi = abi(SRC11, my_src_11_contract.bits());
    ///     src_11_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///     let result_contract_id = src_11_contract_abi.get_contract_id(my_configurables);
    ///     assert(result_contract_id.unwrap() == my_deployed_contract);
    /// }
    /// ```
    #[storage(read)]
    fn get_contract_id(configurables: Option<ContractConfigurables>) -> Option<ContractId> {
        storage.contract_configurables.get(sha256(configurables.unwrap_or(Vec::new()))).try_read()
    }
}

/// This function is copied and can be imported from the Sway Libs Bytecode Library.
/// https://github.com/FuelLabs/sway-libs/tree/master/libs/bytecode
fn compute_bytecode_root(bytecode: Vec<u8>, configurables: Vec<(u64, Vec<u8>)>) -> b256 {
    let mut bytecode_slice = bytecode.as_raw_slice();
    _swap_configurables(bytecode_slice, configurables);
    _compute_bytecode_root(bytecode_slice)
}
