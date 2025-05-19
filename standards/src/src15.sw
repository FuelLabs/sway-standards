library;

use ::src7::Metadata;

/// The required event to be emitted for the SRC-15 standard.
pub struct SRC15MetadataEvent {
    /// The asset for which metadata is associated with.
    pub asset: AssetId,
    /// The Metadata of the SRC-15 event.
    pub metadata: Metadata,
}

impl PartialEq for SRC15MetadataEvent {
    fn eq(self, other: Self) -> bool {
        self.asset == other.asset && self.metadata == other.metadata
    }
}

impl Eq for SRC15MetadataEvent {}

impl SRC15MetadataEvent {
    /// Returns a new `SRC15MetadataEvent` event.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset for which metadata is set.
    /// * `metadata`: [Option<Metdata>] - The Metadata that is set.
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
    /// fn foo(asset: AssetId, metadata: Metadata) {
    ///     let my_src15_metadata_event = SRC15MetadataEvent::new(asset, metadata);
    ///     assert(my_src15_metadata_event.asset == asset);
    ///     assert(my_src15_metadata_event.metadata == metadata);
    /// }
    /// ```
    pub fn new(asset: AssetId, metadata: Metadata) -> Self {
        Self {
            asset,
            metadata,
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
    /// fn foo(asset: AssetId, metadata: Metadata) {
    ///     let my_src15_metadata_event = SRC15MetadataEvent::new(asset, metadata);
    ///     assert(my_src15_metadata_event.asset() == asset);
    /// }
    /// ```
    pub fn asset(self) -> AssetId {
        self.asset
    }

    /// Returns the metadata of the `SRC15MetadataEvent` event.
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
    /// fn foo(asset: AssetId, metadata: Metadata) {
    ///     let my_src15_metadata_event = SRC15MetadataEvent::new(asset, metadata);
    ///     assert(my_src15_metadata_event.metadata() == metadata);
    /// }
    /// ```
    pub fn metadata(self) -> Metadata {
        self.metadata
    }

    /// Logs the `SRC15MetadataEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15MetadataEvent};
    ///
    /// fn foo(asset: AssetId, metadata: Metadata) {
    ///     let my_event = SRC15MetadataEvent::new(asset, metadata);
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}

/// The required event to be emitted for the SRC-15 standard.
pub struct SRC15GlobalMetadataEvent {
    /// The Metadata of the SRC-15 event.
    pub metadata: Metadata,
}

impl PartialEq for SRC15GlobalMetadataEvent {
    fn eq(self, other: Self) -> bool {
        self.metadata == other.metadata
    }
}

impl Eq for SRC15GlobalMetadataEvent {}

impl SRC15GlobalMetadataEvent {
    /// Returns a new `SRC15GlobalMetadataEvent` event.
    ///
    /// # Arguments
    ///
    /// * `metadata`: [Option<Metdata>] - The Metadata that is set.
    ///
    /// # Returns
    ///
    /// * [SRC15GlobalMetadataEvent] - The new `SRC15GlobalMetadataEvent` event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15GlobalMetadataEvent};
    ///
    /// fn foo(metadata: Metadata) {
    ///     let my_src15_metadata_event = SRC15GlobalMetadataEvent::new(metadata);
    ///     assert(my_src15_metadata_event.metadata == metadata);
    /// }
    /// ```
    pub fn new(metadata: Metadata) -> Self {
        Self {
            metadata,
        }
    }

    /// Returns the metadata of the `SRC15GlobalMetadataEvent` event.
    ///
    /// # Returns
    ///
    /// * [Option<Metadata>] - The metadata for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15GlobalMetadataEvent};
    ///
    /// fn foo(metadata: Metadata) {
    ///     let my_src15_metadata_event = SRC15GlobalMetadataEvent::new(metadata);
    ///     assert(my_src15_metadata_event.metadata() == metadata);
    /// }
    /// ```
    pub fn metadata(self) -> Metadata {
        self.metadata
    }

    /// Logs the `SRC15GlobalMetadataEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::{src7::Metadata, src15::SRC15GlobalMetadataEvent};
    ///
    /// fn foo(metadata: Metadata) {
    ///     let my_event = SRC15GlobalMetadataEvent::new(metadata);
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}
