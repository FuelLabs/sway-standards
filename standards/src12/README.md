# SRC-12: Contract Factory

The following standard allows for the implementation of a standard ABI for Contract Factories using the Sway Language. The standardized design designates how verification of newly deployed child contracts are handled.

## Motivation

A standard interface for Contract Factories provides a safe and effective method of ensuring contracts can verify the validity of another contract as a child of a factory. This is critical on the Fuel Network as contracts cannot deploy other contracts and verification must be done after deployment.

## Prior Art

A Contract Factory is a design where a template contract is used and deployed repeatedly with different configurations. These configurations are often minor changes such as pointing to a different asset. All base functionality remains the same.

On Fuel, contracts cannot deploy other contracts. As a result, a Contract Factory on Fuel must register and verify that the bytecode root of a newly deployed child contract matches the expected bytecode root.

When changing something such as a configurable in Sway, the bytecode root is recalculated. The [Bytecode Library](https://docs.fuel.network/docs/sway-libs/bytecode/) has been developed to calculate the bytecode root of a contract with different configurables.

## Specification

The following functions MUST be implemented to follow the SRC-12; Contract Factory Standard:

### Required Functions

#### `fn register_contract(child_contract: ContractId, configurables: Option<Vec<(u64, Vec<u8>)>>) -> Result<b256, str>`

The `register_contract()` function verifies that a newly deployed contract is the child of a contract factory.

- This function MUST verify that the bytecode root of the `child_contract` contract matches the expected bytecode root.
- This function MUST calculate the bytecode root IF `configurables` is `Some`.
- This function MUST not revert.
- This function MUST return a `Result` containing the `b256` bytecode root of the newly registered contract or an `str` error message.
- This function MAY add arbitrary conditions checking a contract factory child’s validity, such as verifying storage variables or initialized values.

#### `fn is_valid(child_contract: ContractId) -> bool`

The `is_valid()` function returns a boolean representing the state of whether a contract is registered as a valid child of the contract factory.

- This function MUST return `true` if this is a valid and registered child, otherwise `false`.

#### `fn factory_bytecode_root() -> Option<b256>`

The `factory_bytecode_root()` function returns the bytecode root of the default template contract.

- This function MUST return the bytecode root of the template contract.

### Optional Functions

The following are functions that may enhance the use of the SRC-12 standard but ARE NOT required.

#### `fn get_contract_id(configurables: Option<Vec<(u64, Vec<u8>)>>) -> Option<ContractId>`

The `get_contract_id()` function returns a registered contract factory child contract with specific implementation details specified by `configurables`.

This function MUST return `Some(ContractId)` IF a contract that follows the specified `configurables` has been registered with the SRC-12 Contract Factory contract, otherwise `None`.

## Rationale

The SRC-12; Contract Factory Standard is designed to standardize the contract factory design implementation interface between all Fuel instances.

## Backwards Compatibility

There are no other standards that the SRC-12 requires compatibility.

## Security Considerations

This standard takes into consideration child contracts that are deployed with differentiating configurable values, however individual contract behaviours may be dependent on storage variables. As storage variables may change after the contract has been registered with the SRC-12 compliant contract, the standard suggests to check these values upon registration however it is not enforced.

## Example ABI

```sway
abi SRC12 {
    #[storage(read, write)]
    fn register_contract(child_contract: ContractId, configurables: Option<Vec<(u64, Vec<u8>)>>) -> Result<b256, str>;
    #[storage(read)]
    fn is_valid(child_contract: ContractId) -> bool;
    #[storage(read)]
    fn factory_bytecode_root() -> Option<b256>;
}

abi SRC12_Extension {
    #[storage(read)]
    fn get_contract_id(configurables: Option<Vec<(u64, Vec<u8>)>>) -> Option<ContractId>;
}
```

## Example Implementation

### With Configurables

Example of the SRC-12 implementation where contract deployments contain configurable values that differentiate the bytecode root from other contracts with the same bytecode.

```sway
contract;

mod utils;

use utils::{_compute_bytecode_root, _swap_configurables};
use src12::*;
use std::{external::bytecode_root, hash::{Hash, sha256}, storage::storage_vec::*};

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
```

### Without Configurables

Example of the SRC-12 implementation where all contract deployments are identical and thus have the same bytecode and root.

```sway
contract;

use src12::*;
use std::{external::bytecode_root, hash::Hash};

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
```
