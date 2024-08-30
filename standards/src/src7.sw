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
