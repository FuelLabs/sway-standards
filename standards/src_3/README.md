# Abstract

The following standard enables the minting and burning of tokens for any fungible assets within the Sway Language. It seeks to define mint and burn functions defined separately from the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard. Any contract that implements the SRC-3 standard MUST implement the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard.

# Motivation

The intent of this standard is to separate the extensions of minting and burning from the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard.

# Prior Art

Minting and burning were initially added to the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard.

# Specification

## Required Public Functions

The following functions MUST be implemented to follow the SRC-3 standard:

### `fn mint(recipient: Identity, sub_id: SubId, amount: u64)`

This function MUST mint `amount` tokens with sub-identifier `sub_id` and transfer them to the `recipient`. 
This function MAY contain arbitrary conditions for minting, and revert if those conditions are not met.

##### Arguments

* `recipient` - The `Identity` to which the newly minted tokens are transferred to.
* `sub_id` - The sub-identifier of the asset to mint.
* `amount` - The quantity of tokens to mint.

### `fn burn(sub_id: SubId, amount: u64)`

This function MUST burn `amount` tokens with the sub-identifier `sub_id` and MUST ensure the `AssetId` of the token is the sha-256 hash of `(ContractId, SubId)` for the implementing contract. 
This function MUST ensure at least `amount` tokens have been transferred to the implementing contract. 
This function MUST update the total supply defined in the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard. 
This function MAY contain arbitrary conditions for burning, and revert if those conditions are not met.

##### Arguments

* `sub_id` - The sub-identifier of the asset to burn.
* `amount` - The quantity of tokens to burn.

# Rationale

This standard has been added to enable compatibility between applications and allow minting and burning tokens per use case. This standard has been separated from the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard to allow for the minting and burning for all fungible tokens, irrelevant of whether they are [Native Assets](https://fuellabs.github.io/sway/v0.44.1/book/blockchain-development/native_assets.html) or not.

# Backwards Compatibility

This standard is compatible with Fuel's [Native Assets](https://fuellabs.github.io/sway/v0.38.0/book/blockchain-development/native_assets.html) ensuring its compatibility with the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard.

# Security Considerations

This standard may introduce security considerations if no checks are implemented to ensure the calling of the `mint()` function is deemed valid or permitted. Checks are highly encouraged.
The burn function may also introduce a security consideration if the total supply within the [SRC-20](https://github.com/FuelLabs/sway-standards/tree/master/standards/src_20) standard is not modified.

# Example ABI

```rust
abi MySRC3Token {
    fn mint(recipient: Identity, sub_id: SubId, amount: u64);
    fn burn(sub_id: SubId, amount: u64);
}
```

This draft standard is to be released as `v0.1`. 