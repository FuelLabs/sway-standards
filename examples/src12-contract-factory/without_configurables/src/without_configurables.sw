contract;

use standards::src12::*;
use std::{external::bytecode_root, hash::Hash,};

configurable {
    TEMPLATE_BYTECODE_ROOT: b256 = b256::zero(),
}

storage {
    /// Contracts that have registered with this contract.
    registered_contracts: StorageMap<ContractId, bool> = StorageMap {},
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
    /// * Writes: `1`
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
        if configurables.is_some() {
            return Result::Err(
                "This SRC-12 implementation only registers contracts without configurable values",
            );
        }

        let returned_root = bytecode_root(child_contract);
        if returned_root != TEMPLATE_BYTECODE_ROOT {
            return Result::Err(
                "The deployed contract's bytecode root and template contract bytecode root do not match",
            );
        }

        storage.registered_contracts.insert(child_contract, true);
        return Result::Ok(returned_root)
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
