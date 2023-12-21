<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-10-logo-dark-theme.png">
        <img alt="SRC-10 logo" width="400px" src=".docs/src-10-logo-light-theme.png">
    </picture>
</p>

# Abstract

The following standard allows for the implementation of a standard API for Native Bridges using the Sway Language. The standardized design has the bridge contract send a message to the origin chain to register which token it accepts to prevent a loss of funds.

# Motivation

A standard interface for bridges intends to provide a safe and efficient bridge between the settlement or canonical chain and the Fuel Network. 

# Prior Art

The standard is centered on Fuel’s [Bridge Architecture](https://github.com/FuelLabs/fuel-bridge/blob/main/docs/ARCHITECTURE.md). Fuel's bridge system is built on a message protocol that allows to send (and receive) messages between entities located in two different blockchains.

The following standard takes reference from the [FungibleBridge](https://github.com/FuelLabs/fuel-bridge/blob/3971081850e7961d9b649edda4cad8a848ee248e/packages/fungible-token/bridge-fungible-token/src/interface.sw#L22) ABI defined in the fuel-bridge repository. 

# Specification

The following functions MUST be implemented to follow the SRC-10; Native Bridge Standard:

## Required Functions

### - `fn register_bridge(token_address: b256, gateway_contract: b256)`

The `register_bridge()` function compiles a message to be sent back to the canonical chain. The `gateway_contract` contract on the canonical chain receives the `token_address` token in the message such that when assets are deposited they are reported to prevent loss of funds. 

> **NOTE:*** Trying to deposit tokens to a contract ID that does not exist or does not implement the Fuel Messaging Portal would mean permanent loss of funds.

- This function MUST send a message on the canonical chain to the `gateway_contract` contract, registering the specified `token_address`. 

### - `fn process_message(message_index: u64)`

The `process_message()` function accepts incoming deposit messages from the canonical chain and issues the corresponding bridged asset.

- This function MUST parse a message at the given `message_index` index. 
- This function SHALL mint a token that follows the [SRC-8; Bridged Asset Standard](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_8). 
- This function SHALL issue a refund if there is an error in the bridging process.

### - `fn withdraw(to_address: b256, sub_id: SubId, gateway_contract: b256)`

The `withdraw()` function accepts and burns a bridged asset and sends a message to the `gateway_contract` contract on the canonical chain to release the originally deposited token to the `to_address` address.

- This function SHALL send a message to the `gateway_contract` contract to release the bridged tokens to the `to_address` address on the canonical chain.
- This function MUST ensure the `sha256(contract_id(), sub_id)` matches the asset's `AssetId` sent in the transaction.
- This function SHALL burn all tokens sent in the transaction.

### - `fn claim_refund(to_address: b256, token_address: b256, token_id: Option<b256>, gateway_contract: b256)`

The `claim_refund()` function is called if something goes wrong in the bridging process and an error occurs. It sends a message to the `gateway_contract` contract on the canonical chain to release the `token_address` token with token id `token_id` to the `to_address` address. 

- This function SHALL send a message to the `gateway_contract` contract to release the `token_address` token with id `token_id` to the `to_address` address on the canonical chain.
- This function MUST ensure a refund was issued.

## Required Data Types

### `MessageData`

The following describes a struct that encapsulates various message metadata to a single type. There MUST be the following fields in the `MessageData` struct:

#### - amount: `u256`

The `amount` field MUST represent the number of tokens.

#### - from: `b256`

The `from` field MUST represent the bridging user’s address on the canonical chain.

#### - len: `u16`

The `len` field MUST represent the number of the deposit messages to discern between deposits that must be forwarded to an EOA vs deposits that must be forwarded to a contract.

#### - to: `Identity`

The `to` field MUST represent the bridging target destination `Address` or `ContractId` on the Fuel Chain.

#### - token_address: `b256`

The `token_address` field MUST represent the bridged token's address on the canonical chain.

#### - token_id: `Option<b256>`

The `token_id` field MUST represent the token's ID on the canonical chain. MUST be `None` if this is a fungible token and no token ID exists.

### Example

```sway 
struct MessageData {
     amount: b256,
     from: b256,
     len: u16,
     to: Identity,
     token_address: b256,
     token_id: Option<b256>,
}
```

## Required Standards

Any contract that implements the SRC-10; Native Bridge Standard MUST implement the [SRC-8; Bridged Asset Standard](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_8) for all bridged assets. 

# Rationale 

The SRC-10; Native Bridge Standard is designed to standardize the native bridge interface between all Fuel instances. 

# Backwards Compatibility

This standard is compatible with the SRC-20 and SRC-8 standards.

# Example ABI

```sway
abi SRC10 {
     fn register_bridge(token_address: b256, gateway_contract: b256);
     fn process_message(message_index: u64);
     fn withdraw(to_address: b256, sub_id: SubId, gateway_contract: b256);
     fn claim_refund(to_address: b256, token_address: b256, token_id: Option<b256>, gateway_contract: b256);
}
```