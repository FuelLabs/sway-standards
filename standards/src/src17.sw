library;

use std::{bytes::Bytes, string::String};
use sway_libs::merkle::sparse::Proof;

/// AltBN128 proof data.
pub type AltBn128Proof = [u8; 288];
/// Sparse Merkle Tree proof data.
pub type SparseMerkleProof = Proof;

#[cfg(experimental_const_generics = false)]
impl AbiEncode for AltBn128Proof {
    fn abi_encode(self, buffer: Buffer) -> Buffer {
        let mut buffer = buffer;
        let mut i = 0;
        while i < 288 {
            buffer = self[i].abi_encode(buffer);
            i += 1;
        };
        buffer
    }
}

#[cfg(experimental_const_generics = false)]
impl AbiDecode for AltBn128Proof {
    fn abi_decode(ref mut buffer: BufferReader) -> [u8; 288] {
        let first: u8 = buffer.decode::<u8>();
        let mut array = [first; 288];
        let mut i = 1;
        while i < 288 {
            array[i] = buffer.decode::<u8>();
            i += 1;
        };
        array
    }
}

/// The error log used something in the SRC-17 verification process fails.
pub enum SRC17VerificationError {
    /// Emitted when verification of a SRC-17 proof fails.
    VerificationFailed: (),
}

impl PartialEq for SRC17VerificationError {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Self::VerificationFailed, Self::VerificationFailed) => {
                true
            },
        }
    }
}

impl Eq for SRC17VerificationError {}

/// A SRC-17 proof, either an AltBN128 proof or a Sparse Merkle Tree proof.
pub enum SRC17Proof {
    /// An AltBN128 proof.
    AltBn128Proof: AltBn128Proof,
    /// A Sparse Merkle Tree proof.
    SparseMerkleProof: SparseMerkleProof,
}

impl PartialEq for SRC17Proof {
    fn eq(self, other: Self) -> bool {
        match (self, other) {
            (Self::AltBn128Proof(proof_1), Self::AltBn128Proof(proof_2)) => {
                let mut i = 1;
                while i < 288 {
                    if proof_1[i] != proof_2[i] {
                        return false
                    }
                    i += 1;
                }
                true
            },
            (Self::SparseMerkleProof(proof_1), Self::SparseMerkleProof(proof_2)) => {
                proof_1 == proof_2
            },
            _ => false,
        }
    }
}

impl Eq for SRC17Proof {}

impl SRC17Proof {
    /// Returns whether the `SRC17Proof` is an AltBN128 proof.
    ///
    /// # Returns
    ///
    /// * [bool] - `true` if this is an AltBN128 proof, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17Proof;
    ///
    /// fn foo(my_proof: SRC17Proof) {
    ///     let result: bool = my_proof.is_alt_bn128_proof();
    ///     assert(result);
    /// }
    /// ```
    fn is_alt_bn128_proof(self) -> bool {
        match self {
            Self::AltBn128Proof(_) => true,
            Self::SparseMerkleProof(_) => false,
        }
    }

    /// Returns whether the `SRC17Proof` is a Sparse Merkle Tree proof.
    ///
    /// # Returns
    ///
    /// * [bool] - `true` if this is a Sparse Merkle Tree proof, otherwise `false`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17Proof;
    ///
    /// fn foo(my_proof: SRC17Proof) {
    ///     let result: bool = my_proof.is_sparse_merkle_proof();
    ///     assert(result);
    /// }
    /// ```
    fn is_sparse_merkle_proof(self) -> bool {
        match self {
            Self::AltBn128Proof(_) => false,
            Self::SparseMerkleProof(_) => true,
        }
    }

    /// Returns the `SRC17Proof` as an AltBN128 proof.
    ///
    /// # Returns
    ///
    /// * [Option<AltBn128Proof>] - `Some` if this is an AltBn128 proof, otherwise `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17Proof;
    ///
    /// fn foo(my_proof: SRC17Proof) {
    ///     let result: Option<AltBn128Proof> = my_proof.as_alt_bn128_proof();
    ///     assert(result.is_some());
    /// }
    /// ```
    fn as_alt_bn128_proof(self) -> Option<AltBn128Proof> {
        match self {
            Self::AltBn128Proof(proof) => Some(proof),
            Self::SparseMerkleProof(_) => None,
        }
    }

    /// Returns the `SRC17Proof` as a Sparse Merkle Tree proof.
    ///
    /// # Returns
    ///
    /// * [Option<SparseMerkleProof>] - `Some` if this is a Sparse Merkle Tree proof, otherwise `None`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17Proof;
    ///
    /// fn foo(my_proof: SRC17Proof) {
    ///     let result: Option<SparseMerkleProof> = my_proof.as_sparse_merkle_proof();
    ///     assert(result.is_some());
    /// }
    /// ```
    fn as_sparse_merkle_proof(self) -> Option<SparseMerkleProof> {
        match self {
            Self::AltBn128Proof(_) => None,
            Self::SparseMerkleProof(proof) => Some(proof),
        }
    }
}

abi SRC17 {
    /// Verifies the validity of a name.
    ///
    /// # Arguments
    ///
    /// * `proof`: [SRC17Proof] - The proof which is used to verify against.
    /// * `name`: [String] - The name of the onchain identity.
    /// * `resolver`: [Identity] - The `Identity` which the name resolved to.
    /// * `asset`: [AssetId] - The asset which represents ownership of the name.
    /// * `metadata`: [Option<Bytes>] - `Some` metadata associated with the `name`, or `None`.
    ///
    /// # Returns
    ///
    /// * [Result<(), SRC17VerificationError>] - `Ok(())` if verification passed, otherwise an `Err`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17;
    ///
    /// fn foo(contract_id: ContractId, proof: SRC17Proof, name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) {
    ///     let contract_abi = abi(SRC17, contract_id.bits());
    ///
    ///     let result = contract_abi.verify(proof, name, resolver, asset, metadata);
    ///     assert(result.is_ok());
    /// }
    /// ```
    #[storage(read)]
    fn verify(
        proof: SRC17Proof,
        name: String,
        resolver: Identity,
        asset: AssetId,
        metadata: Option<Bytes>,
    ) -> Result<(), SRC17VerificationError>;
}

/// The event used when a data change occurs.
pub struct SRC17NameEvent {
    /// The name of the onchain identity.
    pub name: String,
    /// The `Identity` which the name resolves to.
    pub resolver: Identity,
    /// The asset which represents ownership of the name.
    pub asset: AssetId,
    /// Any metadata associated with the name.
    pub metadata: Option<Bytes>,
}

impl SRC17NameEvent {
    /// Returns a new `SRC17NameEvent`.
    ///
    /// # Arguments
    ///
    /// * `name`: [String] - The name for which the event is for.
    /// * `resolver`: [Identity] - The `Identity` which the name resolves to.
    /// * `asset`: [AssetId] - The asset which represents ownership of the name.
    /// * `metadata`: [Option<Bytes>] - any metadata associated with the name.
    ///
    /// # Returns
    ///
    /// * [SRC17NameEvent] - The newly created event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17NameEvent;
    ///
    /// fn foo(name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) {
    ///     let my_event = SRC17NameEvent::new(name, resolver, asset, metadata);
    ///     my_event.log();
    /// }
    /// ```
    pub fn new(
        name: String,
        resolver: Identity,
        asset: AssetId,
        metadata: Option<Bytes>,
    ) -> Self {
        Self {
            name,
            resolver,
            asset,
            metadata,
        }
    }

    /// Returns the name associated with the `SRC17NameEvent`.
    ///
    /// # Returns
    ///
    /// * [String] - The name for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17NameEvent;
    ///
    /// fn foo(name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) {
    ///     let my_event = SRC17NameEvent::new(name, resolver, asset, metadata);
    ///
    ///     let returned_name: String = my_event.name();
    ///     assert(returned_name == name);
    /// }
    /// ```
    pub fn name(self) -> String {
        self.name
    }

    /// Returns the resolver associated with the `SRC17NameEvent`.
    ///
    /// # Returns
    ///
    /// * [Identity] - The resolver for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17NameEvent;
    ///
    /// fn foo(name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) {
    ///     let my_event = SRC17NameEvent::new(name, resolver, asset, metadata);
    ///
    ///     let returned_resolver: String = my_event.resolver();
    ///     assert(returned_resolver == resolver);
    /// }
    /// ```
    pub fn resolver(self) -> Identity {
        self.resolver
    }

    /// Returns the asset associated with the `SRC17NameEvent`.
    ///
    /// # Returns
    ///
    /// * [AssetId] - The asset for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17NameEvent;
    ///
    /// fn foo(name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) {
    ///     let my_event = SRC17NameEvent::new(name, resolver, asset, metadata);
    ///
    ///     let returned_asset: String = my_event.asset();
    ///     assert(returned_asset == asset);
    /// }
    /// ```
    pub fn asset(self) -> AssetId {
        self.asset
    }

    /// Returns the metadata associated with the `SRC17NameEvent`.
    ///
    /// # Returns
    ///
    /// * [Option<Bytes>] - The metadata for the event.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17NameEvent;
    ///
    /// fn foo(name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) {
    ///     let my_event = SRC17NameEvent::new(name, resolver, asset, metadata);
    ///
    ///     let returned_metadata: String = my_event.metadata();
    ///     assert(returned_metadata == metadata);
    /// }
    /// ```
    pub fn metadata(self) -> Option<Bytes> {
        self.metadata
    }

    /// Logs the `SRC17NameEvent`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src17::SRC17NameEvent;
    ///
    /// fn foo(name: String, resolver: Identity, asset: AssetId, metadata: Option<Bytes>) {
    ///     let my_event = SRC17NameEvent::new(name, resolver, asset, metadata);
    ///
    ///     my_event.log();
    /// }
    /// ```
    pub fn log(self) {
        log(self);
    }
}

impl PartialEq for SRC17NameEvent {
    fn eq(self, other: Self) -> bool {
        self.name == other.name && self.asset == other.asset && self.resolver == other.resolver && self.metadata == other.metadata
    }
}

impl Eq for SRC17NameEvent {}
