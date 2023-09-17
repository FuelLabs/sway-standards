<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-5-logo-dark-theme.png">
        <img alt="SRC-5 logo" width="400px" src=".docs/src-5-logo-light-theme.png">
    </picture>
</p>

# Abstract
The following standard allows for the implementation of a standard API for token vaults such as yield bearing token vaults. This standard is an optional add-on to the SRC-20 standard.

# Motivation
Token vaults allow users to own shares of variable amount of assets, such as lending protocols which may have growing assets due to profits from interest. This pattern is highly useful and would greatly benefit from standardisation

# Prior Art
Token vaults have been thoroughly explored on Ethereum and with [EIP 4626](https://eips.ethereum.org/EIPS/eip-4626) they have their own standard for it. However as Fuel's native assets are fundamentally different to Ethereum's ERC-20 tokens, the implementation will differ, but the interface may be used as reference.

# Specification
## Required public functions
The following functions MUST be implemented (on top of the SRC-20 functions) to follow the SRC-6 standard

### `fn deposit(receiver: Identity)`
Method that allows depositing of the underlying asset in exchange for shares of the vault.

MUST revert if any AssetId other than the underlying is forwarded.
MUST mint `preview_deposit(deposited_assets)` amount of shares to `receiver`
MUST increase `managed_assets` by `deposited_assets` (through any means including `std::context::this_balance(ASSET_ID)` if applicable)
MUST increase `total_supply` by newly minted shares

### `fn withdraw(asset: AssetId, receiver: Identity)`
Method that allows the redeeming of the vault shares in exchange for a pro-rata amount of the underlying asset

MUST revert if any AssetId other than the AssetId of the self contract is forwarded.
MUST send `preview_withdraw(redeemed_shares)` amount of assets to `receiver`
MUST burn the received shares
MUST reduce `total_assets` by `preview_withdraw(redeemed_shares)`
MUST reduce `total_supply` by amount of burnt shares

### `fn managed_assets(asset: AssetId) -> u64`
Method that returns the total assets under management by vault. Includes assets controlled by the vault but not directly possessed by vault

MUST return total amount of assets of underlying AssetId under management by vault

### `fn convert_to_shares(asset: AssetId, assets: u64) -> Option<u64>`
Helper method for converting 



## Required logs
The following logs MUST be emitted at the specified occasions

```
pub struct Deposit {
    caller: Identity,
    receiver: Identity,
    assets: u64,
    shares: u64,
}
```
`caller` has called the `deposit` method sending `assets` assets of the underlying asset_id, in exchange for `shares` shares sent to the receiver `receiver`

The `Deposit` struct MUST be logged whenever new shares are minted via the `deposit` method

```
pub struct Withdraw {
    caller: Identity,
    receiver: Identity,
    assets: u64,
    shares: u64,
}
```
`caller` has called the `withdraw` method sending `shares` shares in exchange for `assets` assets to the receiver `receiver`

The `Withdraw` struct MUST be logged whenever shares are redeemed for assets via the `withdraw` method

# Rationale
The ABI discussed is simple and covers the known use cases of token vaults while allowing safe implementations

# Backwards compatibility
This standard is fully compatible with the SRC-20 standard

# Security Considerations
Incorrect implementation of token vaults could allow attackers to steal underlying assets. It is recommended to properly audit any code using this standard to ensure exploits are not possible.

# Reference implementation
Full reference implementation can be seen [here](https://github.com/SwayStar123/vault-standard-reference-implementation/blob/master/src/main.sw)

This is a draft standard
