library;

/// Event logged when a deposit is made.
pub struct Deposit {
    /// The caller of the deposit function.
    pub caller: Identity,
    /// The receiver of the deposit.
    pub receiver: Identity,
    /// The asset being deposited.
    pub underlying_asset: AssetId,
    /// The SubId of the vault.
    pub vault_sub_id: SubId,
    /// The amount of assets being deposited.
    pub deposited_amount: u64,
    /// The amount of shares being minted.
    pub minted_shares: u64,
}

/// Event logged when a withdrawal is made.
pub struct Withdraw {
    /// The caller of the withdrawal function.
    pub caller: Identity,
    /// The receiver of the withdrawal.
    pub receiver: Identity,
    /// The asset being withdrawn.
    pub underlying_asset: AssetId,
    /// The SubId of the vault.
    pub vault_sub_id: SubId,
    /// The amount of assets being withdrawn.
    pub withdrawn_amount: u64,
    /// The amount of shares being burned.
    pub burned_shares: u64,
}

abi SRC6 {
    /// Deposits assets into the contract and mints shares to the receiver.
    ///
    /// # Additional Information
    ///
    /// * Assets must be forwarded to the contract in the contract call.
    ///
    /// # Arguments
    ///
    /// * `receiver`: [Identity] - The receiver of the shares.
    /// * `vault_sub_id`: [SubId] - The SubId of the vault.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of shares minted.
    ///
    /// # Reverts
    ///
    /// * If the asset is not supported by the contract.
    /// * If the amount of assets forwarded to the contract is zero.
    /// * The user crosses any global or user specific deposit limits.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::SRC6;
    ///
    /// fn foo(
    ///     contract_id: ContractId,
    ///     receiver: Identity,
    ///     vault_sub_id: SubId,
    ///     amount: u64,
    ///     asset_id: AssetId
    /// ) {
    ///     let contract_abi = abi(SRC6, contract_id.bits());
    ///     let minted_shares: u64 = contract_abi.deposit {
    ///         gas: 10000,
    ///         coins: amount,
    ///         asset_id: asset_id.bits()
    ///     } (receiver, vault_sub_id);
    ///     assert(minted_shares != 0);
    /// }
    /// ```
    #[payable]
    #[storage(read, write)]
    fn deposit(receiver: Identity, vault_sub_id: SubId) -> u64;

    /// Burns shares from the sender and transfers assets to the receiver.
    ///
    /// # Additional Information
    ///
    /// * Shares must be forwarded to the contract in the contract call.
    ///
    /// # Arguments
    ///
    /// * `receiver`: [Identity] - The receiver of the assets.
    /// * `underlying_asset`: [AssetId] - The asset for which the shares should be burned.
    /// * `vault_sub_id`: [SubId] - The SubId of the vault.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of assets transferred.
    ///
    /// # Reverts
    ///
    /// * If the asset is not supported by the contract.
    /// * If the amount of shares is zero.
    /// * If the transferred shares do not corresspond to the given asset.
    /// * The user crosses any global or user specific withdrawal limits.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::SRC6;
    ///
    /// fn foo(
    ///     contract_id: ContractId,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     share_asset_id: AssetId,
    ///     amount: u64
    /// ) {
    ///     let contract_abi = abi(SRC6, contract_id.bits());
    ///     let withdrawn_amount: u64 = contract_abi.withdraw {
    ///         gas: 10000,
    ///         coins: amount,
    ///         asset_id: share_asset_id.bits()
    ///     } (receiver, underlying_asset, vault_sub_id);
    ///     assert(withdrawn_amount != 0);
    #[payable]
    #[storage(read, write)]
    fn withdraw(
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> u64;

    /// Returns the amount of managed assets of the given asset.
    ///
    /// # Arguments
    ///
    /// * `underlying_asset`: [AssetId] - The asset for which the amount of managed assets should be returned.
    /// * `vault_sub_id`: [SubId] - The SubId of the vault.
    ///
    /// # Returns
    ///
    /// * [u64] - The amount of managed assets of the given asset.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::SRC6;
    ///
    /// fn foo(
    ///     contract_id: ContractId,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId
    /// ) {
    ///     let contract_abi = abi(SRC6, contract_id.bits());
    ///     let managed_assets: u64 = contract_abi.managed_assets(underlying_asset, vault_sub_id);
    ///     assert(managed_assets != 0);
    /// }
    /// ```
    #[storage(read)]
    fn managed_assets(underlying_asset: AssetId, vault_sub_id: SubId) -> u64;

    /// Returns the maximum amount of assets that can be deposited into the contract, for the given asset.
    ///
    /// # Additional Information
    ///
    /// Must account for any user or global limits.
    ///
    /// # Arguments
    ///
    /// * `receiver`: [Identity] - The hypothetical receiver of the shares.
    /// * `underlying_asset`: [AssetId] - The asset for which the maximum amount of depositable assets should be returned.
    /// * `vault_sub_id`: [SubId] - The SubId of the vault.
    ///
    /// # Returns
    ///
    /// * [Some(u64)] - The maximum amount of assets that can be deposited into the contract, for the given asset.
    /// * [None] - If the asset is not supported by the contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::SRC6;
    ///
    /// fn foo(
    ///     contract_id: ContractId,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId
    /// ) {
    ///     let contract_abi = abi(SRC6, contract_id.bits());
    ///     let max_depositable: u64 = contract_abi.max_depositable(receiver, underlying_asset, vault_sub_id).unwrap();
    ///     assert(max_depositable != 0);
    /// }
    /// ```
    #[storage(read)]
    fn max_depositable(
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
    ) -> Option<u64>;

    /// Returns the maximum amount of assets that can be withdrawn from the contract, for the given asset.
    ///
    /// # Additional Information
    ///
    /// Must account for any global limits.
    ///
    /// # Arguments
    ///
    /// * `underlying_asset`: [AssetId] - The asset for which the maximum amount of withdrawable assets should be returned.
    /// * `vault_sub_id`: [SubId] - The SubId of the vault.
    ///
    /// # Returns
    ///
    /// * [Some(u64)] - The maximum amount of assets that can be withdrawn from the contract, for the given asset.
    /// * [None] - If the asset is not supported by the contract.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::SRC6;
    ///
    /// fn foo(
    ///     contract_id: ContractId,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId
    /// ) {
    ///     let contract_abi = abi(SRC6, contract_id.bits());
    ///     let max_withdrawable: u64 = contract_abi.max_withdrawable(underlying_asset, vault_sub_id).unwrap();
    ///     assert(max_withdrawable != 0);
    /// }
    /// ```
    #[storage(read)]
    fn max_withdrawable(underlying_asset: AssetId, vault_sub_id: SubId) -> Option<u64>;
}

impl core::ops::Eq for Deposit {
    fn eq(self, other: Self) -> bool {
        self.caller == other.caller && self.receiver == other.receiver && self.underlying_asset == other.underlying_asset && self.vault_sub_id == other.vault_sub_id && self.deposited_amount == other.deposited_amount && self.minted_shares == other.minted_shares
    }
}

impl core::ops::Eq for Withdraw {
    fn eq(self, other: Self) -> bool {
        self.caller == other.caller && self.receiver == other.receiver && self.underlying_asset == other.underlying_asset && self.vault_sub_id == other.vault_sub_id && self.withdrawn_amount == other.withdrawn_amount && self.burned_shares == other.burned_shares
    }
}

impl Deposit {
    /// Returns a new `Deposit` event.
    ///
    /// # Arguments
    ///
    /// * `caller`: [Identity] - The caller of the deposit function.
    /// * `receiver`: [Identity] - The receiver of the deposit.
    /// * `underlying_asset`: [AssetId] - The asset being deposited.
    /// * `vault_sub_id`: [SubId] - The SubId of the vault.
    /// * `deposited_amount`: [u64] - The amount of assets being deposited.
    /// * `minted_shares`: [u64] - The amount of shares being minted.
    ///
    /// # Returns
    ///
    /// * [Deposit] - The new `Deposit` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     assert(my_event.caller == caller);
    ///     assert(my_event.receiver == receiver);
    ///     assert(my_event.underlying_asset == underlying_asset);
    ///     assert(my_event.vault_sub_id == vault_sub_id);
    ///     assert(my_event.deposited_amount == deposited_amount);
    ///     assert(my_event.minted_shares == minted_shares);
    /// }
    /// ```
    pub fn new(
        caller: Identity,
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
        deposited_amount: u64,
        minted_shares: u64,
    ) -> Self {
        Self {
            caller,
            receiver,
            underlying_asset,
            vault_sub_id,
            deposited_amount,
            minted_shares,
        }
    }

    /// Returns the `caller` of the `Deposit` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The caller for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     assert(my_event.caller() == caller);
    /// }
    /// ```
    pub fn caller(self) -> Identity {
        self.caller
    }

    /// Returns the `receiver` of the `Deposit` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The receiver for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     assert(my_event.receiver() == receiver);
    /// }
    /// ```
    pub fn receiver(self) -> Identity {
        self.receiver
    }

    /// Returns the `underlying_asset` of the `Deposit` event.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The underlying asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     assert(my_event.underlying_asset() == underlying_asset);
    /// }
    /// ```
    pub fn underlying_asset(self) -> AssetId {
        self.underlying_asset
    }

    /// Returns the `vault_sub_id` of the `Deposit` event.
    ///
    /// # Returns
    ///
    /// * [SubId] - The vault sub id for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     assert(my_event.vault_sub_id() == vault_sub_id);
    /// }
    /// ```
    pub fn vault_sub_id(self) -> SubId {
        self.vault_sub_id
    }

    /// Returns the `deposited_amount` of the `Deposit` event.
    ///
    /// # Returns
    ///
    /// * [u64] - The deposited amount for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     assert(my_event.deposited_amount() == deposited_amount);
    /// }
    /// ```
    pub fn deposited_amount(self) -> u64 {
        self.deposited_amount
    }

    /// Returns the `minted_shares` of the `Deposit` event.
    ///
    /// # Returns
    ///
    /// * [u64] - The minted shares for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     assert(my_event.minted_shares() == minted_shares);
    /// }
    /// ```
    pub fn minted_shares(self) -> u64 {
        self.minted_shares
    }

    /// Logs the `Deposit`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Deposit;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     deposited_amount: u64,
    ///     minted_shares: u64
    /// ) {
    ///     let my_event = Deposit::new(caller, receiver, underlying_asset, vault_sub_id, deposited_amount, minted_shares);
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}

impl Withdraw {
    /// Returns a new `Withdraw` event.
    ///
    /// # Arguments
    ///
    /// * `caller`: [Identity] - The caller of the withdrawal function.
    /// * `receiver`: [Identity] - The receiver of the withdrawal.
    /// * `underlying_asset`: [AssetId] - The asset being withdrawn.
    /// * `vault_sub_id`: [SubId] - The SubId of the vault.
    /// * `withdrawn_amount`: [u64] - The amount of assets being withdrawn.
    /// * `burned_shares`: [u64] - The amount of shares being burned.
    ///
    /// # Returns
    ///
    /// * [Withdraw] - The new `Withdraw` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     assert(my_event.caller == caller);
    ///     assert(my_event.receiver == receiver);
    ///     assert(my_event.underlying_asset == underlying_asset);
    ///     assert(my_event.vault_sub_id == vault_sub_id);
    ///     assert(my_event.withdrawn_amount == withdrawn_amount);
    ///     assert(my_event.burned_shares == burned_shares);
    /// }
    /// ```
    pub fn new(
        caller: Identity,
        receiver: Identity,
        underlying_asset: AssetId,
        vault_sub_id: SubId,
        withdrawn_amount: u64,
        burned_shares: u64,
    ) -> Self {
        Self {
            caller,
            receiver,
            underlying_asset,
            vault_sub_id,
            withdrawn_amount,
            burned_shares,
        }
    }

    /// Returns the `caller` of the `Withdraw` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The caller for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     assert(my_event.caller() == caller);
    /// }
    /// ```
    pub fn caller(self) -> Identity {
        self.caller
    }

    /// Returns the `receiver` of the `Withdraw` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The receiver for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     assert(my_event.receiver() == receiver);
    /// }
    /// ```
    pub fn receiver(self) -> Identity {
        self.receiver
    }

    /// Returns the `underlying_asset` of the `Withdraw` event.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The underlying asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     assert(my_event.underlying_asset() == underlying_asset);
    /// }
    /// ```
    pub fn underlying_asset(self) -> AssetId {
        self.underlying_asset
    }

    /// Returns the `vault_sub_id` of the `Withdraw` event.
    ///
    /// # Returns
    ///
    /// * [SubId] - The vault sub id for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     assert(my_event.vault_sub_id() == vault_sub_id);
    /// }
    /// ```
    pub fn vault_sub_id(self) -> SubId {
        self.vault_sub_id
    }

    /// Returns the `withdrawn_amount` of the `Withdraw` event.
    ///
    /// # Returns
    ///
    /// * [u64] - The withdrawn amount for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     assert(my_event.withdrawn_amount() == withdrawn_amount);
    /// }
    /// ```
    pub fn withdrawn_amount(self) -> u64 {
        self.withdrawn_amount
    }

    /// Returns the `burned_shares` of the `Withdraw` event.
    ///
    /// # Returns
    ///
    /// * [u64] - The burned shares for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     assert(my_event.burned_shares() == burned_shares);
    /// }
    /// ```
    pub fn burned_shares(self) -> u64 {
        self.burned_shares
    }

    /// Logs the `Withdraw`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src6::Withdraw;
    ///
    /// fn foo(
    ///     caller: Identity,
    ///     receiver: Identity,
    ///     underlying_asset: AssetId,
    ///     vault_sub_id: SubId,
    ///     withdrawn_amount: u64,
    ///     burned_shares: u64
    /// ) {
    ///     let my_event = Withdraw::new(caller, receiver, underlying_asset, vault_sub_id, withdrawn_amount, burned_shares);
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}
