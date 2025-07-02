# SRC-16: Typed Structured Data

The following standard sets out to standardize encoding and hashing of typed structured data. This enables secure off-chain message signing with human-readable data structures.

## Motivation

As the Fuel ecosystem expands, there's an increasing need for applications to handle complex, human-readable data structures rather than raw bytes. When users sign messages or transactions, they should be able to clearly understand what they're signing, whether it's a simple asset transfer, or a complex DeFi interaction. Without a standard method for hashing structured data, developers risk implementing their own solutions, which could lead to confusion or compromise security. This standard provides a secure and consistent way to handle encoding and hashing of structured data, ensuring both safety and usability within ecosystem.

This standard aims to:

* Provide a secure, standardized method for hashing structured data
* Enable clear presentation of structured data for user verification during signing
* Support complex data types that mirror Sway structs
* Enable domain separation to prevent cross-protocol replay attacks
* Define a consistent encoding scheme for structured data types
* Remain stateless, not requiring any storage attributes to enable use across all Fuel program types.

## Prior Art

This standard uses ideas from [Ethereum's EIP-712 standard](https://eips.ethereum.org/EIPS/eip-712), adapting its concepts for the Fuel ecosystem. EIP-712 has proven successful in enabling secure structured data signing for applications like the various browser based wallets and signers that are utilized throughout various DeFi protocols.

## Specification

### Definition of Typed Structured Data 𝕊

The set of structured data 𝕊 consists of all instances of struct types that can be composed from the following types:

Atomic Types:

```sway
u8 to u256
bool
b256 (hash)
```

Dynamic Types:

```sway
Bytes   // Variable-length byte sequences
String  // Variable-length strings
```

Reference Types:

Arrays (both fixed size and dynamic)
Structs (reference to other struct types)

Example struct definition:

```sway
struct Mail {
    from: Address,
    to: Address,
    contents: String,
}
```

### Domain Separator Encoding

The domain separator provides context for the signing operation, preventing cross-protocol replay attacks. It is computed as hash_struct(domain) where domain is defined as:

```sway
pub struct SRC16Domain {
    name: String,                   // The protocol name (e.g., "MyProtocol")
    version: String,                // The protocol version (e.g., "1")
    chain_id: u64,                  // The Fuel chain ID
    verifying_contract: ContractId, // The contract id that will verify the signature
}
```

The `chain_id` field is a u64 that must be encoded by left-padding with zeros and packed in big-endian order to fill a 32-byte value.

The domain separator encoding follows this scheme:

* Add SRC16_DOMAIN_TYPE_HASH
* Add Keccak256 hash of name string
* Add Keccak256 hash of version string
* Add chain ID as 32-byte big-endian
* Add verifying contract id as 32 bytes

## Type Encoding

Each struct type is encoded as name ‖ "(" ‖ member₁ ‖ "," ‖ member₂ ‖ "," ‖ … ‖ memberₙ ")" where each member is written as type ‖ " " ‖ name.

Example:

```sway
Mail(address from,address to,string contents)
```

## Data Encoding

### Definition of hash_struct

The hash_struct function is defined as:

hash_struct(s : 𝕊) = keccak256(type_hash ‖ encode_data(s))
where:

* type_hash = keccak256(encode_type(type of s))
* ‖ represents byte concatenation
* encode_type and encode_data are defined below

### Definition of encode_data

The encoding of a struct instance is enc(value₁) ‖ enc(value₂) ‖ … ‖ enc(valueₙ), the concatenation of the encoded member values in the order they appear in the type. Each encoded member value is exactly 32 bytes long.

The values are encoded as follows:

Atomic Values:

* Boolean false and true are encoded as u64 values 0 and 1, padded to 32 bytes
* `Address`, `ContractId`, `Identity`, and `b256` are encoded directly as 32 bytes
* Unsigned Integer values (u8 to u256) are encoded as big-endian bytes, padded to 32 bytes

Dynamic Types:

* `Bytes` and `String` are encoded as their Keccak256 hash

Reference Types:

* Arrays (both fixed and dynamic) are encoded as the Keccak256 hash of their concatenated encodings
* Struct values are encoded recursively as hash_struct(value)

The implementation of `TypedDataHash` for `𝕊` SHALL utilize the `DataEncoder` for encoding each element of the struct based on its type.

## Final Message Encoding

The encoding of structured data follows this pattern:

encode(domain_separator : 𝔹²⁵⁶, message : 𝕊) = "\x19\x01" ‖ `domain_separator` ‖ `hash_struct`(message)

where:

* \x19\x01 is a constant prefix
* ‖ represents byte concatenation
* `domain_separator` is the 32-byte hash of the domain parameters
* `hash_struct`(message) is the 32-byte hash of the structured data

## Example implementation

```sway
const MAIL_TYPE_HASH: b256 = 0x536e54c54e6699204b424f41f6dea846ee38ac369afec3e7c141d2c92c65e67f;

impl TypedDataHash for Mail {

    fn type_hash() -> b256 {
        MAIL_TYPE_HASH
    }

    fn struct_hash(self) -> b256 {
        let mut encoded = Bytes::new();
        encoded.append(
            MAIL_TYPE_HASH.to_be_bytes()
        );
        encoded.append(
            DataEncoder::encode_address(self.from).to_be_bytes()
        );
        encoded.append(
            DataEncoder::encode_address(self.to).to_be_bytes()
        );
        encoded.append(
            DataEncoder::encode_string(self.contents).to_be_bytes()
        );

        keccak256(encoded)
    }
}
```

## Rationale

* Domain separators provides protocol-specific context to prevent signature replay across different protocols and chains.
* Type hashes ensure type safety and prevent collisions between different data structures
* The encoding scheme is designed to be deterministic and injective
* The standard maintains compatibility with existing Sway types and practices

## Backwards Compatibility

This standard is compatible with existing Sway data structures and can be implemented alongside other Fuel standards. It does not conflict with existing signature verification methods.

### Type System Compatibility Notes

When implementing SRC16 in relation to EIP712, the following type mappings and considerations apply:

#### String Encoding

* Both standards use the same String type and encoding
* SRC16 specifically uses String type only (not Sway's `str` or `str[]`)
* String values are encoded identically in both standards using keccak256 hash

#### Fixed Bytes

* EIP712's `bytes32` maps directly to Sway's `b256`
* Encoded using `encode_b256` in the `DataEncoder`
* Both standards handle 32-byte values identically
* Smaller fixed byte arrays (`bytes1` to `bytes31`) are not supported in SRC16

#### Address Types

* EIP712 uses 20-byte Ethereum addresses
* When encoding an EIP712 address, SRC16:
  * Takes only rightmost 20 bytes from a 32-byte Fuel Address
  * Pads with zeros on the left for EIP712 compatibility
  * Example: Fuel `Address` of 32 bytes becomes rightmost 20 bytes in EIP712 encoding

#### ContractId Handling

* `ContractId` is unique to Fuel/SRC16 (no equivalent in EIP712)
* When encoding for EIP712 compatibility:
  * Uses rightmost 20 bytes of `ContractId`
  * Particularly important in domain separators where EIP712 expects a 20-byte address

#### Domain Separator Compatibility

```sway
// SRC16 Domain (Fuel native)
pub struct SRC16Domain {
    name: String,                   // Same as EIP712
    version: String,                // Same as EIP712
    chain_id: u64,                  // Fuel chain ID
    verifying_contract: ContractId, // Full 32-byte ContractId
}

// EIP712 Domain (Ethereum compatible)
pub struct EIP712Domain {
    name: String,
    version: String,
    chain_id: u256,
    verifying_contract: b256,      // Only rightmost 20 bytes used
}
```

Note on `verifying_contract` field; When implementing EIP712 compatibility within SRC16, the `verifying_contract` address in the `EIP712Domain` must be constructed by taking only the rightmost 20 bytes from either a Fuel `ContractId`. This ensures proper compatibility with Ethereum's 20-byte addressing scheme in the domain separator.

```sway
// Example ContractId conversion:
// Fuel ContractId (32 bytes):
//   0x000000000000000000000000a2233d3bf2aa3f0cbbe824eb04afc1acc84c364c
//                            └─────────────── 20 bytes ───────────────┘
//
// EIP712 Address (20 bytes):
//   0xa2233d3bf2aa3f0cbbe824eb04afc1acc84c364c
//    └─────────────── 20 bytes ───────────────┘
```

Note on EIP712 Domain Separator `salt`; Within EIP712 the field `salt` is an optional field to be used at the discretion of the protocol designer. Within SRC16 the `EIP712Domain` does not use the `salt` field. The other fields in `EIP712Domain` are mandatory within SRC16.

## Security Considerations

### Replay Attacks

Implementations must ensure signatures cannot be replayed across:

Different chains (prevented by chain_id)
Different protocols (prevented by domain separator)
Different contracts (prevented by verifying_contract)

### Type Safety

Implementations must validate all type information and enforce strict encoding rules to prevent type confusion attacks.

## Example Implementation

Example of the SRC16 implementation where a contract utilizes the encoding scheme to produce a typed structured data hash of the Mail type.

```sway
contract;

use src16::{
    DataEncoder,
    DomainHash,
    SRC16,
    SRC16Base,
    SRC16Domain,
    SRC16Encode,
    SRC16Payload,
    TypedDataHash,
};
use std::{bytes::Bytes, contract_id::*, hash::*, string::String};

configurable {
    /// The name of the signing domain.
    DOMAIN: str[8] = __to_str_array("MyDomain"),
    /// The current major version for the signing domain.
    VERSION: str[1] = __to_str_array("1"),
    /// The active chain ID where the signing is intended to be used. Cast to u256 in domain_hash
    CHAIN_ID: u64 = 9889u64,
}

/// A demo struct representing a mail message
pub struct Mail {
    /// The sender's address
    pub from: Address,
    /// The recipient's address
    pub to: Address,
    /// The message contents
    pub contents: String,
}

/// The Keccak256 hash of the type Mail as UTF8 encoded bytes.
///
/// "Mail(address from,address to,string contents)"
///
/// 536e54c54e6699204b424f41f6dea846ee38ac369afec3e7c141d2c92c65e67f
///
const MAIL_TYPE_HASH: b256 = 0x536e54c54e6699204b424f41f6dea846ee38ac369afec3e7c141d2c92c65e67f;

impl TypedDataHash for Mail {
    fn type_hash() -> b256 {
        MAIL_TYPE_HASH
    }

    fn struct_hash(self) -> b256 {
        let mut encoded = Bytes::new();
        // Add the Mail type hash.
        encoded.append(MAIL_TYPE_HASH.to_be_bytes());
        // Use the DataEncoder to encode each field for known types
        encoded.append(DataEncoder::encode_address(self.from).to_be_bytes());
        encoded.append(DataEncoder::encode_address(self.to).to_be_bytes());
        encoded.append(DataEncoder::encode_string(self.contents).to_be_bytes());

        keccak256(encoded)
    }
}

/// Implement the encode function for Mail using SRC16Payload
///
/// # Additional Information
///
/// 1. Get the encodeData hash of the Mail typed data using
///    <Mail>..struct_hash();
/// 2. Obtain the payload to by populating the SRC16Payload struct
///    with the domain separator and data_hash from the previous step.
/// 3. Obtain the final_hash [Some(b256)] or None using the function
///    SRC16Payload::encode_hash()
///
impl SRC16Encode<Mail> for Mail {
    fn encode(s: Mail) -> b256 {
        // encodeData hash
        let data_hash = s.struct_hash();
        // setup payload
        let payload = SRC16Payload {
            domain: _get_domain_separator(),
            data_hash: data_hash,
        };

        // Get the final encoded hash
        match payload.encode_hash() {
            Some(hash) => hash,
            None => revert(0),
        }
    }
}

impl SRC16Base for Contract {
    fn domain_separator_hash() -> b256 {
        _get_domain_separator().domain_hash()
    }

    fn data_type_hash() -> b256 {
        MAIL_TYPE_HASH
    }
}

impl SRC16 for Contract {
    fn domain_separator() -> SRC16Domain {
        _get_domain_separator()
    }
}

abi MailMe {
    fn send_mail_get_hash(from_addr: Address, to_addr: Address, contents: String) -> b256;
}

impl MailMe for Contract {
    /// Sends a some mail and returns its encoded hash
    ///
    /// # Arguments
    ///
    /// * `from_addr`: [Address] - The sender's address
    /// * `to_addr`: [Address] - The recipient's address
    /// * `contents`: [String] - The message contents
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded hash of the mail data
    ///
    fn send_mail_get_hash(from_addr: Address, to_addr: Address, contents: String) -> b256 {
        // Create the mail struct from data passed in call
        let some_mail = Mail {
            from: from_addr,
            to: to_addr,
            contents: contents,
        };

        Mail::encode(some_mail)
    }
}

/// A program specific implementation to get the Fuel SRC16Domain
///
/// In a Contract the ContractID can be obtain with ContractId::this()
///
/// In a Predicate or Script it is at the implementors discretion to
/// use the code root if they wish to contrain the validation to a
/// specifc program.
///
fn _get_domain_separator() -> SRC16Domain {
    SRC16Domain::new(
        String::from_ascii_str(from_str_array(DOMAIN)),
        String::from_ascii_str(from_str_array(VERSION)),
        CHAIN_ID,
        ContractId::this(),
    )
}
```

```sway
contract;

use src16::{
    DataEncoder,
    DomainHash,
    EIP712,
    EIP712Domain,
    SRC16Base,
    SRC16Encode,
    SRC16Payload,
    TypedDataHash,
};
use std::{bytes::Bytes, contract_id::*, hash::*, string::String};

configurable {
    /// The name of the signing domain.
    DOMAIN: str[8] = __to_str_array("MyDomain"),
    /// The current major version for the signing domain.
    VERSION: str[1] = __to_str_array("1"),
    /// The active chain ID where the signing is intended to be used. Cast to u256 in domain_hash
    CHAIN_ID: u64 = 9889u64,
}

/// A demo struct representing a mail message
pub struct Mail {
    /// The sender's address
    pub from: b256,
    /// The recipient's address
    pub to: b256,
    /// The message contents
    pub contents: String,
}

/// The Keccak256 hash of the type Mail as UTF8 encoded bytes.
///
/// "Mail(bytes32 from,bytes32 to,string contents)"
///
/// cfc972d321844e0304c5a752957425d5df13c3b09c563624a806b517155d7056
///
const MAIL_TYPE_HASH: b256 = 0xcfc972d321844e0304c5a752957425d5df13c3b09c563624a806b517155d7056;

impl TypedDataHash for Mail {
    fn type_hash() -> b256 {
        MAIL_TYPE_HASH
    }

    fn struct_hash(self) -> b256 {
        let mut encoded = Bytes::new();

        // Add the Mail type hash.
        encoded.append(MAIL_TYPE_HASH.to_be_bytes());
        // Use the DataEncoder to encode each field for known types
        encoded.append(DataEncoder::encode_b256(self.from).to_be_bytes());
        encoded.append(DataEncoder::encode_b256(self.to).to_be_bytes());
        encoded.append(DataEncoder::encode_string(self.contents).to_be_bytes());

        keccak256(encoded)
    }
}

/// Implement the encode function for Mail using SRC16Payload
///
/// # Additional Information
///
/// 1. Get the encodeData hash of the Mail typed data using
///    <Mail>..struct_hash();
/// 2. Obtain the payload to by populating the SRC16Payload struct
///    with the domain separator and data_hash from the previous step.
/// 3. Obtain the final_hash [Some(b256)] or None using the function
///    SRC16Payload::encode_hash()
///
impl SRC16Encode<Mail> for Mail {
    fn encode(s: Mail) -> b256 {
        // encodeData hash
        let data_hash = s.struct_hash();
        // setup payload
        let payload = SRC16Payload {
            domain: _get_domain_separator(),
            data_hash: data_hash,
        };

        // Get the final encoded hash
        match payload.encode_hash() {
            Some(hash) => hash,
            None => revert(0),
        }
    }
}

impl SRC16Base for Contract {
    fn domain_separator_hash() -> b256 {
        _get_domain_separator().domain_hash()
    }

    fn data_type_hash() -> b256 {
        MAIL_TYPE_HASH
    }
}

impl EIP712 for Contract {
    fn domain_separator() -> EIP712Domain {
        _get_domain_separator()
    }
}

abi MailMe {
    fn send_mail_get_hash(from_addr: b256, to_addr: b256, contents: String) -> b256;
}

impl MailMe for Contract {
    /// Sends a some mail and returns its encoded hash
    ///
    /// # Arguments
    ///
    /// * `from_addr`: [b256] - The sender's address
    /// * `to_addr`: [b256] - The recipient's address
    /// * `contents`: [String] - The message contents
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded hash of the mail data
    ///
    fn send_mail_get_hash(from_addr: b256, to_addr: b256, contents: String) -> b256 {
        // Create the mail struct from data passed in call
        let some_mail = Mail {
            from: from_addr,
            to: to_addr,
            contents: contents,
        };

        Mail::encode(some_mail)
    }
}

/// A program specific implementation to get the Ethereum EIP712Domain
///
/// In a Contract the ContractID can be obtain with ContractId::this()
///
/// In a Predicate or Script it is at the implementors discretion to
/// use the code root if they wish to contrain the validation to a
/// specifc program.
///
fn _get_domain_separator() -> EIP712Domain {
    EIP712Domain::new(
        String::from_ascii_str(from_str_array(DOMAIN)),
        String::from_ascii_str(from_str_array(VERSION)),
        (asm(r1: (0, 0, 0, CHAIN_ID)) {
                r1: u256
            }),
        ContractId::this(),
    )
}
```
