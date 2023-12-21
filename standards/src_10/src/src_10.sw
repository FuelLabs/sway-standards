library;

/// Enscapsultes metadata sent between the canonical chain and Fuel.
struct MessageData {
    /// The number of tokens.
    amount: b256,
    /// The user's address on the canonical chain.
    from: b256,
    /// The number of deposit messages.
    len: u16,
    /// The bridging target destination on the Fuel chain.
    to: Identity,
    /// The bridged token's address on the canonical chain.
    token_address: b256,
    /// The token's ID on the canonical chain.
    token_id: Option<b256>,
}

abi SRC10 {
    /// Compiles a message to be sent back to the canonical chain.
    ///
    /// # Additional Information
    ///
    /// * The `gateway` contract on the canonical chain receives the `token` ID in the message such that when assets are deposited they are reported to prevent loss of funds.
    ///
    /// # Arguments
    ///
    /// * `token_address`: [b256] - The token's address on the canonical chain.
    /// * `gateway_contract`: [b256] - The contract that accepts deposits on the canonical chain.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src10::SRC10;
    ///
    /// fn foo(gateway_contract: b256, token_address: b256, bridge: ContractId) {
    ///     let bridge_abi = abi(SRC10, bridge.value);
    ///     bridge_abi.register_bridge(token_address, gateway_contract);
    /// }
    /// ```
    #[storage(read, write)]
    fn register_bridge(token_address: b256, gateway_contract: b256);

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
    /// fn foo(to_address: b256, asset_sub_id: SubId, gateway_contract: b256, bridge: ContractId, bridged_asset: AssetId) {
    ///     let bridge_abi = abi(SRC10, bridge.value);
    ///     bridge_abi {
    ///         gas: 10000,
    ///         coins: 100,
    ///         asset_id: bridged_asset,
    ///     }.withdraw(to_address, asset_sub_id, gateway_contract);
    /// }
    /// ```
    #[storage(read, write)]
    fn withdraw(to_address: b256, sub_id: SubId, gateway_contract: b256);

    /// Returns a refund on the canonical chain if an error occurs while bridging.
    ///
    /// # Arguments
    ///
    /// * `to_address`: [b256] - The address on the canonical chain to send the refunded tokens to.
    /// * `token_address`: [b256] - The token on the canonical chain to be refunded.
    /// * `token_id`: [Option<b256>] - The token id of the token on the canonical chain to be refunded.
    /// * `gateway_contract`: [b256] - The contract that holds the deposited tokens on the canonical chain.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src10::SRC10;
    ///
    /// fn foo(to_address: b256, token_address: b256, token_id: Option<b256>, gateway_contract: b256, bridge: ContractId) {
    ///     let bridge_abi = abi(SRC10, bridge.value);
    ///     bridge_abi.claim_refund(to_address, token_address, token_id, gateway_contract);
    /// }
    /// ```
    #[storage(read, write)]
    fn claim_refund(to_address: b256, token_address: b256, token_id: Option<b256>, gateway_contract: b256);
}
