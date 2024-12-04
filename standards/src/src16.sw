library;

use std::{
    bytes::Bytes,
    string::String,
    hash::*,
};
use std::bytes_conversions::{b256::*, u256::*, u64::*};

abi SRC16 {

    /// Returns the domain separator struct containing the initialized parameters
    ///
    /// # Returns
    ///
    /// * [SRC16Domain] - The domain separator with all its parameters
    ///
    fn domain_separator() -> SRC16Domain;

    /// Returns the Keccak256 hash of the encoded domain separator
    ///
    /// # Returns
    ///
    /// * [b256] - The domain separator hash
    ///
    ///
    fn domain_separator_hash() -> b256;

    /// Returns the Keccak256 hash of the structured data type defined in the
    /// implementing program.
    ///
    /// # Returns
    ///
    /// * [b256] - The structured data type hash
    ///
    ///
    fn data_type_hash() -> b256;

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


/// Contains the core parameters that uniquely identify a domain for typed
/// data signing.
pub struct SRC16Domain {
    /// The name of the signing domain
    name: String,
    /// The current major version of the signing domain
    version: String,
    /// The active chain ID where the signing is intended to be used.
    chain_id: u64,
    /// The address of the contract that will verify the signature
    verifying_contract: b256,
}

/// The type hash constant for the domain separator
///
/// # Additional Information
///
/// This is the Keccak256 hash of "SRC16Domain(string name,string version,uint256 chainId,address verifyingContract)"
// pub const SRC16_DOMAIN_TYPE_HASH: b256 = 0xae9189d496944f7c643961cf1b7975c30fea464263ed19e76881ddb5625bb9bd;
pub const SRC16_DOMAIN_TYPE_HASH: b256 = 0x3d99520d68918c39d115c0b17ba8454c1723175ecf4b38d25528fe0a117db78e;


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
        verifying_contract: b256,
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
    /// The encoding follows thse scheme:
    /// 1. add SRC16_DOMAIN_TYPE_HASH
    /// 2. add Keccak256 hash of name string
    /// 3. add Keccak256 hash of version string
    /// 4. add Chain ID as 32-byte big-endian
    /// 5. add Verifying contract address as 32-bytes
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the encoded domain parameters
    ///
    pub fn domain_hash(self) -> b256 {
        let mut encoded = Bytes::new();
        encoded.append(
            SRC16_DOMAIN_TYPE_HASH.to_be_bytes()
        );
        encoded.append(
            keccak256(Bytes::from(self.name)).to_be_bytes()
        );
        encoded.append(
            keccak256(Bytes::from(self.version)).to_be_bytes()
        );
        encoded.append(
            (asm(r1: (0, 0, 0, self.chain_id)) { r1: b256 }).to_be_bytes()
        );
        encoded.append(
            self.verifying_contract.to_be_bytes()
        );
        keccak256(encoded)
    }

}


/// Trait that provides common encoding methods for different data types
///
/// # Additional Information
///
/// This trait standardizes the encoding of common data types used in structured data.
/// for bytes1-64 the encoder places the byte(s) in big-endian.
///
pub trait TypedDataEncoder {

    /// Encodes a string value into a 32-byte hash
    ///
    /// # Arguments
    ///
    /// * `value`: [String] - The string to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded string value
    fn encode_string(value: String) -> b256;

    /// Encodes a u8 value into a 32-byte value.
    ///
    /// # Arguments
    ///
    /// * `value`: [u8] - The number to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded value
    fn encode_u8(value: u8) -> b256;

    /// Encodes a u16 value into a 32-byte value
    ///
    /// # Arguments
    ///
    /// * `value`: [u16] - The number to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded value
    fn encode_u16(value: u16) -> b256;

    /// Encodes a u32 value into a 32-byte value
    ///
    /// # Arguments
    ///
    /// * `value`: [u32] - The number to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded value
    fn encode_u32(value: u32) -> b256;

    /// Encodes a u64 value into a 32-byte value
    ///
    /// # Arguments
    ///
    /// * `value`: [u64] - The number to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded value
    fn encode_u64(value: u64) -> b256;

    /// Encodes a 32-byte value
    ///
    /// # Arguments
    ///
    /// * `value`: [b256] - The value to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded value
    // fn encode_bytes32(value: b256) -> b256;
    fn encode_bytes32(value: b256) -> b256;

    /// Encodes a dynamic array of u8 values into a single 32-byte hash
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
    fn dynamic_u8_array(array: Vec<u8>) -> b256;

    /// Encodes a dynamic array of u16 values into a single 32-byte hash
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
    fn dynamic_u16_array(array: Vec<u16>) -> b256;

    /// Encodes a dynamic array of u32 values into a single 32-byte hash
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
    fn dynamic_u32_array(array: Vec<u32>) -> b256;

    /// Encodes a dynamic array of u64 values into a single 32-byte hash
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
    fn dynamic_u64_array(array: Vec<u64>) -> b256;

    /// Encodes a dynamic array of 32-byte values into a single 32-byte hash
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Each b256 value in the array is encoded directly
    /// 2. The encoded values are concatenated in order
    /// 3. The concatenated bytes are hashed with Keccak256
    ///
    /// # Arguments
    ///
    /// * `array`: [Vec<b256>] - The array of 32-byte values to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The Keccak256 hash of the concatenated encoded values
    fn dynamic_bytes32_array(array: Vec<b256>) -> b256;

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
    fn encode_bool(value: bool) -> b256;

    /// Encodes an Address value into a 32-byte value
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Convert Address to its underlying b256 representation
    /// 2. Encode the b256 value directly
    ///
    /// # Arguments
    ///
    /// * `value`: [Address] - The address to encode
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded value
    fn encode_address(value: Address) -> b256;

}

/// Standard implementation of typed data encoding methods
pub struct DataEncoder {}

impl TypedDataEncoder for DataEncoder {

    fn encode_string(value: String) -> b256 {
        keccak256(Bytes::from(value))
    }

    fn encode_u8(value: u8) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) { r1: b256 }
    }

    fn encode_u16(value: u16) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) { r1: b256 }
    }

    fn encode_u32(value: u32) -> b256 {
        asm(r1: (0, 0, 0, value.as_u64())) { r1: b256 }
    }

    fn encode_u64(value: u64) -> b256 {
        asm(r1: (0, 0, 0, value)) { r1: b256 }
    }

    fn encode_bytes32(value: b256) -> b256 {
        value
    }

    fn dynamic_u8_array(array: Vec<u8>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            let enc_v = asm(r1: (0, 0, 0, v.as_u64())) { r1: b256 };
            encoded.append(
                // Self::encode_u8(v).to_be_bytes() //NOTE - breaks compiler.
                enc_v.to_be_bytes()
            );
        }
        keccak256(encoded)
    }

    fn dynamic_u16_array(array: Vec<u16>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            let enc_v = asm(r1: (0, 0, 0, v.as_u64())) { r1: b256 };
            encoded.append(
                // Self::encode_u16(v).to_be_bytes()
                enc_v.to_be_bytes()
            );
        }
        keccak256(encoded)
    }

    fn dynamic_u32_array(array: Vec<u32>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            let enc_v = asm(r1: (0, 0, 0, v.as_u64())) { r1: b256 };
            encoded.append(
                // Self::encode_u32(v).to_be_bytes()
                enc_v.to_be_bytes()
            );
        }
        keccak256(encoded)
    }

    fn dynamic_u64_array(array: Vec<u64>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            let enc_v = asm(r1: (0, 0, 0, v)) { r1: b256 };
            encoded.append(
                // Self::encode_u64(v).to_be_bytes()
                enc_v.to_be_bytes()
            );
        }
        keccak256(encoded)
    }

    fn dynamic_bytes32_array(array: Vec<b256>) -> b256 {
        let mut encoded = Bytes::new();
        for v in array.iter() {
            encoded.append(
                v.to_be_bytes()
            );
        }
        keccak256(encoded)
    }

    fn encode_bool(value: bool) -> b256 {
        let value_as_int = if value { 1u64 } else { 0u64 };
        asm(r1: (0, 0, 0, value_as_int)) { r1: b256 }
    }

    fn encode_address(value: Address) -> b256 {
        value.into()
    }

    //TODO - Fixed length arrays.

}


/// Trait for types that can be hashed in a structured way
///
pub trait TypedDataHash {

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


/// A struct to hold the signing domain and types data hash.
pub struct SRC16Payload{
    pub domain: SRC16Domain,
    pub data_hash: b256,
}

impl SRC16Payload {

    /// Computes the encoded hash according to SRC16 specification
    ///
    /// # Additional Information
    ///
    /// The encoding follows this scheme:
    /// 1. Add prefix bytes \x19\x01
    /// 2. Add domain separator hash
    /// 3. Add data struct hash
    /// 4. Compute final Keccak256 hash
    ///
    /// # Returns
    ///
    /// * [Option<b256>] - The encoded hash, or None if encoding fails
    ///
    pub fn encode_hash(self) -> Option<b256> {

        let domain_separator_bytes = self.domain.domain_hash().to_be_bytes();
        let data_hash_bytes = self.data_hash.to_be_bytes();
        let mut digest_input = Bytes::with_capacity(66);
        // add prefix
        digest_input.push(0x19);
        digest_input.push(0x01);
        // add domain_separator then tped data hash
        digest_input.append(domain_separator_bytes);
        digest_input.append(data_hash_bytes);
        let final_hash = keccak256(digest_input);

        Some(final_hash)
    }
}

