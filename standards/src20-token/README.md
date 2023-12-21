<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-20-logo-dark-theme.png">
        <img alt="SRC-20 logo" width="400px" src=".docs/src-20-logo-light-theme.png">
    </picture>
</p>

# Abstract

The following standard allows for the implementation of a standard API for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) using the Sway Language. This standard provides basic functionality as well as on-chain metadata for other applications to use.

# Motivation

A standard interface for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) on Fuel allows external applications to interact with the token, whether that be decentralized exchanges, wallets, or Fuel's [Scripts](https://docs.fuel.network/docs/sway/sway-program-types/scripts/) and [Predicates](https://docs.fuel.network/docs/sway/sway-program-types/predicates/). 

# Prior Art

The SRC-20 Token Standard naming pays homage to the [ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20) seen on Ethereum. While there is functionality we may use as a reference, it is noted that Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) are fundamentally different than Ethereum's tokens.

There has been a discussion of the Fungile Token Standard on the [Fuel Forum](https://forum.fuel.network/). This discussion can be found [here](https://forum.fuel.network/t/src-20-fungible-token-standard/186). 

There has also been a Fungible Token Standard and Non-Fungible Token Standard implementations added to the [Sway-Libs](https://github.com/FuelLabs/sway-libs) repository before the creation of the [Sway-Standards](https://github.com/FuelLabs/sway-standards) repository. The introduction of this standard in the [Sway-Standards](https://github.com/FuelLabs/sway-standards) repository will deprecate the Sway-Libs Fungible Token Standard.

# Specification

## Required Public Functions

The following functions MUST be implemented to follow the SRC-20 standard:

### `fn total_assets() -> u64`

This function MUST return the total number of individual assets for a contract.

### `fn total_supply(asset: AssetId) -> Option<u64>`

This function MUST return the total supply of tokens for an asset. This function MUST return `Some` for any assets minted by the contract.

### `fn name(asset: AssetId) -> Option<String>` 

This function MUST return the name of the asset, such as “Ether”. This function MUST return `Some` for any assets minted by the contract.

### `fn symbol(asset: AssetId) -> Option<String>`

This function must return the symbol of the asset, such as “ETH”. This function MUST return `Some` for any assets minted by the contract.

### `fn decimals(asset: AssetId) -> Option<u8>`

This function must return the number of decimals the asset uses - e.g. 8, which means to divide the token amount by 100000000 to get its user representation. This function MUST return `Some` for any assets minted by the contract.

## Non-Fungible Token Restrictions 

Non-Fungible Tokens (NFT) on Fuel are Native Assets and thus follow the same standard as Fungible Tokens with some restrictions. For a Native Asset on Fuel to be deemed an NFT, the following must be applied:

* Non-Fungible Tokens SHALL have a total supply of one per asset. 
* Non-Fungible Tokens SHALL have a decimal of `0u8`.

# Rationale

As the SRC-20 Token Standard leverages Native Assets on Fuel, we do not require the implementation of certain functions such as transfer or approval. This is done directly within the FuelVM and there is no smart contract that requires updating of balances. As Fuel is UTXO based, any transfer events may be indexed on transaction receipts. 

Following this, we have omitted the inclusion of any transfer functions or events. The provided specification outlines only the required functions and events to implement fully functional tokens on the Fuel Network. Additional functionality and properties may be added as needed.

# Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets). There are no other standards that require compatibility.

# Security Considerations

This standard does not introduce any security concerns, as it does not call external contracts, nor does it define any mutations of the contract state.

# Example ABI

```rust 
abi MyToken {
    #[storage(read)]
    fn total_assets() -> u64;
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64>;
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String>;
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String>;
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8>;
}
```

# Example Implementation

## [Single Native Assset](../../examples/src20-token/single_asset/src/single_asset.sw)

Example of the SRC-20 implementation where a contract contains a single asset with one `SubId`. This implementation is recommended for users that intend to deploy a single asset with their contract.

## [Multi Native Asset](../../examples/src20-token/multi_asset/src/multi_asset.sw)

Example of the SRC-20 implementation where a contract contains multiple assets with differing `SubId`s. This implementation is recommended for users that intend to deploy multiple assets with their contract.
