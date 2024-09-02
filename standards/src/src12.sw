library;

use std::{alloc::alloc_bytes, bytes::Bytes, hash::{Hash, Hasher}};

pub type BytecodeRoot = b256;
pub type ContractConfigurables = Vec<(u64, Vec<u8>)>;

abi SRC12 {
    /// Verifies that a newly deployed contract is the child of a contract factory and registers it.
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
    /// # Examples
    ///
    /// ```sway
    /// use standards::src12::SRC12;
    ///
    /// fn foo(src_12_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_12_contract_abi = abi(SRC12, src_12_contract.bits());
    ///     let result = src_12_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///     assert(result.is_ok());
    ///     assert(src_12_contract_abi.is_valid(my_deployed_contract));
    /// }
    /// ```
    #[storage(read, write)]
    fn register_contract(
        child_contract: ContractId,
        configurables: Option<ContractConfigurables>,
    ) -> Result<BytecodeRoot, str>;

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
    /// # Examples
    ///
    /// ```sway
    /// use standards::src12::SRC12;
    ///
    /// fn foo(src_12_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_12_contract_abi = abi(SRC12, src_12_contract.bits());
    ///     let _ = src_12_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///
    ///     let result: bool = src_12_contract_abi.is_valid(my_deployed_contract)
    ///     assert(result);
    /// }
    /// ```
    #[storage(read)]
    fn is_valid(child_contract: ContractId) -> bool;

    /// Returns the bytecode root of the default template contract.
    ///
    /// # Returns
    ///
    /// * [Option<BytecodeRoot>] - The bytecode root of the default template contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src12::SRC12;
    ///
    /// fn foo(src_12_contract: ContractId) {
    ///     let src_12_contract_abi = abi(SRC12, src_12_contract.bits());
    ///     let root: Option<BytecodeRoot> = src_12_contract_abi.factory_bytecode_root();
    ///     assert(root.unwrap() != b256::zero());
    /// }
    /// ```
    #[storage(read)]
    fn factory_bytecode_root() -> Option<BytecodeRoot>;
}

abi SRC12_Extension {
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
    /// # Examples
    ///
    /// ```sway
    /// use standards::src12::SRC12;
    ///
    /// fn foo(src_12_contract: ContractId, my_deployed_contract: ContractId, my_configurables: Option<ContractConfigurables>) {
    ///     let src_12_contract_abi = abi(SRC12, src_12_contract.bits());
    ///     let _ = src_12_contract_abi.register_contract(my_deployed_contract, my_configurables);
    ///
    ///     let result_contract_id: Option<ContractId> = src_12_contract_abi.get_contract_id(my_configurables);
    ///     assert(result_contract_id.unwrap() == my_deployed_contract);
    /// }
    /// ```
    #[storage(read)]
    fn get_contract_id(configurables: Option<ContractConfigurables>) -> Option<ContractId>;
}

impl Hash for ContractConfigurables {
    fn hash(self, ref mut state: Hasher) {
        // Iterate over every configurable
        let mut configurable_iterator = 0;
        while configurable_iterator < self.len() {
            let (offset, data) = self.get(configurable_iterator).unwrap();
            let buffer = alloc_bytes(data.len() + 4);
            let offset_ptr = asm(input: offset) {
                input: raw_ptr
            };

            // Overwrite the configurable data into the buffer
            offset_ptr.copy_bytes_to(buffer, 4);
            data.ptr().copy_bytes_to(buffer.add::<u8>(4), data.len());

            state.write(Bytes::from(raw_slice::from_parts::<u8>(buffer, data.len() + 4)));
            configurable_iterator += 1;
        }
    }
}
