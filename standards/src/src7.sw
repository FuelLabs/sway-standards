library;

use std::{bytes::Bytes, string::String};

abi SRC7 {
    /// Returns metadata for the corresponding `asset` and `key`.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the metadata.
    /// * `key`: [String] - The key to the specific metadata.
    ///
    /// # Returns
    ///
    /// * [Option<Metadata>] - `Some` metadata that corresponds to the `key` or `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src7::{SRC7, Metadata};
    /// use std::string::String;
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC7, contract_id);
    ///     let key = String::from_ascii_str("image");
    ///     let data = contract_abi.metadata(asset, key);
    ///     assert(data.is_some());
    /// }
    /// ```
    #[storage(read)]
    fn metadata(asset: AssetId, key: String) -> Option<Metadata>;
}

/// Universal return type for metadata.
pub enum Metadata {
    // Used when the stored metadata is a `b256`.
    B256: b256,
    /// Used when the stored metadata is `Bytes`.
    Bytes: Bytes,
    /// Used when the stored metadata is a `u64`.
    Int: u64,
    /// Used when the stored metadata is a `String`.
    String: String,
}

/// The event emitted when metadata is set via a function call.
pub struct SetMetadataEvent {
    /// The asset for which metadata is set.
    pub asset: AssetId,
    /// The Metadata that is set.
    pub metadata: Option<Metadata>,
    /// The key used for the metadata.
    pub key: String,
    /// The `Identity` of the caller that set the metadata.
    pub sender: Identity,
}

impl core::ops::Eq for Metadata {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Metadata::B256(bytes1), Metadata::B256(bytes2)) => {
                bytes1 == bytes2
            },
            (Metadata::Bytes(bytes1), Metadata::Bytes(bytes2)) => {
                bytes1 == bytes2
            },
            (Metadata::Int(int1), Metadata::Int(int2)) => {
                int1 == int2
            },
            (Metadata::String(string1), Metadata::String(string2)) => {
                string1 == string2
            },
            _ => false,
        }
    }
}

impl Metadata {
    /// Returns the underlying metadata as a `String`.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - `Some` if the underlying type is a `String`, otherwise `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::string::String;
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     let string = metadata.unwrap().as_string();
    ///     assert(string.len() != 0);
    /// }
    /// ```
    pub fn as_string(self) -> Option<String> {
        match self {
            Self::String(data) => Option::Some(data),
            _ => Option::None,
        }
    }

    /// Returns whether the underlying metadata is a `String`.
    ///
    /// # Returns
    ///
    /// * [bool] - `true` if the metadata is a `String`, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::string::String;
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     assert(metadata.unwrap().is_string());
    /// }
    /// ```
    pub fn is_string(self) -> bool {
        match self {
            Self::String(_) => true,
            _ => false,
        }
    }

    /// Returns the underlying metadata as a `u64`.
    ///
    /// # Returns
    ///
    /// * [Option<u64>] - `Some` if the underlying type is a `u64`, otherwise `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::string::String;
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     let int = metadata.unwrap().as_u64();
    ///     assert(int != 0);
    /// }
    /// ```
    pub fn as_u64(self) -> Option<u64> {
        match self {
            Self::Int(data) => Option::Some(data),
            _ => Option::None,
        }
    }

    /// Returns whether the underlying metadata is a `u64`.
    ///
    /// # Returns
    ///
    /// * [bool] - `true` if the metadata is a `u64`, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::string::String;
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     assert(metadata.unwrap().is_u64());
    /// }
    /// ```
    pub fn is_u64(self) -> bool {
        match self {
            Self::Int(_) => true,
            _ => false,
        }
    }

    /// Returns the underlying metadata as `Bytes`.
    ///
    /// # Returns
    ///
    /// * [Option<Bytes>] - `Some` if the underlying type is `Bytes`, otherwise `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::{bytes::Bytes, string::String};
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     let bytes = metadata.unwrap().as_bytes();
    ///     assert(bytes.len() != 0);
    /// }
    /// ```
    pub fn as_bytes(self) -> Option<Bytes> {
        match self {
            Self::Bytes(data) => Option::Some(data),
            _ => Option::None,
        }
    }

    /// Returns whether the underlying metadata is `Bytes`.
    ///
    /// # Returns
    ///
    /// * [bool] - `true` if the metadata is `Bytes`, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::{bytes::Bytes, string::String};
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     assert(metadata.unwrap().is_bytes());
    /// }
    /// ```
    pub fn is_bytes(self) -> bool {
        match self {
            Self::Bytes(_) => true,
            _ => false,
        }
    }

    /// Returns the underlying metadata as a `b256`.
    ///
    /// # Returns
    ///
    /// * [Option<u64>] - `Some` if the underlying type is a `b256`, otherwise `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::string::String;
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     let val = metadata.unwrap().as_b256();
    ///     assert(val != b256::zero());
    /// }
    /// ```
    pub fn as_b256(self) -> Option<b256> {
        match self {
            Self::B256(data) => Option::Some(data),
            _ => Option::None,
        }
    }

    /// Returns whether the underlying metadata is a `b256`.
    ///
    /// # Returns
    ///
    /// * [bool] - `true` if the metadata is a `b256`, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use std::string::String;
    /// use standards::src7::{SRC7, Metadata};
    ///
    /// fn foo(contract_id: ContractId, asset: AssetId, key: String) {
    ///     let metadata_abi = abi(SRC7, contract_id);
    ///     let metadata: Option<Metadata> = metadata_abi.metadata(asset, key);
    ///
    ///     assert(metadata.unwrap().is_b256());
    /// }
    /// ```
    pub fn is_b256(self) -> bool {
        match self {
            Self::B256(_) => true,
            _ => false,
        }
    }
}
