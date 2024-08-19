library;

use std::{alloc::{alloc, alloc_bytes, realloc_bytes}, bytes::Bytes,};

/// Pre-defined number of bytes of a leaf in a bytecode merkle tree.
const LEAF_SIZE = 16 * 1024;
/// Pre-defined number of bytes of a multiple in a leaf to pad to in a bytecode merkle tree.
const MULTIPLE = 8;
/// Prepended byte to leaves in a bytecode merkle tree.
const LEAF = 0u8;
/// Prepended byte to nodes in a bytecode merkle tree.
const NODE = 1u8;

/// This function is copied from the Sway Libs Bytecode Library.
/// https://github.com/FuelLabs/sway-libs/tree/master/libs/bytecode
fn _generate_leaves(bytecode: raw_slice) -> raw_slice {
    // Number of leaves is '(bytecode.len() / LEAF_SIZE)' if it's perfectly divisible by LEAF_SIZE.
    // Otherwise `(bytecode.len() / LEAF_SIZE) + 1` to account for padding.
    let bytecode_len = bytecode.len::<u8>();
    let num_leaves = match bytecode_len % LEAF_SIZE {
        0 => bytecode_len / LEAF_SIZE,
        _ => bytecode_len / LEAF_SIZE + 1,
    };
    let mut leaves_digest = raw_slice::from_parts::<b256>(alloc::<b256>(num_leaves), num_leaves);

    // Iterate over all the leaves
    let mut leaf_iterator = 0;
    let mut bytes_remaining = bytecode_len;
    while leaf_iterator < num_leaves {
        let leaf_offset_ptr = bytecode.ptr().add_uint_offset(leaf_iterator * LEAF_SIZE);
        let mut digest_ptr = leaves_digest.ptr().add::<b256>(leaf_iterator);

        // Group bytes into leaves of size LEAF_SIZE
        // If we have less than LEAF_SIZE, check if it's a multiple of MULTIPLE.
        // If it is, then simply add it as a leaf.
        // If it isn't, then pad with zeros to the nearest MULTIPLE.
        if bytes_remaining >= LEAF_SIZE {
            // Add leaf with size LEAF_SIZE
            let leaf_slice = raw_slice::from_parts::<u8>(leaf_offset_ptr, LEAF_SIZE);
            _leaf_digest(leaf_slice, digest_ptr);
            bytes_remaining -= LEAF_SIZE;
        } else if bytes_remaining % MULTIPLE == 0 {
            // Leaf size is a multiple of MULTIPLE so no need to pad
            let leaf_slice = raw_slice::from_parts::<u8>(leaf_offset_ptr, bytes_remaining);
            _leaf_digest(leaf_slice, digest_ptr);
        } else {
            // Pad to size of MULTIPLE and then add as a leaf
            let padding = MULTIPLE - (bytes_remaining % MULTIPLE);
            let leaf_offset_ptr = realloc_bytes(leaf_offset_ptr, bytes_remaining, bytes_remaining + padding);
            let leaf_slice = raw_slice::from_parts::<u8>(leaf_offset_ptr, bytes_remaining + padding);
            _leaf_digest(leaf_slice, digest_ptr);
        }

        leaf_iterator += 1;
    }

    leaves_digest
}

/// This function is copied from the Sway Libs Bytecode Library.
/// https://github.com/FuelLabs/sway-libs/tree/master/libs/bytecode
pub fn _compute_bytecode_root(bytecode: raw_slice) -> b256 {
    let mut vec_digest = _generate_leaves(bytecode);
    let vec_digest_len = vec_digest.len::<b256>();
    let mut size = (vec_digest_len + 1) >> 1;
    let mut odd = vec_digest_len & 1;

    while true {
        // Iterate over this level
        let mut iterator = 0;
        while iterator < size - odd {
            let j = iterator << 1;

            _node_digest(
                vec_digest
                    .ptr()
                    .add::<b256>(j),
                vec_digest
                    .ptr()
                    .add::<b256>(j + 1),
                vec_digest
                    .ptr()
                    .add::<b256>(iterator),
            );

            iterator += 1;
        }

        // Check if we have an odd or even amount of nodes at this level
        if odd == 1 && vec_digest_len > 1 {
            vec_digest
                .ptr()
                .add::<b256>(iterator << 1)
                .copy_bytes_to(vec_digest.ptr().add::<b256>(iterator), 32);
        }

        // If we only have one node left then that is the root
        if size == 1 {
            break;
        }

        odd = size & 1;
        size = (size + 1) >> 1;
    }

    vec_digest.ptr().read::<b256>()
}

/// This function is copied from the Sway Libs Bytecode Library.
/// https://github.com/FuelLabs/sway-libs/tree/master/libs/bytecode
pub fn _swap_configurables(
    ref mut bytecode: raw_slice,
    configurables: Vec<(u64, Vec<u8>)>,
) {
    // Iterate over every configurable
    let mut configurable_iterator = 0;
    while configurable_iterator < configurables.len() {
        let (offset, data) = configurables.get(configurable_iterator).unwrap();

        // Overwrite the configurable data into the bytecode
        data
            .ptr()
            .copy_bytes_to(bytecode.ptr().add::<u8>(offset), data.len());

        configurable_iterator += 1;
    }
}

/// This function is copied from the Sway Libs Bytecode Library.
/// https://github.com/FuelLabs/sway-libs/tree/master/libs/bytecode
fn _leaf_digest(data: raw_slice, ref mut result_buffer: raw_ptr) {
    let number_of_bytes = data.number_of_bytes();
    let ptr = alloc_bytes(number_of_bytes + 1);

    // Prepend LEAF to the leaf bytes
    ptr.write_byte(LEAF);
    data
        .ptr()
        .copy_bytes_to(ptr.add_uint_offset(1), number_of_bytes);

    // Compute the digest
    asm(hash: result_buffer, ptr: ptr, bytes: number_of_bytes + 1) {
        s256 hash ptr bytes;
    };
}

/// This function is copied from the Sway Libs Bytecode Library.
/// https://github.com/FuelLabs/sway-libs/tree/master/libs/bytecode
fn _node_digest(left: raw_ptr, right: raw_ptr, result_buffer: raw_ptr) {
    let ptr = alloc_bytes(65);

    // Prepend NODE and concat the 2 node bytes for the current node
    ptr.write_byte(NODE);
    left.copy_bytes_to(ptr.add_uint_offset(1), 32);
    right.copy_bytes_to(ptr.add_uint_offset(33), 32);

    // Compute the digest
    asm(hash: result_buffer, ptr: ptr, bytes: 65) {
        s256 hash ptr bytes;
    };
}
