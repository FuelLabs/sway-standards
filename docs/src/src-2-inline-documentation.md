# SRC-2: Inline Documentation

The following standard intends to define the structure and organization of inline documentation for functions, structs, enums, storage, configurables, and more within the Sway Language. This is a living standard.

## Motivation

The standard seeks to provide a better developer experience using Fuel's tooling and the Language Server. This will allow for better interoperability between applications and enable developers to quickly understand any external code they are using or implementing.

## Prior Art

A number of pre-existing functions in the [sway standard library](https://fuellabs.github.io/sway/master/std/), [sway-applications](https://github.com/FuelLabs/sway-applications), and [sway-libs](https://docs.fuel.network/docs/sway-libs/) repositories have inline documentation. The inline documentation for these is already compatible with Fuel's VS Code extension. These however do not all follow the same structure and outline.

## Specification

### Functions

The following describes the structure and order of inline documentation for functions. Some sections MAY NOT apply to each function. When a section is not relevant it SHALL be omitted.

#### Functions: Description

This section has no header.
A simple explanation of the function's intent or functionality.
Example:

```sway
/// This function computes the hash of two numbers.
```

#### Functions: Additional Information

This section has a `h1` header.
This section is directly below the description and can provide additional information beyond the function's intent or functionality.
Example:

```sway
/// # Additional Information
///
/// This function also has some complex behaviors.
```

#### Functions: Arguments

This section has a `h1` header.
Lists the arguments of the function's definition with the `*` symbol and describes each one. The list SHALL provide the name, type, and description. The argument SHALL be encapsulated between two backticks: `argument`. The type SHALL be encapsulated between two square brackets: [type].
Example:

```sway
/// # Arguments
///
/// * `argument_1`: [Identity] - This argument is a user to be hashed.
```

#### Functions: Returns

This section has a `h1` header.
Lists the return values of the function with the `*` symbol and describes each one. This list SHALL be in the order of the return index and provide the type and description. The type SHALL be encapsulated between two square brackets: [type].
Example:

```sway
/// # Returns
///
/// * [u64] - The number of hashes performed.
```

#### Functions: Reverts

This section has a `h1` header.
Lists the cases in which the function will revert starting with the `*` symbol. The list SHALL be in the order of occurrence within the function.
Example:

```sway
/// # Reverts
///
/// * When `argument_1` or `argument_2` are a zero [b256].
```

#### Functions: Number of Storage Accesses

This section has a `h1` header.
Provides information on how many storage reads, writes, and clears occur within the function.
Example:

```sway
/// # Number of Storage Accesses
///
/// * Reads: `1`
/// * Clears: `2`
```

#### Functions: Examples

This section has a `h1` header.
This section provides an example of the use of the function. This section is not required to follow the SRC-2 standard however encouraged for auxiliary and library functions.
Example:

```sway
/// # Examples
///
/// ```sway
/// fn foo(argument_1: b256, argument_2: b256) {
///     let result = my_function(argument_1, argument_2);
/// }
```

### Structs

The following describes the structure and order of inline documentation for structs. Some sections MAY NOT apply to each struct. When a section is not relevant it SHALL be omitted.

#### Structs: Description

This section has no header.
A simple explanation of the struct's purpose or functionality.
Example:

```sway
/// This struct contains information on an NFT.
```

#### Structs: Additional Information

This section has a `h1` header.
This section is directly below the description and can provide additional information beyond the struct's purpose or functionality.
Example:

```sway
/// # Additional Information
///
/// This struct also has some complex behaviors.
```

### Fields

The following describes the structure and order of inline documentation for fields within structs. Some sections MAY NOT apply to each field. When a section is not relevant it SHALL be omitted.

#### Fields: Description

This section has no header.
Each field SHALL have its own description with a simple explanation of the field's purpose or functionality.
Example:

```sway
/// This field represents an owner.
field_1: Identity,
```

#### Fields: Additional Information

This section has a `h1` header.
This section is directly below the description and can provide additional information beyond the field's purpose or functionality.
Example:

```sway
/// # Additional Information
///
/// This field also has some complex behaviors.
```

### Enums

The following describes the structure and order of inline documentation for enums. Some sections MAY NOT apply to each enum. When a section is not relevant it SHALL be omitted.

#### Enums: Description

This section has no header.
A simple explanation of the enum's purpose or functionality.
Example:

```sway
/// This enum holds the state of a contract.
```

#### Enums: Additional Information

This section has a `h1` header.
This section is directly below the description and can provide additional information beyond the enum's purpose or functionality.
Example:

```sway
/// # Additional Information
///
/// This enum also has some complex behaviors.
```

### Variant

The following describes the structure and order of inline documentation for fields within enums. Some sections MAY NOT apply to each field. When a section is not relevant it SHALL be omitted.

#### Variant: Description

This section has no header.
Each variant SHALL have its own description with a simple explanation of the variant's purpose or functionality.
Example:

```sway
/// This variant represents the uninitialized state of a contract.
variant_1: (),
/// This variant represents the initialized state of a contract.
variant_2: Identity,
```

#### Variant: Additional Information

This section has a `h1` header.
This section is directly below the description and can provide additional information beyond the variant's purpose or functionality.
Example:

```sway
/// # Additional Information
///
/// This variant also has some complex behaviors.
```

### Errors

In Sway, errors are recommended to be enums. They SHALL follow the same structure and order for inline documentation as described above for enums. Some sections MAY NOT apply to each error. When a section is not relevant it SHALL be omitted.

### Logs

In Sway, logs are recommended to be structs. They SHALL follow the same structure and order for inline documentation as described above for structs. Some sections MAY NOT apply to each log. When a section is not relevant it SHALL be omitted.

### Storage

The following describes the structure and order of inline documentation for variables within the storage block. Some sections MAY NOT apply to each storage variable. When a section is not relevant it SHALL be omitted.

#### Storage: Description

This section has no header.
A simple explanation of the storage variable's purpose or functionality.
Example:

```sway
/// This storage variable is used for state.
```

#### Storage: Additional Information

This section has a `h1` header.
This section is directly below the description and can provide additional information beyond the storage variable's purpose or functionality.
Example:

```sway
/// # Additional Information
///
/// This storage variable maps a user to a state.
```

### Configurable

The following describes the structure and order of inline documentation for variables in the configurable block. Some sections MAY NOT apply to each storage variable. When a section is not relevant it SHALL be omitted.

#### Configurable: Description

This section has no header.
A simple explanation of the configurable variable's purpose or functionality.
Example:

```sway
/// This configurable variable is used for an address.
```

#### Configurable: Additional Information

This section has a `h1` header.
This section is directly below the description and can provide additional information beyond the configurable variable's purpose or functionality.
Example:

```sway
/// # Additional Information
///
/// This configurable variable makes security assumptions.
```

### Other Sections

If the above described sections are not relevant for the information that needs to documented, a custom section with a arbitrary `h1` header may be utilized.

Example:

```sway
/// # Recommended Message Style
///
/// We recommend that `expect` messages are used to describe the reason you *expect* the `Option` should be `Some`.
```

## Rationale

The SRC-2 standard should help provide developers with an easy way to both quickly write inline documentation and get up to speed on other developers' code. This standard in combination with Fuel's VS Code extension provides readily accessible information on functions, structs, and enums

![Screenshot 2023-05-10 125656](https://github.com/FuelLabs/sway-standards/assets/54727135/f03073b9-2a28-44d1-b12a-5603a0738fee)

## Backwards Compatibility

There are no standards that the SRC-2 standard requires to be backward compatible with.

## Security Considerations

This standard will improve security by providing developers with relevant information such as revert cases.

## Examples

### Function Example

```sway
/// Ensures that the sender is the owner.
///
/// # Arguments
///
/// * `number`: [u64] - A value that is checked to be 5.
///
/// # Returns
///
/// * [bool] - Determines whether `number` is or is not 5.
///
/// # Reverts
///
/// * When the sender is not the owner.
///
/// # Number of Storage Accesses
///
/// * Reads: `1`
///
/// # Examples
///
/// ```sway
/// use ownable::Ownership;
///
/// storage {
///     owner: Ownership = Ownership::initialized(Identity::Address(Address::zero())),
/// }
///
/// fn foo() {
///     storage.owner.only_owner();
///     // Do stuff here
/// }
#[storage(read)]
pub fn only_owner(self, number: u64) -> bool {
    require(self.owner() == State::Initialized(msg_sender().unwrap()), AccessError::NotOwner);
    number == 5
}
```

### Struct Examples

```sway
/// Metadata that is tied to an asset.
pub struct NFTMetadata {
    /// Represents the ID of this NFT.
    value: u64,
}
```

```sway
/// Log of a bid.
pub struct Bid {
    /// The number of coins that were bid.
    amount: u64,
    /// The user which placed this bid.
    bidder: Identity,
}
```

### Enum Examples

```sway
/// Determines the state of ownership.
pub enum State {
    /// The ownership has not been set.
    Uninitialized: (),
    /// The user who has been given ownership.
    Initialized: Identity,
    /// The ownership has been given up and can never be set again.
    Revoked: (),
}
```

```sway
/// Error log for when access is denied.
pub enum AccessError {
    /// Emitted when the caller is not the owner of the contract.
    NotOwner: (),
}
```

### Storage Examples

```sway
storage {
    /// An asset which is to be distributed.
    asset: Option<AssetId> = Option::None,
    /// Stores the ClaimState of users that have interacted with the Airdrop Distributor contract.
    ///
    /// # Additional Information
    ///
    /// Maps (user => claim)
    claims: StorageMap<Identity, ClaimState> = StorageMap {},
}
```

### Configurable Example

```sway
configurable {
    /// The threshold required for activation.
    THRESHOLD: u64 = 5,
}
```
