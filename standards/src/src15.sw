library;

use ::src7::Metadata;

/// The required event to be emitted for the SRC-15 standard.
pub struct SRC15MetadataEvent {
    /// The asset for which metadata is associated with.
    pub asset: AssetId,
    /// The Metadata of the SRC-15 event.
    pub metadata: Metadata,
    /// The `Identity` of the caller that emitted the metadata.
    pub sender: Identity,
}

impl core::ops::Eq for SRC15MetadataEvent {
    fn eq(self, other: Self) -> bool {
        self.asset == other.asset && self.metadata == other.metadata && self.sender == other.sender
    }
}

impl SRC15MetadataEvent {
    /// Returns a new `SRC15MetadataEvent` event.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which metadata is set.
    /// * `metadata`: [Option<Metdata>] - The Metadata that is set.
    /// * `sender`: [Identity] - The caller that set the metadata.
    ///
    /// # Returns
    ///
    /// * [SRC15MetadataEvent] - The new `SRC15MetadataEvent` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15MetadataEvent};
    ///
    /// fn foo(asset: AssetId, metadata: Metadata, sender: Identity) {
    ///     let my_src15_metadata_event = SRC15MetadataEvent::new(asset, metadata, sender);
    ///     assert(my_src15_metadata_event.asset == asset);
    ///     assert(my_src15_metadata_event.metadata == metadata);
    ///     assert(my_src15_metadata_event.sender == sender);
    /// }
    /// ```
    pub fn new(
        asset: AssetId,
        metadata: Metadata,
        sender: Identity,
    ) -> Self {
        Self {
            asset,
            metadata,
            sender,
        }
    }

    /// Returns the asset of the `SRC15MetadataEvent` event.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15MetadataEvent};
    ///
    /// fn foo(asset: AssetId, metadata: Metadata, sender: Identity) {
    ///     let my_src15_metadata_event = SRC15MetadataEvent::new(asset, metadata, sender);
    ///     assert(my_src15_metadata_event.asset() == asset);
    /// }
    /// ```
    pub fn asset(self) -> AssetId {
        self.asset
    }

    /// Returns the metadata of the `v` event.
    ///
    /// # Returns
    ///
    /// * [Option<Metadata>] - The metadata for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15MetadataEvent};
    ///
    /// fn foo(asset: AssetId, metadata: Metadata, sender: Identity) {
    ///     let my_src15_metadata_event = SRC15MetadataEvent::new(asset, metadata, sender);
    ///     assert(my_src15_metadata_event.metadata() == metadata);
    /// }
    /// ```
    pub fn metadata(self) -> Metadata {
        self.metadata
    }

    /// Returns the sender of the `SRC15MetadataEvent` event.
    ///
    /// # Returns
    ///
    /// * [Identity] - The sender of the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15MetadataEvent};
    ///
    /// fn foo(asset: AssetId, metadata: Metadata, sender: Identity) {
    ///     let my_src15_metadata_event = SRC15MetadataEvent::new(asset, metadata, sender);
    ///     assert(my_src15_metadata_event.sender() == sender);
    /// }
    /// ```
    pub fn sender(self) -> Identity {
        self.sender
    }

    /// Logs the `SRC15MetadataEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15MetadataEvent};
    ///
    /// fn foo(asset: AssetId, metadata: Metadata, sender: Identity) {
    ///     let my_event = SRC15MetadataEvent::new(asset, metadata, sender);
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}
