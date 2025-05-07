contract;

use std::{bytes::Bytes, hash::{Hash, sha256}, string::String};
use standards::src17::*;
use sway_libs::merkle::{common::MerkleRoot, sparse::*};

storage {
    merkle_root: MerkleRoot = MerkleRoot::zero(),
}

impl SRC17 for Contract {
    #[storage(read)]
    fn verify(
        proof: SRC17Proof,
        name: String,
        resolver: Identity,
        asset: AssetId,
        metadata: Option<Bytes>,
    ) -> Result<(), SRC17VerificationError> {
        match proof {
            SRC17Proof::AltBn128Proof(_) => Err(SRC17VerificationError::VerificationFailed),
            SRC17Proof::SparseMerkleProof(proof) => {
                let key: MerkleTreeKey = sha256(name);

                match proof {
                    Proof::Inclusion => {
                        // Combine the resolver, asset, and metadata into to a single Byte array.
                        let mut leaf_bytes = Bytes::new();
                        leaf_bytes.append(resolver.bits().into());
                        leaf_bytes.append(asset.bits().into());
                        match metadata {
                            Some(metadata_bytes) => {
                                leaf_bytes.append(metadata_bytes);
                            },
                            None => (),
                        }

                        if proof.verify(storage.merkle_root.read(), key, Some(leaf_bytes))
                        {
                            Ok(())
                        } else {
                            Err(SRC17VerificationError::VerificationFailed)
                        }
                    },
                    Proof::Exclusion => {
                        if proof.verify(storage.merkle_root.read(), key, None) {
                            Ok(())
                        } else {
                            Err(SRC17VerificationError::VerificationFailed)
                        }
                    }
                }
            }
        }
    }
}

abi UpdateData {
    fn data_updated(
        name: String,
        resolver: Identity,
        asset: AssetId,
        metadata: Option<Bytes>,
    );
}

impl UpdateData for Contract {
    fn data_updated(
        name: String,
        resolver: Identity,
        asset: AssetId,
        metadata: Option<Bytes>,
    ) {
        // NOTE: There are no checks for whether someone has the permission to do this. 
        // It is suggested to add some administrative controls such as the Sway-Libs Ownership Library.
        let event = SRC17NameEvent::new(name, resolver, asset, metadata);
        event.log();
    }
}

abi SetupExample {
    #[storage(write)]
    fn initialize(root: MerkleRoot);
}

impl SetupExample for Contract {
    #[storage(write)]
    fn initialize(root: MerkleRoot) {
        // NOTE: There are no checks for whether someone has the permission to do this. 
        // It is suggested to add some administrative controls such as the Sway-Libs Ownership Library.
        storage.merkle_root.write(root);
    }
}
