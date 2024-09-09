library;

use std::string::String;

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
pub struct DepositMessage {
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
    /// use standards::src10::SRC10;
    ///
    /// fn foo(message_index: u64, bridge: ContractId) {
    ///     let bridge_abi = abi(SRC10, bridge.bits());
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
    /// use standards::src10::SRC10;
    ///
    /// fn foo(to_address: b256, bridge: ContractId, bridged_asset: AssetId) {
    ///     let bridge_abi = abi(SRC10, bridge.bits());
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
    /// use standards::src10::SRC10;
    ///
    /// fn foo(to_address: b256, token_address: b256, token_id: b256, gateway_contract: b256, bridge: ContractId) {
    ///     let bridge_abi = abi(SRC10, bridge.bits());
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

impl core::ops::Eq for DepositType {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Self::Address, Self::Address) => true,
            (Self::Contract, Self::Contract) => true,
            (Self::ContractWithData, Self::ContractWithData) => true,
            _ => false,
        }
    }
}

impl core::ops::Eq for DepositMessage {
    fn eq(self, other: Self) -> bool {
        self.amount == other.amount && self.from == other.from && self.to == other.to && self.token_address == other.token_address && self.token_id == other.token_id && self.decimals == other.decimals && self.deposit_type == other.deposit_type
    }
}

impl core::ops::Eq for MetadataMessage {
    fn eq(self, other: Self) -> bool {
        self.token_address == other.token_address && self.token_id == other.token_id && self.name == other.name && self.symbol == other.symbol
    }
}

impl DepositMessage {
    /// Returns a new `DepositMessage`.
    ///
    /// # Arguments
    ///
    /// * `amount`: [b256] - The number of tokens.
    /// * `from`: [b256] - The user's address on the canonical chain.
    /// * `to`: [Identity] - The bridging target destination on the Fuel chain.
    /// * `token_address`: [b256] - The bridged token's address on the canonical chain.
    /// * `token_id`: [b256] - The token's ID on the canonical chain.
    /// * `decimals`: [u8] - The decimals of the token.
    /// * `deposit_type`: [DepositType] - The type of deposit made.
    ///
    /// # Returns
    ///
    /// * [DepositMessage] - The newly created `DepositMessage`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.amount == amount);
    ///     assert(deposit_message.from == from);
    ///     assert(deposit_message.to == to);
    ///     assert(deposit_message.token_address == token_address);
    ///     assert(deposit_message.token_id == token_id);
    ///     assert(deposit_message.decimals == decimals);
    ///     assert(deposit_message.deposit_type == deposit_type);
    /// }
    /// ```
    pub fn new(
        amount: b256,
        from: b256,
        to: Identity,
        token_address: b256,
        token_id: b256,
        decimals: u8,
        deposit_type: DepositType,
    ) -> Self {
        Self {
            amount,
            from,
            to,
            token_address,
            token_id,
            decimals,
            deposit_type,
        }
    }

    /// Returns the `amount` of the `DepositMessage`.
    ///
    /// # Returns
    ///
    /// * [b256] - The amount for the deposit message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.amount() == amount);
    /// }
    /// ```
    pub fn amount(self) -> b256 {
        self.amount
    }

    /// Returns the `from` of the `DepositMessage`.
    ///
    /// # Returns
    ///
    /// * [b256] - The from address for the deposit message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.from() == from);
    /// }
    /// ```
    pub fn from(self) -> b256 {
        self.from
    }

    /// Returns the `to` of the `DepositMessage`.
    ///
    /// # Returns
    ///
    /// * [Identity] - The to `Identity` for the deposit message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.to() == to);
    /// }
    /// ```
    pub fn to(self) -> Identity {
        self.to
    }

    /// Returns the `token_address` of the `DepositMessage`.
    ///
    /// # Returns
    ///
    /// * [b256] - The token address for the deposit message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.token_address() == token_address);
    /// }
    /// ```
    pub fn token_address(self) -> b256 {
        self.token_address
    }

    /// Returns the `token_id` of the `DepositMessage`.
    ///
    /// # Returns
    ///
    /// * [b256] - The token id for the deposit message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.token_id() == token_id);
    /// }
    /// ```
    pub fn token_id(self) -> b256 {
        self.token_id
    }

    /// Returns the `decimals` of the `DepositMessage`.
    ///
    /// # Returns
    ///
    /// * [u8] - The decimals for the deposit message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.decimals() == decimals);
    /// }
    /// ```
    pub fn decimals(self) -> u8 {
        self.decimals
    }

    /// Returns the `deposit_type` of the `DepositMessage`.
    ///
    /// # Returns
    ///
    /// * [DepositType] - The deposit type for the deposit message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositMessage;
    ///
    /// fn foo(
    ///     amount: b256,
    ///     from: b256,
    ///     to: Identity,
    ///     token_address: b256,
    ///     token_id: b256,
    ///     decimals: u8,
    ///     deposit_type: DepositType
    /// ) {
    ///     let deposit_message = DepositMessage::new(
    ///         amount,
    ///         from,
    ///         to,
    ///         token_address,
    ///         token_id,
    ///         decimals,
    ///         deposit_type
    ///     );
    ///     assert(deposit_message.deposit_type() == deposit_type);
    /// }
    /// ```
    pub fn deposit_type(self) -> DepositType {
        self.deposit_type
    }
}

impl MetadataMessage {
    /// Returns a new `MetadataMessage`.
    ///
    /// # Arguments
    ///
    /// * `token_address`: [b256] - The bridged token's address on the canonical chain.
    /// * `token_id`: [b256] - The token's ID on the canonical chain.
    /// * `name`: [String] - The bridged token's name on the canonical chain.
    /// * `symbol`: [String] - The bridged token's symbol on the canonical chain.
    ///
    /// # Returns
    ///
    /// * [MetadataMessage] - The newly created `MetadataMessage`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::MetadataMessage;
    ///
    /// fn foo(token_address: b256, token_id: b256, name: String, symbol: String) {
    ///     let metadata_message = MetadataMessage::new(token_address, token_id, name, symbol);
    ///     assert(metadata_message.token_address == token_address);
    ///     assert(metadata_message.token_id == token_id);
    ///     assert(deposit_message.name == name);
    ///     assert(deposit_message.symbol == symbol);
    /// }
    /// ```
    pub fn new(
        token_address: b256,
        token_id: b256,
        name: String,
        symbol: String,
    ) -> Self {
        Self {
            token_address,
            token_id,
            name,
            symbol,
        }
    }

    /// Returns the `token_address` of the `MetadataMessage`.
    ///
    /// # Returns
    ///
    /// * [b256] - The token address for the metdata message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::MetadataMessage;
    ///
    /// fn foo(token_address: b256, token_id: b256, name: String, symbol: String) {
    ///     let metadata_message = MetadataMessage::new(token_address, token_id, name, symbol);
    ///     assert(metadata_message.token_address() == token_address);
    /// }
    /// ```
    pub fn token_address(self) -> b256 {
        self.token_address
    }

    /// Returns the `token_id` of the `MetadataMessage`.
    ///
    /// # Returns
    ///
    /// * [b256] - The token id for the metdata message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::MetadataMessage;
    ///
    /// fn foo(token_address: b256, token_id: b256, name: String, symbol: String) {
    ///     let metadata_message = MetadataMessage::new(token_address, token_id, name, symbol);
    ///     assert(metadata_message.token_id() == token_id);
    /// }
    /// ```
    pub fn token_id(self) -> b256 {
        self.token_id
    }

    /// Returns the `name` of the `MetadataMessage`.
    ///
    /// # Returns
    ///
    /// * [String] - The name for the metdata message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::MetadataMessage;
    ///
    /// fn foo(token_address: b256, token_id: b256, name: String, symbol: String) {
    ///     let metadata_message = MetadataMessage::new(token_address, token_id, name, symbol);
    ///     assert(metadata_message.name() == name);
    /// }
    /// ```
    pub fn name(self) -> String {
        self.name
    }

    /// Returns the `symbol` of the `MetadataMessage`.
    ///
    /// # Returns
    ///
    /// * [String] - The symbol for the metdata message.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::MetadataMessage;
    ///
    /// fn foo(token_address: b256, token_id: b256, name: String, symbol: String) {
    ///     let metadata_message = MetadataMessage::new(token_address, token_id, name, symbol);
    ///     assert(metadata_message.symbol() == symbol);
    /// }
    /// ```
    pub fn symbol(self) -> String {
        self.symbol
    }
}

impl DepositType {
    /// Returns whether the deposit type is an address.
    ///
    /// # Return Values
    ///
    /// * [bool] - `true` if the deposit type is an address, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositType;
    ///
    /// fn foo(deposit_type: DepositType) {
    ///     assert(DepositType.is_address());
    /// }
    /// ```
    pub fn is_address(self) -> bool {
        match self {
            Self::Address => true,
            _ => false,
        }
    }

    /// Returns whether the deposit type is a contract.
    ///
    /// # Return Values
    ///
    /// * [bool] - `true` if the deposit type is a contract, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositType;
    ///
    /// fn foo(deposit_type: DepositType) {
    ///     assert(DepositType.is_contract());
    /// }
    /// ```
    pub fn is_contract(self) -> bool {
        match self {
            Self::Contract => true,
            _ => false,
        }
    }

    /// Returns whether the deposit type is a contract with data.
    ///
    /// # Return Values
    ///
    /// * [bool] - `true` if the deposit type is a contract with data, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src10::DepositType;
    ///
    /// fn foo(deposit_type: DepositType) {
    ///     assert(DepositType.is_contract_with_data());
    /// }
    /// ```
    pub fn is_contract_with_data(self) -> bool {
        match self {
            Self::ContractWithData => true,
            _ => false,
        }
    }
}
