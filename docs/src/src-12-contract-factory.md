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
{{#include ../examples/src12-contract-factory/with_configurables/src/with_configurables.sw}}
```

### Without Configurables

Example of the SRC-12 implementation where all contract deployments are identical and thus have the same bytecode and root.

```sway
{{#include ../examples/src12-contract-factory/without_configurables/src/without_configurables.sw}}
```
