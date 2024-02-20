library;

abi SRC11 {
     #[storage(read, write)]
     fn register_contract(child_contract: ContractId, configurables: Option<Vec<(u64, Vec<u8>)>>);
     #[storage(read)]
     fn is_valid(child_contract: ContractId) -> bool;
     #[storage(read)]
     fn factory_bytecode_root() -> Option<b256>;
     #[storage(read)]
     fn get_contract_id(configurables: Option<Vec<(u64, Vec<u8>)>>) -> Option<ContractId>;
}
