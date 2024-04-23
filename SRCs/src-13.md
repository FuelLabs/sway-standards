<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-13-logo-dark-theme.png">
        <img alt="SRC-13 logo" width="400px" src=".docs/src-13-logo-light-theme.png">
    </picture>
</p>

# Abstract

The following standard allows for the implementation of Soulbound Address on the Fuel Network. Soulbound Assets are [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) sent to the Soulbound Address and cannot be transferred. As Native Assets on the Fuel Network do not require approvals to be spent, any asset sent to an `Address` may be transferable. The SRC-13 standard provides a predicate interface to lock Native Assets as soulbound. 

# Motivation

A standard enables soulbound assets on Fuel and allows external applications to query and provide soulbound assets, whether that be decentralized exchanges, wallets, or other external applications. 

# Prior Art

[Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) on the Fuel Network do not require the implementation of certain functions such as transfer or approval. This is done directly within the FuelVM and there is no smart contract that requires updating of balances. As such, any assets sent to an `Address` may be spendable and ownership of that asset may be transferred. For any soulbound assets, spending must be restricted. 

Predicates are programs that return a Boolean value and which represent ownership of some resource upon execution to true. All predicates evaluate to an `Address` based on their bytecode root. A predicate must evaluate to true such that the assets may be spent.

The SRC-13 Soulbound Asset Standard naming pays homage to the [ERC-5192: Minimal Soulbound NFTs](https://eips.ethereum.org/EIPS/eip-5192) seen on Ethereum. While there is functionality we may use as a reference, it is noted that Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) are fundamentally different than Ethereum's tokens.

# Specification

## Overview

To ensure that some asset shall never be spent, we must apply spending conditions. This can be done with Predicates on Fuel. Any asset sent to a Predicate `Address` shall never be spent if the predicate never evaluates to true.

We must also ensure every `Address` on Fuel has its own Predicate. This can be guaranteed by using a `configurable` where an `Address` is defined.

## Definitions

- **Soulbound Address Predicate** - The resulting predicate which owns assets on behalf of an `Address`.
- **Soulbound Address** - The computed `Address` of the *Soulbound Asset Predicate*.
- **Soulbound Asset** - Any [Native Asset](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) sent to the *Soulbound Address*.

## Soulbound Address Predicate Specification

- The *Soulbound Address Predicate* SHALL never spend the assets sent to its computed predicate `Address` or *Soulbound Address*.
- The *Soulbound Address Predicate* SHALL encode an `Address` of which it represents the soulbound address.

Below we define the *Soulbound Address Predicate* where `ADDRESS` MUST be replaced with the `Address` of which the *Soulbound Address Predicate* represents.

```sway
predicate;

configurable {
    ADDRESS: Address = Address::from(0x0000000000000000000000000000000000000000000000000000000000000000),
}

fn main() -> bool {
    asm (address: ADDRESS) { address: b256 };
    false
}
```

## Soulbound Address 

The *Soulbound Address* is the *Soulbound Address Predicate*'s predicate address. A predicate's address(the bytecode root) is defined [here](https://github.com/FuelLabs/fuel-specs/blob/master/src/identifiers/predicate-id.md). 

The *Soulbound Address* may be computed from the  *Soulbound Address Predicate*'s bytecode both on-chain or off-chain. For off-chain computation, please refer to the fuels-rs [predicate docs](https://docs.fuel.network/docs/fuels-rs/predicates/). For on-chain computation, please refer to Sway-Lib's [Bytecode Library](https://github.com/FuelLabs/sway-libs/tree/master/libs/bytecode).

# Rationale

On the Fuel Network, the process for sending any [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) is the same and does not require any approval. This means that any assets sent to an Address may be spendable and does not require any external spending conditions. In the case of a soulbound asset, we need to ensure the asset cannot be spent.

# Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) and the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src20-native-asset) standard.

# Security Considerations

This standard does not introduce any security concerns, as it does not call external contracts, nor does it define any mutations of the contract state.

It should however be noted that any Native Asset on the Fuel Network is not a Soulbound Asset until it is sent to a *Soulbound Address*.

# Example

The following example shows the *Soulbound Address Predicate* for the `0xe033369a522e3cd2fc19a5a705a7f119938027e8e287c0ec35b784e68dab2be6` `Address`. 

The resulting *Soulbound Address* is `0x7f28a538d06788a3d98bb72f4b41012d86abc4b0369ee5dedf56cfbaf245d609`. Any Native Assets sent to this address will become Soulbound Assets.

```sway 
predicate;

configurable {
    ADDRESS: Address = Address::from(0xe033369a522e3cd2fc19a5a705a7f119938027e8e287c0ec35b784e68dab2be6),
}

fn main() -> bool {
    asm (address: ADDRESS) { address: b256 };
    false
}
```
