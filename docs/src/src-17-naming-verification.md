# SRC-17: Naming Verification Standard

The following standard defines a naming verification standard for onchain identities. 

## Motivation

A standard interface for names on Fuel allows external applications to verify and determine the resolver of a name, whether that be decentralized exchanges frontends, wallets, explorers, or other infrastructure providers.

## Prior Art

A number of existing name service platforms already existed prior to the development of this standard. Notably the most well-known on the Ethereum Blockchain is the [Ethereum Name Service(ENS)](https://ens.domains/). This domain service has a major influence on other name services across multiple platforms. ENS pioneered name service platforms and this standard takes some inspiration from their resolver design.

On Fuel, we have 2 existing name service platforms. These are [Bako ID](https://www.bako.id/) and [Fuel Name Serice(FNS)](https://fuelname.com/). This standard was developed in close collaboration with these two platforms to ensure compatibility and ease of upgrade.

## Specification

### Type Aliases

#### `AltBn128Proof` Type Alias

The following describes a type alias for AltBn128 proofs. The `AltBn128Proof` SHALL be defined as the fixed length array `[u8; 288]`.

```sway
pub type AltBn128Proof = [u8; 288];
```

#### `SparseMerkleProof` Type Alias

The following describes a type alias for Sparse Merkle Tree proofs. The `SparseMerkleProof` SHALL be defined as the `Proof` type from the Sway-Libs Sparse Merkle Tree Library.

```sway
pub type SparseMerkleProof = Proof;
```

### Enums

#### `SRC17VerificationError` Enum

The following describes an enum that is used when verification of a name fails. There SHALL be the following variants in the `SRC17VerificationError` type:

##### `VerificationFailed`

The `VerificationFailed` variant SHALL be used when verification of a name fails for ANY reason.

```sway
pub enum SRC17VerificationError {
    VerificationFailed: (),
}
```

#### `SRC17Proof` Enum

The following describes an enum that wraps various proof types into a single input type. There SHALL be the following variants in the `SRC17Proof` type:

##### `AltBn128Proof`

The `AltBn128Proof` variant SHALL be used for AltBn128 proofs.

##### `SparseMerkleProof` 

The `SparseMerkleProof` variant SHALL be used for Sparse Merkle Tree proofs.

```sway
pub enum SRC17Proof {
    AltBn128Proof: AltBn128Proof,
    SparseMerkleProof: SparseMerkleProof,
}
```

### Required Public Functions

The following functions MUST be implemented to follow the SRC-17 standard:

#### `fn verify(proof: SRC17Proof, name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) -> Result<(), SRC17VerificationError>`

- This function MUST return `Ok(())` if the proof verification was successful. Otherwise, it MUST return `Err(SRC17VerificationError::VerificationFailed)`.
- The `proof` argument MUST be an `SRC17Proof` which proves the `name`, `asset`, `resolver`, and `metadata` are valid and included in the data.
- The `name` argument MUST the corresponding `String` for the onchain human-readable identity.
- The `resolver` argument MUST be the identity which the name is pointing to.
- The `asset` argument MUST be the asset that represents ownership of a name.
- The `metadata` argument MUST contain `Some` bytes associated with the name or MUST be `None`.

### Logging

The following logs MUST be implemented and emitted to follow the SRC-17 standard. Logs MUST be emitted if there are changes that update ANY proof.

#### SRC17NameEvent

The `SRC17NameEvent` MUST be emitted when ANY data changes occur.

There SHALL be the following fields in the `SRC17UpdateEvent` struct:

* `name`: The `name` field SHALL be used for the corresponding `String` which represents the name.
* `resolver`: The `resolver` field SHALL be used for the corresponding `Identity` to which the name points.
* `asset`: The `asset` field SHALL be used for the corresponding `AssetId` that represents ownership of a name.
* `metadata`: The `metadata` field MUST contain `Some` bytes associated with the name or MUST be `None`.

Example:

```sway
pub struct SRC17NameEvent {
    pub name: String,
    pub resolver: Identity,
    pub asset: AssetId,
    pub metadata: Option<Bytes>
}
```

## Rationale

The development and implementation of this standard should enable the verification of names for infrastructure providers such as explorers, wallets, and more. Standardizing the verification method and leaving the implementation up to interpretation shall leave room for experimentation and differentiating designs between projects. 

Additionally, the use of proofs should reduce the onchain footprint and minimize state. This standard notably has no expiry, a feature of most name service platforms. Should a project wish to implement an expiry, it should be included as part of the metadata.

## Backwards Compatibility

This standard is compatible with the existing name standards in the Fuel ecosystem, namely Bako ID and Fuel Name Service(FNS). There are no other standards that require compatibility.

## Security Considerations

This standard does not introduce any security concerns, as it does not call external contracts, nor does it define any mutations of the contract state.

## Example ABI

```sway
pub type AltBn128Proof = [u8; 288];
pub type SparseMerkleProof = Proof;

pub enum SRC17Proof {
    AltBn128Proof: AltBn128Proof,
    SparseMerkleProof: SparseMerkleProof,
}

pub enum SRC17VerificationError {
    VerificationFailed: (),
}

abi SRC17 {
    #[storage(read)]
    fn verify(proof: SRC17Proof, name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) -> Result<(), SRC17VerificationError>;
}
```

## Example Implementation

### Sparse Merkle Verification Example

An example of the SRC-17 implementation where a Sparse Merkle Tree is used to verify the validity of names. In the example, the `name` is the key in the Sparse Merkle Tree and the `asset`, `resolver`, and `metadata` are the data which make up the leaf. The example supports both inclusion and exclusion proofs. If an AltBn128 proof is provided instead, the verification fails.

```sway
{{#include ../examples/src20-native-asset/multi_asset/src/multi_asset.sw}}
```
