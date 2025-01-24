library;

use std::{bytes::Bytes, hash::*, string::String};
use std::bytes_conversions::{b256::*, u256::*, u64::*};
use std::core::codec::{AbiEncode, encode};

/// This base ABI provides the common hashing functionality that is
/// shared between the Fuel (SRC16) and Ethereum (EIP712) implementations.
abi SRC16Base {
    /// Returns the Keccak256 hash of the encoded domain separator
    ///
    /// # Returns
    ///
    /// * [b256] - The domain separator hash computed from the domain parameters
    fn domain_separator_hash() -> b256;

    /// Returns the Keccak256 hash of the structured data type
    ///
    /// # Returns
    ///
    /// * [b256] - The type hash specific to the implementing contract's data structure
    fn data_type_hash() -> b256;
}

/// Fuel-specific implementation of structured data signing
///
/// # Additional Information
///
/// Extends SRC16Base with Fuel-specific domain separator handling using
///
abi SRC16 : SRC16Base {
    /// Returns the domain separator struct for Fuel
    ///
    /// # Returns
    ///
    /// * [SRC16Domain] - The domain separator containing Fuel-specific parameters
    fn domain_separator() -> SRC16Domain;
}

/// Ethereum-compatible implementation of structured data signing
///
/// # Additional Information
///
/// Extends SRC16Base with Ethereum-compatible domain separator handling using
///
abi EIP712 : SRC16Base {
    /// Returns the domain separator struct for Ethereum compatibility
    ///
    /// # Returns
    ///
    /// * [EIP712Domain] - The domain separator containing Ethereum-compatible parameters
    fn domain_separator() -> EIP712Domain;
}

/// Contains the core parameters that uniquely identify a domain for typed
/// data signing on Fuel.
pub struct SRC16Domain {
    /// The name of the signing domain
    name: String,
    /// The current major version of the signing domain
    version: String,
    /// The active chain ID where the signing is intended to be used.
    chain_id: u64,
    /// The contract id of the contract that will verify the signature
    verifying_contract: ContractId,
}

/// The type hash constant for the SRC16Domain domain separator
///
/// # Additional Information
///
/// This is the Keccak256 hash of "SRC16Domain(string name,string version,uint256 chainId,contractId verifyingContract)"
pub const SRC16_DOMAIN_TYPE_HASH: b256 = 0x10f132d1adc99105bb9ad0d98956a93f35bda5c77713ac13adc489609c39336f;

/// Encodes the SRC16Domain domain parameters using AbiEncode.
///
/// # Additional Information
///
/// The encoding follows the following scheme:
/// 1. add SRC16_DOMAIN_TYPE_HASH
/// 2. add Keccak256 hash of name string
/// 3. add Keccak256 hash of version string
/// 4. add Chain ID as 32-byte big-endian
/// 5. add Verifying contract address as 32-bytes
///
impl AbiEncode for SRC16Domain {
    fn abi_encode(self, buffer: Buffer) -> Buffer {
        let buffer = SRC16_DOMAIN_TYPE_HASH.abi_encode(buffer);
        let buffer = keccak256(Bytes::from(self.name)).abi_encode(buffer);
        let buffer = keccak256(Bytes::from(self.version)).abi_encode(buffer);
        let buffer = (asm(r1: (0, 0, 0, self.chain_id)) {
            r1: b256
        }).abi_encode(buffer);
        let buffer = self.verifying_contract.abi_encode(buffer);
        buffer
    }
}

impl SRC16Domain {
    /// Creates a new SRC16Domain instance with the provided parameters
    ///
    /// # Arguments
    ///
    /// * `domain_name`: [String] - The name of the signing domain
    /// * `version`: [String] - The version of the signing domain
    /// * `chain_id`: [u64] - The chain ID where the contract is deployed
    /// * `verifying_contract`: [b256] - The address of the contract that will verify the signature
    ///
    /// # Returns
    ///
    /// * [SRC16Domain] - A new instance of SRC16Domain with the provided parameters
    ///
    pub fn new(
        domain_name: String,
        version: String,
        chain_id: u64,
        verifying_contract: ContractId,
    ) -> SRC16Domain {
        SRC16Domain {
            name: domain_name,
            version: version,
            chain_id: chain_id,
            verifying_contract: verifying_contract,
        }
    }

    /// Computes the Keccak256 hash of the encoded domain parameters
    ///
    /// # Additional Information
    ///
    /// Utilizes AbiEncode for SRC16Domain
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the encoded domain parameters
    ///
    pub fn domain_hash(self) -> b256 {
        let encoded = encode(self);
        let bytes = Bytes::from(encoded);
        keccak256(bytes)
    }
}

/// The EIP712 Domain struct matching Ethereum's implementation
pub struct EIP712Domain {
    /// The name of the signing domain
    name: String,
    /// The current major version of the signing domain
    version: String,
    /// The Ethereum chain ID
    chain_id: u256,
    /// The address of the contract that will verify the signature
    verifying_contract: b256,
}

/// The type hash constant for the EIP712Domain domain separator
///
/// # Additional Information
///
/// This is the Keccak256 hash of "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
pub const EIP712_DOMAIN_TYPE_HASH: b256 = 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f;

/// Encodes the EIP712Domain domain parameters using AbiEncode.
///
/// # Additional Information
///
/// The encoding follows the following scheme:
/// 1. add EIP712_DOMAIN_TYPE_HASH
/// 2. add Keccak256 hash of name string
/// 3. add Keccak256 hash of version string
/// 4. add Chain ID as 32-byte big-endian
/// 5. add Verifying contract address as 32-bytes
///
impl AbiEncode for EIP712Domain {
    fn abi_encode(self, buffer: Buffer) -> Buffer {
        let buffer = EIP712_DOMAIN_TYPE_HASH.abi_encode(buffer);
        let buffer = keccak256(Bytes::from(self.name)).abi_encode(buffer);
        let buffer = keccak256(Bytes::from(self.version)).abi_encode(buffer);
        let buffer = (self.chain_id).abi_encode(buffer);
        let buffer = self.verifying_contract.abi_encode(buffer);
        buffer
    }
}

impl EIP712Domain {
    /// Creates a new EIP712Domain instance with the provided parameters
    ///
    /// # Arguments
    ///
    /// * `domain_name`: [String] - The name of the signing domain
    /// * `version`: [String] - The version of the signing domain
    /// * `chain_id`: [u256] - The chain ID where the contract is deployed
    /// * `verifying_contract`: [b256] - The address (last 20-Bytes) of the contract that will verify the signature
    ///
    /// # Returns
    ///
    /// * [EIP712Domain] - A new instance of EIP712Domain with the provided parameters
    ///
    pub fn new(
        domain_name: String,
        version: String,
        chain_id: u256,
        verifying_contract: ContractId,
    ) -> EIP712Domain {
        // Take only the rightmost 20 bytes from a 32-byte Fuel ContractId
        let mut verifying_contract_last_20 = Bytes::with_capacity(32);
        let mut i = 0;
        while i < 12 {
            verifying_contract_last_20.push(0);
            i += 1;
        }
        let (_, last_20): (Bytes, Bytes) = verifying_contract.bits().to_be_bytes().split_at(12);
        verifying_contract_last_20.append(last_20);

        EIP712Domain {
            name: domain_name,
            version: version,
            chain_id: chain_id,
            verifying_contract: verifying_contract_last_20.into(),
        }
    }

    /// Computes the Keccak256 hash of the encoded domain parameters
    ///
    /// # Additional Information
    ///
    /// Utilizes AbiEncode for EIP712Domain
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the encoded domain parameters
    ///
    pub fn domain_hash(self) -> b256 {
        let encoded = encode(self);
        let bytes = Bytes::from(encoded);
        keccak256(bytes)
    }
}

/// Trait for types that can be hashed in a structured way
///
pub trait TypedDataHash {
    /// The type hash constant for this struct
    fn type_hash() -> b256;

    /// Return the Keccak256 hash of the encoded typed structured data.
    ///
    /// # Arguments
    ///
    /// * `self` : [<custom_struct>] - A custom data structure used by the SRC16 validator.
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the encoded structured data
    ///
    /// # Additional Information
    ///
    /// This is a per-program implementation. This function should be implemented
    /// for the <custom_struct>. The DataEncoder can be used to encoded known data types.
    ///
    /// Implementors should ensure their hash computation follows the SRC16 specification.
    ///
    /// # Example
    ///
    /// ```sway
    /// use standards::src16::{SRC16, TypedDataHash};
    ///
    /// impl TypedDataHash for <custom_struct> {
    ///     fn struct_hash(self) -> b256 {
    ///         let mut encoded = Bytes::new();
    ///
    ///         ... implement encodeData for S using DataEncoder ...
    ///
    ///         keccak256(encoded)
    /// }
    /// ```
    ///
    fn struct_hash(self) -> b256;
}

/// Holds the signing domain and types data hash used by DomainHash.
pub struct SRC16Payload<D> {
    pub domain: D,
    pub data_hash: b256,
}

impl<D> SRC16Payload<D> {
    /// Computes the final encoded hash according to SRC16/EIP712 specification
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Add prefix bytes \x19\x01
    /// 2. Add domain separator hash from either SRC16Domain or EIP712Domain
    /// 3. Add struct data hash
    /// 4. Compute final Keccak256 hash
    ///
    /// # Arguments
    ///
    /// * `self`: [SRC16Payload<D>] - The payload containing domain parameters and data hash
    ///
    /// # Returns
    ///
    /// * [Option<b256>] - The final encoded hash, or None if encoding fails
    ///
    /// # Examples
    ///
    /// ```sway
    /// fn encode_mail_data(mail: Mail, domain: SRC16Domain) {
    ///     let payload = SRC16Payload {
    ///         domain: domain,
    ///         data_hash: mail.struct_hash(),
    ///     };
    ///     let final_hash = payload.encode_hash();
    /// }
    /// ```
    pub fn encode_hash(self) -> Option<b256>
    where
        D: DomainHash,
    {
        let domain_separator_bytes = self.domain.domain_hash().to_be_bytes();
        let data_hash_bytes = self.data_hash.to_be_bytes();
        let mut digest_input = Bytes::with_capacity(66);
        digest_input.push(0x19);
        digest_input.push(0x01);
        digest_input.append(domain_separator_bytes);
        digest_input.append(data_hash_bytes);
        let final_hash = keccak256(digest_input);

        Some(final_hash)
    }
}

/// Trait for domain types that can be hashed
pub trait DomainHash {
    fn domain_hash(self) -> b256;
}

/// Implementation of domain hashing for both SRC16 and EIP712 domains
///
/// # Additional Information
///
/// Both domain types provide their own domain_hash() implementation following their
/// respective encoding schemes:
/// * SRC16Domain uses "SRC16Domain(string name,string version,uint256 chainId,address verifyingContract)"
/// * EIP712Domain uses "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
///
/// # Returns
///
/// * [b256] - The Keccak256 hash of the encoded domain parameters
///
impl DomainHash for SRC16Domain {
    fn domain_hash(self) -> b256 {
        self.domain_hash()
    }
}

impl DomainHash for EIP712Domain {
    fn domain_hash(self) -> b256 {
        self.domain_hash()
    }
}

pub trait SRC16Encode<T> {
    /// Returns the combined typed data hash according to SRC16 specification.
    ///
    /// # Arguments
    ///
    /// * `s`: [T] - A generic structured data type defined in the implementing program.
    ///
    /// # Additional Information
    ///
    /// This function produces a domain-bound hash by combining:
    /// 1. The prefix bytes (\x19\x01)
    /// 2. The domain separator hash
    /// 3. The structured data hash
    ///
    /// # Arguments
    ///
    /// * `data_hash`: [b256] - The Keccak256 hash of the encoded structured data
    ///
    /// # Returns
    ///
    /// * [b256] - The combined typed data hash.
    ///
    fn encode<T>(s: T) -> b256;
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
    /// Encodes a String value by taking the Keccak256 hash of its bytes.
    ///
    /// # Arguments
    ///
    /// * `value`: [String] - The string value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The keccak256 hash of the string's bytes
    fn encode_string(value: String) -> b256 {
        keccak256(Bytes::from(value))
    }

    /// Encodes a u8 value into a 32-byte value (big-endian, padded with zeros).
    ///
    /// # Arguments
    ///
    /// * `value`: [u8] - The u8 value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The value padded to 32 bytes
    fn encode_u8(value: u8) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) {
            r1: b256
        }
    }

    /// Encodes a u16 value into a 32-byte value (big-endian, padded with zeros).
    ///
    /// # Arguments
    ///
    /// * `value`: [u16] - The u16 value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The value padded to 32 bytes
    fn encode_u16(value: u16) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) {
            r1: b256
        }
    }

    /// Encodes a u32 value into a 32-byte value (big-endian, padded with zeros).
    ///
    /// # Arguments
    ///
    /// * `value`: [u32] - The u32 value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The value padded to 32 bytes
    fn encode_u32(value: u32) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) {
            r1: b256
        }
    }

    /// Encodes a u64 value into a 32-byte value (big-endian, padded with zeros).
    ///
    /// # Arguments
    ///
    /// * `value`: [u64] - The u64 value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The value padded to 32 bytes
    fn encode_u64(value: u64) -> b256 {
        asm(r1: (0, 0, 0, value)) {
            r1: b256
        }
    }

    /// Encodes a u256 value into a 32-byte value (big-endian, padded with zeros).
    ///
    /// # Arguments
    ///
    /// * `value`: [u256] - The u256 value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The value padded to 32 bytes
    fn encode_u256(value: u256) -> b256 {
        value.as_b256()
    }

    /// Encodes as it original b256 value.
    ///
    /// # Arguments
    ///
    /// * `value`: [b256] - The b256 value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The value padded to 32 bytes
    fn encode_b256(value: b256) -> b256 {
        value
    }

    /// Encodes a boolean value into a 32-byte value
    ///
    /// # Additional Information
    ///
    /// Encodes bool values as follows in b256 big-endian format:
    /// * false = 0
    /// * true = 1
    ///
    /// # Arguments
    ///
    /// * `value`: [bool] - The boolean to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded value
    fn encode_bool(value: bool) -> b256 {
        let value_as_uint = if value { 1u64 } else { 0u64 };
        asm(r1: (0, 0, 0, value_as_uint)) {
            r1: b256
        }
    }

    /// Encodes a dynamic array of u8 values into a single 32-byte hash.
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Each u8 value in the array is encoded to a b256
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `array`: [Vec<u8>] - The array of u8 values to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
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
        keccak256(encoded)
    }

    /// Encodes a dynamic array of u16 values into a single 32-byte hash.
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Each u16 value in the array is encoded to a b256
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `array`: [Vec<u16>] - The array of u16 values to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
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
        keccak256(encoded)
    }

    /// Encodes a dynamic array of u32 values into a single 32-byte hash.
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Each u32 value in the array is encoded to a b256
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `array`: [Vec<u32>] - The array of u32 values to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
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
        keccak256(encoded)
    }

    /// Encodes a dynamic array of u64 values into a single 32-byte hash.
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Each u64 value in the array is encoded to a b256
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `array`: [Vec<u64>] - The array of u64 values to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
    fn dynamic_u64_array(array: Vec<u64>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append((asm(r1: (0, 0, 0, v)) {
                r1: b256
            }).to_be_bytes());
        }
        keccak256(encoded)
    }

    /// Encodes a dynamic array of u256 values into a single 32-byte hash.
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Each u256 value in the array is encoded to a b256
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `array`: [Vec<u256>] - The array of u256 values to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
    fn dynamic_u256_array(array: Vec<u256>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(v.to_be_bytes());
        }
        keccak256(encoded)
    }

    /// Encodes a dynamic array of b256 values into a single 32-byte hash.
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Each b256 value in the array is encoded to a b256
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `array`: [Vec<b256>] - The array of b256 values to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
    fn dynamic_b256_array(array: Vec<b256>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(v.to_be_bytes());
        }
        keccak256(encoded)
    }

    /// Encodes an Address into a 32-byte value.
    ///
    /// # Arguments
    ///
    /// * `value`: [Address] - The address to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The address as a b256
    fn encode_address(value: Address) -> b256 {
        value.into()
    }

    /// Encodes a ContractId into a 32-byte value.
    ///
    /// # Arguments
    ///
    /// * `value`: [ContractId] - The contract ID to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The contract ID as a b256
    fn encode_contract_id(value: ContractId) -> b256 {
        value.into()
    }

    /// Encodes an Identity enum into a 32-byte value.
    ///
    /// # Additional Information
    ///
    /// Handles both Address and ContractId variants by accessing their underlying b256 representation.
    ///
    /// # Arguments
    ///
    /// * `value`: [Identity] - The identity to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded identity value
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
///
/// # Additional Information
///
/// The encoding follows this scheme:
/// 1. Each typed value in the array is encoded to a b256 using
///    the respective DataEncoder method.
/// 2. The encoded values are concatenated in order
/// 3. The concatenated bytes are hashed with Keccak256
///
/// # Arguments
///
/// * `slice`: [raw_slice] - The raw slice containing the typed array
///
/// # Returns
///
/// * [b256] - The Keccak256 hash of the concatenated encoded values
///
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
    /// Encodes a fixed array of String values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of u8 values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of u16 values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of u32 values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of u64 values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of u256 values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of b256 values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of Address values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of ContractId values into a single 32-byte hash.
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
        keccak256(encoded)
    }

    /// Encodes a fixed array of Identity values into a single 32-byte hash
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
        keccak256(encoded)
    }
}

/// This trait provides encoding functionality for fixed-length arrays of different types.
pub trait FixedArrayEncoder {
    /// Encodes a fixed-length array into a 32-byte hash based on the specified encoder type.
    ///
    /// # Additional Information
    ///
    /// This function acts as a dispatcher that routes to specific encoding implementations
    /// based on the provided EncoderType. The encoding follows this scheme:
    /// 1. Each element is encoded according to its type-specific rules
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `slice`: [raw_slice] - The raw slice containing the array data
    /// * `encoder_type`: [EncoderType] - The type of encoder to use for the array elements
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
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
