library;

/// Specifies the type of deposit made.
pub enum DepositType {
    /// The deposit was made to an Address.
    Address: (),
    /// The deposit was made to a Contract.
    Contract: (),
    /// The deposit was made to a Contract and contains additioanl data for the Fuel chain.
    ContractWithData: (),
}

/// Enscapsultes metadata sent between the canonical chain and Fuel when a deposit is made.
struct DepositMessage {
    /// The number of tokens.
    pub amount: b256,
    /// The user's address on the canonical chain.
    pub from: b256,
    /// The bridging target destination on the Fuel chain.
    pub to: Identity,
    /// The bridged token's address on the canonical chain.
    pub token_address: b256,
    /// The token's ID on the canonical chain.
    pub token_id: b256,
    /// The decimals of the token.
    pub decimals: u8,
    /// The type of deposit made.
    pub deposit_type: DepositType,
}

pub struct MetadataMessage {
    /// The bridged token's address on the canonical chain.
    pub token_address: b256,
    /// The token's ID on the canonical chain.
    pub token_id: b256,
    /// The bridged token's name on the canonical chain.
    pub name: String,
    /// The bridged token's symbol on the canonical chain.
    pub symbol: String,
}

abi SRC10 {
    /// Accepts incoming deposit messages from the canonical chain and issues the corresponding bridged asset.
    ///
    /// # Arguments
    ///
    /// * `message_index`: [u64] - The index of the message to parse.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src10::SRC10;
    ///
    /// fn foo(message_index: u64, bridge: ContractId) {
    ///     let bridge_abi = abi(SRC10, bridge.value);
    ///     bridge_abi.process_message(message_index);
    /// }
    /// ```
    #[storage(read, write)]
    fn process_message(message_index: u64);

    /// Accepts and burns a bridged asset and sends a messages to the canonical chain to release the original deposited token.
    ///
    /// # Arguments
    ///
    /// * `to_address`: [b256] - The address on the canonical chain to send the released tokens to.
    /// * `sub_id`: [SubId] - The SubId of the asset sent in the transaction.
    /// * `gateway_contract`: [b256] - The contract that holds the deposited tokens on the canonical chain.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src10::SRC10;
    ///
    /// fn foo(to_address: b256, bridge: ContractId, bridged_asset: AssetId) {
    ///     let bridge_abi = abi(SRC10, bridge.value);
    ///     bridge_abi {
    ///         gas: 10000,
    ///         coins: 100,
    ///         asset_id: bridged_asset,
    ///     }.withdraw(to_address);
    /// }
    /// ```
    #[storage(read, write)]
    fn withdraw(to_address: b256);

    /// Returns a refund on the canonical chain if an error occurs while bridging.
    ///
    /// # Arguments
    ///
    /// * `to_address`: [b256] - The address on the canonical chain to send the refunded tokens to.
    /// * `token_address`: [b256] - The token on the canonical chain to be refunded.
    /// * `token_id`: [b256] - The token id of the token on the canonical chain to be refunded.
    /// * `gateway_contract`: [b256] - The contract that holds the deposited tokens on the canonical chain.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src10::SRC10;
    ///
    /// fn foo(to_address: b256, token_address: b256, token_id: b256, gateway_contract: b256, bridge: ContractId) {
    ///     let bridge_abi = abi(SRC10, bridge.value);
    ///     bridge_abi.claim_refund(to_address, token_address, token_id, gateway_contract);
    /// }
    /// ```
    #[storage(read, write)]
    fn claim_refund(
        to_address: b256,
        token_address: b256,
        token_id: b256,
        gateway_contract: b256,
    );
}
