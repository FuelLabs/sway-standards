# SRC-10: Native Bridge

The following standard allows for the implementation of a standard API for Native Bridges using the Sway Language. The standardized design has the bridge contract send a message to the origin chain to register which token it accepts to prevent a loss of funds.

## Motivation

A standard interface for bridges intends to provide a safe and efficient bridge between the settlement or canonical chain and the Fuel Network.

## Prior Art

The standard is centered on Fuel’s [Bridge Architecture](https://github.com/FuelLabs/fuel-bridge/blob/main/docs/ARCHITECTURE.md). Fuel's bridge system is built on a message protocol that allows to send (and receive) messages between entities located in two different blockchains.

The following standard takes reference from the [`FungibleBridge`](https://github.com/FuelLabs/fuel-bridge/blob/3971081850e7961d9b649edda4cad8a848ee248e/packages/fungible-token/bridge-fungible-token/src/interface.sw#L22) ABI defined in the fuel-bridge repository.

## Specification

The following functions MUST be implemented to follow the SRC-10; Native Bridge Standard:

### Required Functions

**`fn process_message(message_index: u64)`**

The `process_message()` function accepts incoming deposit messages from the canonical chain and issues the corresponding bridged asset.

- This function MUST parse a message at the given `message_index` index.
- This function SHALL mint an asset that follows the [SRC-8; Bridged Asset Standard](./src-8-bridged-asset.md).
- This function SHALL issue a refund if there is an error in the bridging process.

**`fn withdraw(to_address: b256)`**

The `withdraw()` function accepts and burns a bridged Native Asset on Fuel and sends a message to the bridge contract on the canonical chain to release the originally deposited tokens to the `to_address` address.

- This function SHALL send a message to the bridge contract to release the bridged tokens to the `to_address` address on the canonical chain.
- This function MUST ensure the asset's `AssetId` sent in the transaction matches a bridged asset.
- This function SHALL burn all coins sent in the transaction.

**`fn claim_refund(to_address: b256, token_address: b256, token_id: b256, gateway_contract: b256)`**

The `claim_refund()` function is called if something goes wrong in the bridging process and an error occurs. It sends a message to the `gateway_contract` contract on the canonical chain to release the `token_address` token with token id `token_id` to the `to_address` address.

- This function SHALL send a message to the `gateway_contract` contract to release the `token_address` token with id `token_id` to the `to_address` address on the canonical chain.
- This function MUST ensure a refund was issued.

### Required Data Types

#### `DepositType`

The `DepositType` enum describes whether the bridged deposit is made to a address, contract, or contract and contains additional metadata. There MUST be the following variants in the `DepositType` enum:

**`Address`: `()`**

The `Address` variant MUST represent when the deposit is made to an address on the Fuel chain.

**`Contract`: `()`**

The `Contract` variant MUST represent when the deposit is made to an contract on the Fuel chain.

**`ContractWithData`: `()`**

The `ContractWithData` variant MUST represent when the deposit is made to an contract and contains additional metadata for the Fuel chain.

##### Example Deposit Type

```sway
pub enum DepositType {
    Address: (),
    Contract: (),
    ContractWithData: (),
}
```

#### `DepositMessage`

The following describes a struct that encapsulates various deposit message metadata to a single type. There MUST be the following fields in the `DepositMessage` struct:

**`amount`: `u256`**

The `amount` field MUST represent the number of tokens.

**`from`: `b256`**

The `from` field MUST represent the bridging user’s address on the canonical chain.

**`to`: `Identity`**

The `to` field MUST represent the bridging target destination `Address` or `ContractId` on the Fuel Chain.

**`token_address`: `b256`**

The `token_address` field MUST represent the bridged token's address on the canonical chain.

**`token_id`: `b256`**

The `token_id` field MUST represent the token's ID on the canonical chain. The `b256::zero()` MUST be used if this is a fungible token and no token ID exists.

**`decimals`: `u8`**

The `decimals` field MUST represent the bridged token's decimals on the canonical chain.

**`deposit_type`: `DepositType`**

The `deposit_type` field MUST represent the type of bridge deposit made on the canonical chain.

##### Example Deposit Message

```sway
pub struct DepositMessage {
    pub amount: b256,
    pub from: b256,
    pub to: Identity,
    pub token_address: b256,
    pub token_id: b256,
    pub decimals: u8,
    pub deposit_type: DepositType,
}
```

#### `MetadataMessage`

The following describes a struct that encapsulates the metadata of token on the canonical chain to a single type. There MUST be the following fields in the `MetadataMessage` struct:

**`token_address`: `b256`**

The `token_address` field MUST represent the bridged token's address on the canonical chain.

**`token_id`: `b256`**

The `token_id` field MUST represent the token's ID on the canonical chain. The `b256::zero()` MUST be used if this is a fungible token and no token ID exists.

**`name`: `String`**

The `name` field MUST represent the bridged token's name field on the canonical chain.

**`symbol`: `String`**

The `symbol` field MUST represent the bridged token's symbol field on the canonical chain.

##### Example Metadata Message

```sway
pub struct MetadataMessage {
    pub token_address: b256,
    pub token_id: b256,
    pub name: String,
    pub symbol: String,
}
```

## Required Standards

Any contract that implements the SRC-10; Native Bridge Standard MUST implement the [SRC-8; Bridged Asset Standard](./src-8-bridged-asset.md) for all bridged assets.

## Rationale

The SRC-10; Native Bridge Standard is designed to standardize the native bridge interface between all Fuel instances.

## Backwards Compatibility

This standard is compatible with the SRC-20 and SRC-8 standards.

## Example ABI

```sway
abi SRC10 {
     fn process_message(message_index: u64);
     fn withdraw(to_address: b256);
     fn claim_refund(to_address: b256, token_address: b256, token_id: b256, gateway_contract: b256);
}
```
