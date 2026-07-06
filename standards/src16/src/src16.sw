library;

use std::{bytes::Bytes, hash::*, string::String};
use std::bytes_conversions::{b256::*, u256::*, u64::*};

/// Contains the core parameters that uniquely identify a domain for typed
/// data signing on Fuel. All fields are optional; only the fields that are
/// Some are included in the type hash string and encoded data, allowing the
/// domain to be constructed with only the parameters required by the application.
pub struct SRC16Domain {
    /// The name of the signing domain
    name: Option<String>,
    /// The current major version of the signing domain
    version: Option<String>,
    /// The active chain ID where the signing is intended to be used
    chain_id: Option<u256>,
    /// The contract id of the contract that will verify the signature
    verifying_contract: Option<ContractId>,
    /// A disambiguating salt
    salt: Option<b256>,
}

impl SRC16Domain {
    /// Creates a new SRC16Domain instance with the provided parameters
    ///
    /// # Arguments
    ///
    /// * `name`: [Option<String>] - The name of the signing domain
    /// * `version`: [Option<String>] - The version of the signing domain
    /// * `chain_id`: [Option<u256>] - The chain ID where the contract is deployed
    /// * `verifying_contract`: [Option<ContractId>] - The contract that will verify the signature
    /// * `salt`: [Option<b256>] - An optional disambiguating salt
    ///
    /// # Returns
    ///
    /// * [SRC16Domain] - A new instance of SRC16Domain with the provided parameters
    ///
    pub fn new(
        name: Option<String>,
        version: Option<String>,
        chain_id: Option<u256>,
        verifying_contract: Option<ContractId>,
        salt: Option<b256>,
    ) -> SRC16Domain {
        SRC16Domain {
            name,
            version,
            chain_id,
            verifying_contract,
            salt,
        }
    }

    /// Computes the Keccak256 hash of the encoded domain parameters
    ///
    /// # Additional Information
    ///
    /// Dynamically builds the type hash string including only the fields that are
    /// Some. Uses raw k256 assembly to hash string values and the final encoded
    /// buffer directly, avoiding length-prefixed stdlib encoding.
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the encoded domain parameters
    ///
    pub fn domain_hash(self) -> b256 {
        let mut encoded: [b256; 6] = [
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
        ];
        let mut type_hash_string = Bytes::new();
        let mut total_bytes = 32;
        let mut needs_comma = false;

        type_hash_string.append(String::from_ascii_str("SRC16Domain(").as_bytes());

        if self.name.is_some() {
            type_hash_string.append(String::from_ascii_str("string name").as_bytes());
            asm(
                ptr: self.name.unwrap().ptr(),
                len: self.name.unwrap().as_str().len(),
                dst: encoded,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                k256 offset_ptr ptr len;
            }
            total_bytes += 32;
            needs_comma = true;
        }

        if self.version.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",string version").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("string version").as_bytes());
            }
            asm(
                ptr: self.version.unwrap().ptr(),
                len: self.version.unwrap().as_str().len(),
                dst: encoded,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                k256 offset_ptr ptr len;
            }
            total_bytes += 32;
            needs_comma = true;
        }

        if self.chain_id.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",u256 chain_id").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("u256 chain_id").as_bytes());
            }
            asm(
                dst: encoded,
                src: self.chain_id.unwrap(),
                bytes: 32,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                mcp offset_ptr src bytes;
            };
            total_bytes += 32;
            needs_comma = true;
        }

        if self.verifying_contract.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",contractId verifying_contract").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("contractId verifying_contract").as_bytes());
            }
            asm(
                dst: encoded,
                src: self.verifying_contract.unwrap(),
                bytes: 32,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                mcp offset_ptr src bytes;
            };
            total_bytes += 32;
            needs_comma = true;
        }

        if self.salt.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",b256 salt").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("b256 salt").as_bytes());
            }
            asm(
                dst: encoded,
                src: self.salt.unwrap(),
                bytes: 32,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                mcp offset_ptr src bytes;
            };
            total_bytes += 32;
        }

        type_hash_string.append(String::from_ascii_str(")").as_bytes());
        asm(
            ptr: type_hash_string.ptr(),
            len: type_hash_string.len(),
            dst: encoded,
        ) {
            k256 dst ptr len;
        }

        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded, bytes: total_bytes) {
            k256 hash ptr bytes;
            hash: b256
        }
    }
}

/// The EIP712 Domain struct matching Ethereum's implementation.
/// All fields are optional per the EIP712 specification, allowing the domain
/// to be constructed with only the parameters required by the application.
pub struct EIP712Domain {
    /// The name of the signing domain
    name: Option<String>,
    /// The current major version of the signing domain
    version: Option<String>,
    /// The Ethereum chain ID
    chain_id: Option<u256>,
    /// The address of the contract that will verify the signature (rightmost 20 bytes)
    verifying_contract: Option<b256>,
    /// A disambiguating salt
    salt: Option<b256>,
}

impl EIP712Domain {
    /// Creates a new EIP712Domain instance with the provided parameters
    ///
    /// # Arguments
    ///
    /// * `name`: [Option<String>] - The name of the signing domain
    /// * `version`: [Option<String>] - The version of the signing domain
    /// * `chain_id`: [Option<u256>] - The chain ID where the contract is deployed
    /// * `verifying_contract`: [Option<ContractId>] - The contract that will verify the signature.
    ///   Only the rightmost 20 bytes are retained to match Ethereum's 20-byte address scheme.
    /// * `salt`: [Option<b256>] - An optional disambiguating salt
    ///
    /// # Returns
    ///
    /// * [EIP712Domain] - A new instance of EIP712Domain with the provided parameters
    ///
    pub fn new(
        name: Option<String>,
        version: Option<String>,
        chain_id: Option<u256>,
        verifying_contract: Option<ContractId>,
        salt: Option<b256>,
    ) -> EIP712Domain {
        match verifying_contract {
            Some(bits) => {
                // An EVM address is only 20 bytes, so the first 12 are set to zero
                let mut local_bits = bits.bits();
                asm(r1: local_bits) {
                    mcli r1 i12;
                };
                EIP712Domain {
                    name,
                    version,
                    chain_id,
                    verifying_contract: Some(local_bits),
                    salt,
                }
            },
            None => {
                EIP712Domain {
                    name,
                    version,
                    chain_id,
                    verifying_contract: None,
                    salt,
                }
            }
        }
    }

    /// Computes the Keccak256 hash of the encoded domain parameters
    ///
    /// # Additional Information
    ///
    /// Dynamically builds the type hash string including only the fields that are
    /// Some. This is the `domainSeparator` as defined in https://eips.ethereum.org/EIPS/eip-712
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the encoded domain parameters
    ///
    pub fn domain_hash(self) -> b256 {
        let mut encoded: [b256; 6] = [
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
        ];
        let mut type_hash_string = Bytes::new();
        let mut total_bytes = 32;
        let mut needs_comma = false;

        type_hash_string.append(String::from_ascii_str("EIP712Domain(").as_bytes());

        if self.name.is_some() {
            type_hash_string.append(String::from_ascii_str("string name").as_bytes());
            asm(
                ptr: self.name.unwrap().ptr(),
                len: self.name.unwrap().as_str().len(),
                dst: encoded,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                k256 offset_ptr ptr len;
            }
            total_bytes += 32;
            needs_comma = true;
        }

        if self.version.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",string version").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("string version").as_bytes());
            }
            asm(
                ptr: self.version.unwrap().ptr(),
                len: self.version.unwrap().as_str().len(),
                dst: encoded,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                k256 offset_ptr ptr len;
            }
            total_bytes += 32;
            needs_comma = true;
        }

        if self.chain_id.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",uint256 chainId").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("uint256 chainId").as_bytes());
            }
            asm(
                dst: encoded,
                src: self.chain_id.unwrap(),
                bytes: 32,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                mcp offset_ptr src bytes;
            };
            total_bytes += 32;
            needs_comma = true;
        }

        if self.verifying_contract.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",address verifyingContract").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("address verifyingContract").as_bytes());
            }
            asm(
                dst: encoded,
                src: self.verifying_contract.unwrap(),
                bytes: 32,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                mcp offset_ptr src bytes;
            };
            total_bytes += 32;
            needs_comma = true;
        }

        if self.salt.is_some() {
            if needs_comma {
                type_hash_string.append(String::from_ascii_str(",bytes32 salt").as_bytes());
            } else {
                type_hash_string.append(String::from_ascii_str("bytes32 salt").as_bytes());
            }
            asm(
                dst: encoded,
                src: self.salt.unwrap(),
                bytes: 32,
                offset_bytes: total_bytes,
                offset_ptr,
            ) {
                add offset_ptr dst offset_bytes;
                mcp offset_ptr src bytes;
            };
            total_bytes += 32;
        }

        type_hash_string.append(String::from_ascii_str(")").as_bytes());
        asm(
            ptr: type_hash_string.ptr(),
            len: type_hash_string.len(),
            dst: encoded,
        ) {
            k256 dst ptr len;
        }

        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded, bytes: total_bytes) {
            k256 hash ptr bytes;
            hash: b256
        }
    }
}

/// Selects the encoding variant — Fuel-native (SRC16) or Ethereum-compatible (EIP712).
pub enum Encoding {
    SRC16: (),
    EIP712: (),
}

/// Wraps either a Fuel-native or Ethereum-compatible domain separator.
pub enum Domain {
    SRC16Domain: SRC16Domain,
    EIP712Domain: EIP712Domain,
}

impl Domain {
    pub fn domain_hash(self) -> b256 {
        match self {
            Self::SRC16Domain(domain) => domain.domain_hash(),
            Self::EIP712Domain(domain) => domain.domain_hash(),
        }
    }
}

/// Standard ABI for contracts that support SRC16 typed structured data signing.
abi SRC16 {
    /// Returns the Keccak256 hash of the domain separator for the given encoding.
    fn domain_separator_hash(encoding: Encoding) -> b256;

    /// Returns the Keccak256 type hash of the contract's primary data type for the given encoding.
    fn data_type_hash(encoding: Encoding) -> b256;

    /// Returns the domain separator for the given encoding.
    fn domain_separator(encoding: Encoding) -> Domain;
}

/// Trait for types that can be encoded as SRC16 typed structured data.
///
/// # Additional Information
///
/// Implementors provide `type_hash` and `struct_hash` for both SRC16 and EIP712
/// encodings. The default `encode` method combines them with the domain separator
/// following the `\x19\x01 ‖ domainHash ‖ structHash` pattern.
///
/// # Example
///
/// ```sway
/// const MAIL_TYPE_HASH: b256 = 0x536e54c54e6699204b424f41f6dea846ee38ac369afec3e7c141d2c92c65e67f;
///
/// impl SRC16Encode for Mail {
///     fn type_hash(encoding: Encoding) -> b256 {
///         MAIL_TYPE_HASH
///     }
///
///     fn struct_hash(self, encoding: Encoding) -> b256 {
///         let mut encoded = Bytes::new();
///         encoded.append(MAIL_TYPE_HASH.to_be_bytes());
///         encoded.append(DataEncoder::encode_address(self.from).to_be_bytes());
///         encoded.append(DataEncoder::encode_address(self.to).to_be_bytes());
///         encoded.append(DataEncoder::encode_string(self.contents).to_be_bytes());
///         let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
///         asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
///             k256 hash ptr len;
///             hash: b256
///         }
///     }
/// }
/// ```
pub trait SRC16Encode {
    /// Returns the Keccak256 type hash for this struct under the given encoding.
    fn type_hash(encoding: Encoding) -> b256;

    /// Returns the Keccak256 struct hash (type_hash ‖ encode_data) for the given encoding.
    fn struct_hash(self, encoding: Encoding) -> b256;
} {
    /// Computes the final SRC16/EIP712 encoded hash: `keccak256(\x19\x01 ‖ domainHash ‖ structHash)`.
    fn encode(self, domain: Domain) -> b256 {
        let encoding = match domain {
            Domain::SRC16Domain => Encoding::SRC16,
            Domain::EIP712Domain => Encoding::EIP712,
        };

        let domain_separator_bytes = domain.domain_hash();
        let data_hash_bytes = self.struct_hash(encoding);

        let mut encoded: [b256; 3] = [
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
            0x0000000000000000000000000000000000000000000000000000000000000000,
        ];

        // \x19\x01 prefix
        asm(dst: encoded, src_1: 0x19, src_2: 0x01, bytes: 1) {
            sb dst src_1 i0;
            sb dst src_2 i1;
        };

        // domain separator hash at offset 2
        asm(
            dst: encoded,
            src: domain_separator_bytes,
            bytes: 32,
            offset_bytes: 2,
            offset_ptr,
        ) {
            add offset_ptr dst offset_bytes;
            mcp offset_ptr src bytes;
        };

        // struct hash at offset 34
        asm(
            dst: encoded,
            src: data_hash_bytes,
            bytes: 32,
            offset_bytes: 34,
            offset_ptr,
        ) {
            add offset_ptr dst offset_bytes;
            mcp offset_ptr src bytes;
        };

        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded, bytes: 66) {
            k256 hash ptr bytes;
            hash: b256
        }
    }
}

/// Trait for managing a u64 replay protection nonce on a typed data struct.
pub trait Nonce {
    fn set_nonce(ref mut self, nonce: u64);
    fn get_nonce(self) -> u64;
}

/// Trait for managing a u256 replay protection nonce on a typed data struct.
pub trait ExtendedNonce {
    fn set_nonce(ref mut self, nonce: u256);
    fn get_nonce(self) -> u256;
}

/// This trait provides common encoding methods for different data types.
///
/// # Additional Information
///
/// This trait standardizes the encoding of common data types used in structured data.
/// All unsigned integers are encoded to 32 byte big-endian format.
///
pub trait TypedDataEncoder {
    fn encode_string(value: String) -> b256;
    fn encode_u8(value: u8) -> b256;
    fn encode_u16(value: u16) -> b256;
    fn encode_u32(value: u32) -> b256;
    fn encode_u64(value: u64) -> b256;
    fn encode_u256(value: u256) -> b256;
    fn encode_b256(value: b256) -> b256;
    fn encode_bool(value: bool) -> b256;
    fn dynamic_u8_array(array: Vec<u8>) -> b256;
    fn dynamic_u16_array(array: Vec<u16>) -> b256;
    fn dynamic_u32_array(array: Vec<u32>) -> b256;
    fn dynamic_u64_array(array: Vec<u64>) -> b256;
    fn dynamic_u256_array(array: Vec<u256>) -> b256;
    fn dynamic_b256_array(array: Vec<b256>) -> b256;
    fn encode_address(value: Address) -> b256;
    fn encode_contract_id(value: ContractId) -> b256;
    fn encode_identity(value: Identity) -> b256;
}

/// Standard implementation of typed data encoding methods
pub struct DataEncoder {}

/// Implementation of typed data encoding methods according to the SRC16 specification.
///
/// # Additional Information
///
/// This implementation provides encoding methods for both primitive types and dynamic arrays.
/// All encoded values are 32 bytes (b256) to maintain backwards compatibility with the EIP712
/// specification.
///
impl TypedDataEncoder for DataEncoder {
    /// Encodes a String value by taking the Keccak256 hash of its raw bytes.
    fn encode_string(value: String) -> b256 {
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(
            hash: result_buffer,
            ptr: value.ptr(),
            len: value.as_str().len(),
        ) {
            k256 hash ptr len;
            hash: b256
        }
    }

    /// Encodes a u8 value into a 32-byte big-endian value.
    fn encode_u8(value: u8) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) {
            r1: b256
        }
    }

    /// Encodes a u16 value into a 32-byte big-endian value.
    fn encode_u16(value: u16) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) {
            r1: b256
        }
    }

    /// Encodes a u32 value into a 32-byte big-endian value.
    fn encode_u32(value: u32) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) {
            r1: b256
        }
    }

    /// Encodes a u64 value into a 32-byte big-endian value.
    fn encode_u64(value: u64) -> b256 {
        asm(r1: (0, 0, 0, value)) {
            r1: b256
        }
    }

    /// Encodes a u256 value into a 32-byte value.
    fn encode_u256(value: u256) -> b256 {
        value.as_b256()
    }

    /// Returns the b256 value as-is.
    fn encode_b256(value: b256) -> b256 {
        value
    }

    /// Encodes a boolean value: false → 0, true → 1, both padded to 32 bytes.
    fn encode_bool(value: bool) -> b256 {
        let value_as_uint = if value { 1u64 } else { 0u64 };
        asm(r1: (0, 0, 0, value_as_uint)) {
            r1: b256
        }
    }

    /// Encodes a dynamic array of u8 values as keccak256 of their concatenated 32-byte encodings.
    fn dynamic_u8_array(array: Vec<u8>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(
                (asm(r1: (0, 0, 0, v.as_u64())) {
                        r1: b256
                    })
                    .to_be_bytes(),
            );
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    /// Encodes a dynamic array of u16 values as keccak256 of their concatenated 32-byte encodings.
    fn dynamic_u16_array(array: Vec<u16>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(
                (asm(r1: (0, 0, 0, v.as_u64())) {
                        r1: b256
                    })
                    .to_be_bytes(),
            );
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    /// Encodes a dynamic array of u32 values as keccak256 of their concatenated 32-byte encodings.
    fn dynamic_u32_array(array: Vec<u32>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(
                (asm(r1: (0, 0, 0, v.as_u64())) {
                        r1: b256
                    })
                    .to_be_bytes(),
            );
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    /// Encodes a dynamic array of u64 values as keccak256 of their concatenated 32-byte encodings.
    fn dynamic_u64_array(array: Vec<u64>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append((asm(r1: (0, 0, 0, v)) {
                r1: b256
            }).to_be_bytes());
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    /// Encodes a dynamic array of u256 values as keccak256 of their concatenated 32-byte encodings.
    fn dynamic_u256_array(array: Vec<u256>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(v.to_be_bytes());
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    /// Encodes a dynamic array of b256 values as keccak256 of their concatenated encodings.
    fn dynamic_b256_array(array: Vec<b256>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(v.to_be_bytes());
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    /// Encodes an Address as its underlying b256.
    fn encode_address(value: Address) -> b256 {
        value.into()
    }

    /// Encodes a ContractId as its underlying b256.
    fn encode_contract_id(value: ContractId) -> b256 {
        value.into()
    }

    /// Encodes an Identity (Address or ContractId) as its underlying b256.
    fn encode_identity(value: Identity) -> b256 {
        match value {
            Identity::Address(addr) => addr.bits(),
            Identity::ContractId(contract_id) => contract_id.bits(),
        }
    }
}

/// This enum determines the encoder type for fixed-length array encoding.
pub enum EncoderType {
    String: (),
    U8: (),
    U16: (),
    U32: (),
    U64: (),
    U256: (),
    B256: (),
    Address: (),
    ContractId: (),
    Identity: (),
}

/// This trait provides standard methods for encoding a fixed array of typed
/// values into a single 32-byte hash.
pub trait FixedDataEncoder {
    fn encode_fixed_string_array(slice: raw_slice) -> b256;
    fn encode_fixed_u8_array(slice: raw_slice) -> b256;
    fn encode_fixed_u16_array(slice: raw_slice) -> b256;
    fn encode_fixed_u32_array(slice: raw_slice) -> b256;
    fn encode_fixed_u64_array(slice: raw_slice) -> b256;
    fn encode_fixed_u256_array(slice: raw_slice) -> b256;
    fn encode_fixed_b256_array(slice: raw_slice) -> b256;
    fn encode_fixed_address_array(slice: raw_slice) -> b256;
    fn encode_fixed_contract_id_array(slice: raw_slice) -> b256;
    fn encode_fixed_identity_array(slice: raw_slice) -> b256;
}

impl FixedDataEncoder for DataEncoder {
    fn encode_fixed_string_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<String>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<String>(i).read::<String>();
            encoded.append(DataEncoder::encode_string(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_u8_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<u8>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<u8>(i).read::<u8>();
            encoded.append(DataEncoder::encode_u8(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_u16_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<u16>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<u16>(i).read::<u16>();
            encoded.append(DataEncoder::encode_u16(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_u32_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<u32>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<u32>(i).read::<u32>();
            encoded.append(DataEncoder::encode_u32(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_u64_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<u64>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<u64>(i).read::<u64>();
            encoded.append(DataEncoder::encode_u64(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_u256_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<u256>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<u256>(i).read::<u256>();
            encoded.append(DataEncoder::encode_u256(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_b256_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<b256>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<b256>(i).read::<b256>();
            encoded.append(DataEncoder::encode_b256(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_address_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<Address>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<Address>(i).read::<Address>();
            encoded.append(DataEncoder::encode_address(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_contract_id_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<ContractId>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<ContractId>(i).read::<ContractId>();
            encoded.append(DataEncoder::encode_contract_id(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }

    fn encode_fixed_identity_array(slice: raw_slice) -> b256 {
        let mut encoded = Bytes::new();
        let len = slice.len::<Identity>();
        let ptr = slice.ptr();
        let mut i = 0;
        while i < len {
            let item = ptr.add::<Identity>(i).read::<Identity>();
            encoded.append(DataEncoder::encode_identity(item).to_be_bytes());
            i += 1;
        }
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }
}

/// This trait provides encoding functionality for fixed-length arrays of different types.
pub trait FixedArrayEncoder {
    fn encode_fixed_array(slice: raw_slice, encoder_type: EncoderType) -> b256;
}

impl FixedArrayEncoder for DataEncoder {
    fn encode_fixed_array(slice: raw_slice, encoder_type: EncoderType) -> b256 {
        match encoder_type {
            EncoderType::String => Self::encode_fixed_string_array(slice),
            EncoderType::U8 => Self::encode_fixed_u8_array(slice),
            EncoderType::U16 => Self::encode_fixed_u16_array(slice),
            EncoderType::U32 => Self::encode_fixed_u32_array(slice),
            EncoderType::U64 => Self::encode_fixed_u64_array(slice),
            EncoderType::U256 => Self::encode_fixed_u256_array(slice),
            EncoderType::B256 => Self::encode_fixed_b256_array(slice),
            EncoderType::Address => Self::encode_fixed_address_array(slice),
            EncoderType::ContractId => Self::encode_fixed_contract_id_array(slice),
            EncoderType::Identity => Self::encode_fixed_identity_array(slice),
        }
    }
}
