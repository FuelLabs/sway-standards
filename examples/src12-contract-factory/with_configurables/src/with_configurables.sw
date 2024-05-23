contract;

mod utils;

use utils::{_compute_bytecode_root, _swap_configurables};
use standards::src12::*;
use std::{external::bytecode_root, hash::{Hash, sha256,}, storage::storage_vec::*,};

configurable {
    TEMPLATE_BYTECODE_ROOT: b256 = b256::zero(),
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
    /// be changed by anyone or can only be changed once.
    #[storage(read, write)]
    fn set_bytecode(bytecode: Vec<u8>) {
        storage.bytecode.store_vec(bytecode);
    }
}

impl SRC12 for Contract {
    /// Verifies that a newly deployed contract is the child of a contract factory and registers it.
    ///
    /// # Additional Information
    ///
    /// This example does not check whether a contract has already been registered and will overwrite any values.
    ///
    /// # Arguments
    ///
    /// * `child_contract`: [ContractId] - The deployed factory child contract of which to verify the bytecode root.
    /// * `configurables`: [Option<ContractConfigurables>] - The configurables value set for the `child_contract`.
    ///
    /// # Returns
    ///
    /// * [Result<BytecodeRoot, str>] - Either the bytecode root of the newly registered contract or a `str` error message.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Writes: `2`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src12::SRC12;
    ///
    /// fn foo(my_src_12_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_12_contract_abi = abi(SRC12, my_src_12_contract.bits());
    ///     src_12_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///     assert(src_12_contract_abi.is_valid(my_deployed_contract));
    /// }
    /// ```
    #[storage(read, write)]
    fn register_contract(
        child_contract: ContractId,
        configurables: Option<ContractConfigurables>,
    ) -> Result<BytecodeRoot, str> {
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
        if returned_root != computed_root {
            return Result::Err(
                "The deployed contract's bytecode root and expected contract bytecode root do not match",
            );
        }

        storage.registered_contracts.insert(child_contract, true);
        storage
            .contract_configurables
            .insert(sha256(configurables.unwrap_or(Vec::new())), child_contract);

        return Result::Ok(computed_root)
    }

    /// Returns a boolean representing the state of whether a contract is a valid child of the contract factory.
    ///
    /// # Arguments
    ///
    /// * `child_contract`: [ContractId] - The deployed factory child contract of which to check the registry status.
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
    /// use src12::SRC12;
    ///
    /// fn foo(my_src_12_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_12_contract_abi = abi(SRC12, my_src_12_contract.bits());
    ///     src_12_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///     assert(src_12_contract_abi.is_valid(my_deployed_contract));
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
    /// * [Option<BytecodeRoot>] - The bytecode root of the default template contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src12::SRC12;
    ///
    /// fn foo(my_src_12_contract: ContractId) {
    ///     let src_12_contract_abi = abi(SRC12, my_src_12_contract.bits());
    ///     let root = src_12_contract_abi.factory_bytecode_root();
    ///     assert(root.unwrap() != b256::zero());
    /// }
    /// ```
    #[storage(read)]
    fn factory_bytecode_root() -> Option<BytecodeRoot> {
        Some(TEMPLATE_BYTECODE_ROOT)
    }
}

impl SRC12_Extension for Contract {
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
    /// use src12::SRC12_Extension;
    ///
    /// fn foo(my_src_12_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_12_contract_abi = abi(SRC12_Extension, my_src_12_contract.bits());
    ///     src_12_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///     let result_contract_id = src_12_contract_abi.get_contract_id(my_configurables);
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
