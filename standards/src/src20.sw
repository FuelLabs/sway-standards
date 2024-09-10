library;

use std::string::String;

abi SRC20 {
    /// Returns the total number of individual assets for a contract.
    ///
    /// # Returns
    ///
    /// * [u64] - The number of assets that this contract has minted.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId) {
    ///     let contract_abi = abi(SRC20, contract_id.bits());
    ///     let total_assets: u64 = contract_abi.total_assets();
    ///     assert(total_assets != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_assets() -> u64;

    /// Returns the total supply of coins for an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the total supply.
    ///
    /// # Returns
    ///
    /// * [Option<u64>] - The total supply of coins for `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract_id.bits());
    ///     let total_supply: Option<u64> = contract_abi.total_supply(asset);
    ///     assert(total_supply.unwrap() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64>;

    /// Returns the name of the asset, such as “Ether”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the name.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The name of `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract_id.bits());
    ///     let name: Option<String> = contract_abi.name(asset);
    ///     assert(name.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String>;
    /// Returns the symbol of the asset, such as “ETH”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the symbol.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The symbol of `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract_id.bits());
    ///     let symbol: Option<String> = contract_abi.symbol(asset);
    ///     assert(symbol.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String>;
    /// Returns the number of decimals the asset uses.
    ///
    /// # Additional Information
    ///
    /// e.g. 8, means to divide the coin amount by 100000000 to get its user representation.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the decimals.
    ///
    /// # Returns
    ///
    /// * [Option<u8>] - The decimal precision used by `asset`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SRC20;
    ///
    /// fn foo(contract_id: ContractId, asset: AssedId) {
    ///     let contract_abi = abi(SRC20, contract_id.bits());
    ///     let decimals: Option<u8> = contract_abi.decimals(asset);
    ///     assert(decimals.unwrap() == 8u8);
    /// }
    /// ```
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8>;
}

/// The event emitted when the name is set.
pub struct SetNameEvent {
    /// The asset for which name is set.
    pub asset: AssetId,
    /// The name that is set.
    pub name: Option<String>,
    /// The caller that set the name.
    pub sender: Identity,
}

/// The event emitted when the symbol is set.
pub struct SetSymbolEvent {
    /// The asset for which symbol is set.
    pub asset: AssetId,
    /// The symbol that is set.
    pub symbol: Option<String>,
    /// The caller that set the symbol.
    pub sender: Identity,
}

/// The event emitted when the decimals is set.
pub struct SetDecimalsEvent {
    /// The asset for which decimals is set.
    pub asset: AssetId,
    /// The decimals that is set.
    pub decimals: u8,
    /// The caller that set the decimals.
    pub sender: Identity,
}

/// The event emitted when the total supply is changed.
pub struct TotalSupplyEvent {
    /// The asset for which supply is updated.
    pub asset: AssetId,
    /// The new supply of the asset.
    pub supply: u64,
    /// The caller that updated the supply.
    pub sender: Identity,
}

impl core::ops::Eq for SetNameEvent {
    fn eq(self, other: Self) -> bool {
        self.asset == other.asset && self.name == other.name && self.sender == other.sender
    }
}

impl SetNameEvent {
    /// Returns a new `SetNameEvent` event.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which name is set.
    /// * `name`: [Option<String>] - The name that is set.
    /// * `sender`: [Identity] - The caller that set the name.
    ///
    /// # Returns
    ///
    /// * [SetNameEvent] - The new `SetNameEvent` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetNameEvent;
    ///
    /// fn foo(asset: AssetId, name: Option<String>, sender: Identity) {
    ///     let my_event = SetNameEvent::new(asset, name, sender);
    ///     assert(my_event.asset == asset);
    ///     assert(my_event.name == name);
    ///     assert(my_event.sender == sender);
    /// }
    pub fn new(asset: AssetId, name: Option<String>, sender: Identity) -> Self {
        Self {
            asset,
            name,
            sender,
        }
    }

    /// Returns the asset of the `SetNameEvent` event.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetNameEvent;
    ///
    /// fn foo(asset: AssetId, name: Option<String>, sender: Identity) {
    ///     let my_event = SetNameEvent::new(asset, name, sender);
    ///     assert(my_event.asset() == asset);
    /// }
    pub fn asset(self) -> AssetId {
        self.asset
    }

    /// Returns the name of the `SetNameEvent` event.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The name for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetNameEvent;
    ///
    /// fn foo(asset: AssetId, name: Option<String>, sender: Identity) {
    ///     let my_event = SetNameEvent::new(asset, name, sender);
    ///     assert(my_event.name() == name);
    /// }
    pub fn name(self) -> Option<String> {
        self.name
    }

    /// Returns the sender of the `SetNameEvent` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The sender of the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetNameEvent;
    ///
    /// fn foo(asset: AssetId, name: Option<String>, sender: Identity) {
    ///     let my_event = SetNameEvent::new(asset, name, sender);
    ///     assert(my_event.sender() == sender);
    /// }
    pub fn sender(self) -> Identity {
        self.sender
    }

    /// Logs the `SetNameEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetNameEvent;
    ///
    /// fn foo(asset: AssetId, name: Option<String>, sender: Identity) {
    ///     let my_event = SetNameEvent::new(asset, name, sender);
    ///     my_event.log();
    /// }
    pub fn log(self) {
        log(self);
    }
}

impl core::ops::Eq for SetSymbolEvent {
    fn eq(self, other: Self) -> bool {
        self.asset == other.asset && self.symbol == other.symbol && self.sender == other.sender
    }
}

impl SetSymbolEvent {
    /// Returns a new `SetSymbolEvent` event.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which symbol is set.
    /// * `symbol`: [Option<String>] - The symbol that is set.
    /// * `sender`: [Identity] - The caller that set the symbol.
    ///
    /// # Returns
    ///
    /// * [SetSymbolEvent] - The new `SetSymbolEvent` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetSymbolEvent;
    ///
    /// fn foo(asset: AssetId, symbol: Option<String>, sender: Identity) {
    ///     let my_event = SetSymbolEvent::new(asset, symbol, sender);
    ///     assert(my_event.asset == asset);
    ///     assert(my_event.symbol == symbol);
    ///     assert(my_event.sender == sender);
    /// }
    pub fn new(asset: AssetId, symbol: Option<String>, sender: Identity) -> Self {
        Self {
            asset,
            symbol,
            sender,
        }
    }

    /// Returns the asset of the `SetSymbolEvent` event.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetSymbolEvent;
    ///
    /// fn foo(asset: AssetId, symbol: Option<String>, sender: Identity) {
    ///     let my_event = SetSymbolEvent::new(asset, symbol, sender);
    ///     assert(my_event.asset() == asset);
    /// }
    pub fn asset(self) -> AssetId {
        self.asset
    }

    /// Returns the symbol of the `SetSymbolEvent` event.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The symbol for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetSymbolEvent;
    ///
    /// fn foo(asset: AssetId, symbol: Option<String>, sender: Identity) {
    ///     let my_event = SetSymbolEvent::new(asset, symbol, sender);
    ///     assert(my_event.symbol() == symbol);
    /// }
    pub fn symbol(self) -> Option<String> {
        self.symbol
    }

    /// Returns the sender of the `SetSymbolEvent` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The sender of the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetSymbolEvent;
    ///
    /// fn foo(asset: AssetId, symbol: Option<String>, sender: Identity) {
    ///     let my_event = SetSymbolEvent::new(asset, symbol, sender);
    ///     assert(my_event.sender() == sender);
    /// }
    pub fn sender(self) -> Identity {
        self.sender
    }

    /// Logs the `SetSymbolEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetSymbolEvent;
    ///
    /// fn foo(asset: AssetId, symbol: Option<String>, sender: Identity) {
    ///     let my_event = SetSymbolEvent::new(asset, symbol, sender);
    ///     my_event.log();
    /// }
    pub fn log(self) {
        log(self);
    }
}

impl core::ops::Eq for SetDecimalsEvent {
    fn eq(self, other: Self) -> bool {
        self.asset == other.asset && self.decimals == other.decimals && self.sender == other.sender
    }
}

impl SetDecimalsEvent {
    /// Returns a new `SetDecimalsEvent` event.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which decimals is set.
    /// * `decimals`: [u8] - The decimals that is set.
    /// * `sender`: [Identity] - The caller that set the decimals.
    ///
    /// # Returns
    ///
    /// * [SetDecimalsEvent] - The new `SetDecimalsEvent` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetDecimalsEvent;
    ///
    /// fn foo(asset: AssetId, decimals: u8, sender: Identity) {
    ///     let my_event = SetDecimalsEvent::new(asset, decimals, sender);
    ///     assert(my_event.asset == asset);
    ///     assert(my_event.decimals == decimals);
    ///     assert(my_event.sender == sender);
    /// }
    /// ```
    pub fn new(asset: AssetId, decimals: u8, sender: Identity) -> Self {
        Self {
            asset,
            decimals,
            sender,
        }
    }

    /// Returns the asset of the `SetDecimalsEvent` event.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetDecimalsEvent;
    ///
    /// fn foo(asset: AssetId, decimals: u8, sender: Identity) {
    ///     let my_event = SetDecimalsEvent::new(asset, decimals, sender);
    ///     assert(my_event.asset() == asset);
    /// }
    /// ```
    pub fn asset(self) -> AssetId {
        self.asset
    }

    /// Returns the decimals of the `SetDecimalsEvent` event.
    ///
    /// # Returns
    ///
    /// * [u8] - The decimals for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetDecimalsEvent;
    ///
    /// fn foo(asset: AssetId, decimals: u8, sender: Identity) {
    ///     let my_event = SetDecimalsEvent::new(asset, decimals, sender);
    ///     assert(my_event.decimals() == decimals);
    /// }
    /// ```
    pub fn decimals(self) -> u8 {
        self.decimals
    }

    /// Returns the sender of the `SetDecimalsEvent` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The sender of the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetDecimalsEvent;
    ///
    /// fn foo(asset: AssetId, decimals: u8, sender: Identity) {
    ///     let my_event = SetDecimalsEvent::new(asset, decimals, sender);
    ///     assert(my_event.sender() == sender);
    /// }
    /// ```
    pub fn sender(self) -> Identity {
        self.sender
    }

    /// Logs the `SetDecimalsEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::SetDecimalsEvent;
    ///
    /// fn foo(asset: AssetId, decimals: u8, sender: Identity) {
    ///     let my_event = SetDecimalsEvent::new(asset, decimals, sender);
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}

impl core::ops::Eq for TotalSupplyEvent {
    fn eq(self, other: Self) -> bool {
        self.asset == other.asset && self.supply == other.supply && self.sender == other.sender
    }
}

impl TotalSupplyEvent {
    /// Returns a new `TotalSupplyEvent` event.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which supply is updated.
    /// * `supply`: [u64] - The new supply of the asset.
    /// * `sender`: [Identity] - The caller that updated the supply.
    ///
    /// # Returns
    ///
    /// * [TotalSupplyEvent] - The new `TotalSupplyEvent` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::TotalSupplyEvent;
    ///
    /// fn foo(asset: AssetId, supply: u64, sender: Identity) {
    ///     let my_event = TotalSupplyEvent::new(asset, supply, sender);
    ///     assert(my_event.asset == asset);
    ///     assert(my_event.supply == supply);
    ///     assert(my_event.sender == sender);
    /// }
    /// ```
    pub fn new(asset: AssetId, supply: u64, sender: Identity) -> Self {
        Self {
            asset,
            supply,
            sender,
        }
    }

    /// Returns the asset of the `TotalSupplyEvent` event.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::TotalSupplyEvent;
    ///
    /// fn foo(asset: AssetId, supply: u64, sender: Identity) {
    ///     let my_event = TotalSupplyEvent::new(asset, supply, sender);
    ///     assert(my_event.asset() == asset);
    /// }
    /// ```
    pub fn asset(self) -> AssetId {
        self.asset
    }

    /// Returns the supply of the `TotalSupplyEvent` event.
    ///
    /// # Returns
    ///
    /// * [u64] - The supply for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::TotalSupplyEvent;
    ///
    /// fn foo(asset: AssetId, supply: u64, sender: Identity) {
    ///     let my_event = TotalSupplyEvent::new(asset, supply, sender);
    ///     assert(my_event.supply() == supply);
    /// }
    /// ```
    pub fn supply(self) -> u64 {
        self.supply
    }

    /// Returns the sender of the `TotalSupplyEvent` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The sender of the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::TotalSupplyEvent;
    ///
    /// fn foo(asset: AssetId, supply: u64, sender: Identity) {
    ///     let my_event = TotalSupplyEvent::new(asset, supply, sender);
    ///     assert(my_event.sender() == sender);
    /// }
    /// ```
    pub fn sender(self) -> Identity {
        self.sender
    }

    /// Logs the `TotalSupplyEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src20::TotalSupplyEvent;
    ///
    /// fn foo(asset: AssetId, supply: u64, sender: Identity) {
    ///     let my_event = TotalSupplyEvent::new(asset, supply, sender);
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}
