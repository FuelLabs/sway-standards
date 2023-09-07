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
    /// * [Option<MetadataType>] - `Some` metadata that corresponds to the `key` or `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src_7::{SRC7, MetadataType};
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
    fn metadata(asset: AssetId, key: String) -> Option<MetadataType>;
}

/// Universal return type for metadata.
pub enum MetadataType {
    /// Used when the stored metadata is a `String`.
    StringData: String,
    /// Used when the stored metadata is a `u64`.
    IntData: u64,
    /// Used when the stored metadata is a `u64`.
    BytesData: Bytes,
}
