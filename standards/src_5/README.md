<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-5-logo-dark-theme.png">
        <img alt="SRC-5 logo" width="400px" src=".docs/src-5-logo-light-theme.png">
    </picture>
</p>

# Abstract

The following standard intends to enable the use of administrators or owners in Sway contracts. 

# Motivation

The standard seeks to provide a method for restricting access to particular users within a Sway contract.

# Prior Art

The [sway-libs](https://github.com/FuelLabs/sway-libs) repository contains a pre-existing Ownership library. 

Ownership libraries exist for other ecosystems such as OpenZeppelin's [Ownership library](https://docs.openzeppelin.com/contracts/2.x/api/ownership).

# Specification

## State

There SHALL be 3 states for any library implementing an ownership module in the following order:

### - `Uninitialized`
The `Uninitialized` state SHALL be set as the initial state if no owner or admin is set. The `Uninitialized` state MUST be used when an owner or admin MAY be set in the future.

### - `Initialized`
The `Initialized` state SHALL be set as the state if an owner or admin is set with an associated `Identity` type.

### - `Revoked`
The `Revoked` state SHALL be set when there is no owner or admin and there SHALL NOT be one set in the future.

Example:

```rust
pub enum State {
    Uninitialized: (),
    Initialized: Identity,
    Revoked: (),
}
```

## Functions

The following functions MUST be implemented to follow the SRC-5 standard:

### `fn owner() -> State`
This function SHALL return the current state of ownership for the contract where `State` is either `Uninitialized`, `Initialized`, or `Revoked`.

## Errors

There SHALL be error handling.

### - `NotOwner`
This error MUST be emitted when `only_owner()` reverts.

# Rationale

In order to provide a universal method of administrative capabilities, SRC-5 will further enable interoperability between applications and provide safeguards for smart contract security.

# Backwards Compatability

The SRC-5 standard is compatible with the [sway-libs](https://github.com/FuelLabs/sway-libs) repository pre-existing Ownership library. Considerations should be made to best handle multiple owners or admins.

There are no standards that SRC-5 requires to be compatible with.

# Security Considerations

The SRC-5 standard should help improve the security of Sway contracts and their interoperability.

# Examples ABI

```rust
abi SRC5 {
    #[storage(read)]
    fn owner() -> State;
}
```

# Example Implementation

## [Uninitalized](../../examples/src_5/uninitialized_example/)

Example of the SRC-5 implementation where a contract does not have an owner set at compile time with the intent to set it during runtime.

## [Initialized](../../examples/src_5/initialized_example/)

Example of the SRC-5 implementation where a contract has an owner set at compile time.
