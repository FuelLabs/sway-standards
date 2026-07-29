library;

use benchmarking::*;
use src16::*;
use std::string::*;

// Fixtures for `DataEncoder` (the `TypedDataEncoder` implementation).

#[inline(never)]
fn fixture_create_string() -> String {
    String::from_ascii_str("SampleStringValueForEncoding")
}

#[inline(never)]
fn fixture_create_u8() -> u8 {
    0x42u8
}

#[inline(never)]
fn fixture_create_u16() -> u16 {
    0x4242u16
}

#[inline(never)]
fn fixture_create_u32() -> u32 {
    0x42424242u32
}

#[inline(never)]
fn fixture_create_u64() -> u64 {
    0x4242424242424242u64
}

#[inline(never)]
fn fixture_create_u256() -> u256 {
    0x4242424242424242424242424242424242424242424242424242424242424242u256
}

#[inline(never)]
fn fixture_create_b256() -> b256 {
    0x4242424242424242424242424242424242424242424242424242424242424242
}

#[inline(never)]
fn fixture_create_bool() -> bool {
    true
}

#[inline(never)]
fn fixture_create_address() -> Address {
    Address::zero()
}

#[inline(never)]
fn fixture_create_contract_id() -> ContractId {
    ContractId::zero()
}

#[inline(never)]
fn fixture_create_identity() -> Identity {
    Identity::Address(Address::zero())
}

// Dynamic-array fixtures are parameterized by length so that the same
// (`#[inline(never)]`) build cost cancels between a benchmark and its baseline
// at each length. Benching at two lengths lets us derive the per-element cost
// (slope) and the fixed overhead (intercept) of the `dynamic_*_array` encoders.

#[inline(never)]
fn fixture_create_vec_u8(len: u64) -> Vec<u8> {
    let mut v = Vec::new();
    let mut i = 0;
    while i < len {
        v.push(0x42u8);
        i += 1;
    }
    v
}

#[inline(never)]
fn fixture_create_vec_u16(len: u64) -> Vec<u16> {
    let mut v = Vec::new();
    let mut i = 0;
    while i < len {
        v.push(0x4242u16);
        i += 1;
    }
    v
}

#[inline(never)]
fn fixture_create_vec_u32(len: u64) -> Vec<u32> {
    let mut v = Vec::new();
    let mut i = 0;
    while i < len {
        v.push(0x42424242u32);
        i += 1;
    }
    v
}

#[inline(never)]
fn fixture_create_vec_u64(len: u64) -> Vec<u64> {
    let mut v = Vec::new();
    let mut i = 0;
    while i < len {
        v.push(0x4242424242424242u64);
        i += 1;
    }
    v
}

#[inline(never)]
fn fixture_create_vec_u256(len: u64) -> Vec<u256> {
    let mut v = Vec::new();
    let mut i = 0;
    while i < len {
        v.push(0x4242424242424242424242424242424242424242424242424242424242424242u256);
        i += 1;
    }
    v
}

#[inline(never)]
fn fixture_create_vec_b256(len: u64) -> Vec<b256> {
    let mut v = Vec::new();
    let mut i = 0;
    while i < len {
        v.push(0x4242424242424242424242424242424242424242424242424242424242424242);
        i += 1;
    }
    v
}

#[test]
fn baseline__typed_data_encoder__encode_string() {
    let _ = fixture_create_string();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_string() {
    let value = fixture_create_string();

    let encoded = DataEncoder::encode_string(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_u8() {
    let _ = fixture_create_u8();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_u8() {
    let value = fixture_create_u8();

    let encoded = DataEncoder::encode_u8(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_u16() {
    let _ = fixture_create_u16();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_u16() {
    let value = fixture_create_u16();

    let encoded = DataEncoder::encode_u16(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_u32() {
    let _ = fixture_create_u32();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_u32() {
    let value = fixture_create_u32();

    let encoded = DataEncoder::encode_u32(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_u64() {
    let _ = fixture_create_u64();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_u64() {
    let value = fixture_create_u64();

    let encoded = DataEncoder::encode_u64(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_u256() {
    let _ = fixture_create_u256();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_u256() {
    let value = fixture_create_u256();

    let encoded = DataEncoder::encode_u256(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_b256() {
    let _ = fixture_create_b256();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_b256() {
    let value = fixture_create_b256();

    let encoded = DataEncoder::encode_b256(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_bool() {
    let _ = fixture_create_bool();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_bool() {
    let value = fixture_create_bool();

    let encoded = DataEncoder::encode_bool(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_address() {
    let _ = fixture_create_address();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_address() {
    let value = fixture_create_address();

    let encoded = DataEncoder::encode_address(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_contract_id() {
    let _ = fixture_create_contract_id();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_contract_id() {
    let value = fixture_create_contract_id();

    let encoded = DataEncoder::encode_contract_id(value);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__encode_identity() {
    let _ = fixture_create_identity();
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__encode_identity() {
    let value = fixture_create_identity();

    let encoded = DataEncoder::encode_identity(value);
    keep(encoded);
}

// The `dynamic_*_array` encoders are length-dependent. Each is benched at two
// lengths (1 and 8). Per-element cost = (net(8) - net(1)) / (8 - 1), and the
// fixed overhead = net(1) - per-element cost, where net(len) is
// `gas(bench __len) - gas(baseline __len)`.

#[test]
fn baseline__typed_data_encoder__dynamic_u8_array__len_1() {
    let _ = fixture_create_vec_u8(1);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u8_array__len_1() {
    let array = fixture_create_vec_u8(1);

    let encoded = DataEncoder::dynamic_u8_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u8_array__len_8() {
    let _ = fixture_create_vec_u8(8);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u8_array__len_8() {
    let array = fixture_create_vec_u8(8);

    let encoded = DataEncoder::dynamic_u8_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u16_array__len_1() {
    let _ = fixture_create_vec_u16(1);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u16_array__len_1() {
    let array = fixture_create_vec_u16(1);

    let encoded = DataEncoder::dynamic_u16_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u16_array__len_8() {
    let _ = fixture_create_vec_u16(8);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u16_array__len_8() {
    let array = fixture_create_vec_u16(8);

    let encoded = DataEncoder::dynamic_u16_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u32_array__len_1() {
    let _ = fixture_create_vec_u32(1);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u32_array__len_1() {
    let array = fixture_create_vec_u32(1);

    let encoded = DataEncoder::dynamic_u32_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u32_array__len_8() {
    let _ = fixture_create_vec_u32(8);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u32_array__len_8() {
    let array = fixture_create_vec_u32(8);

    let encoded = DataEncoder::dynamic_u32_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u64_array__len_1() {
    let _ = fixture_create_vec_u64(1);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u64_array__len_1() {
    let array = fixture_create_vec_u64(1);

    let encoded = DataEncoder::dynamic_u64_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u64_array__len_8() {
    let _ = fixture_create_vec_u64(8);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u64_array__len_8() {
    let array = fixture_create_vec_u64(8);

    let encoded = DataEncoder::dynamic_u64_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u256_array__len_1() {
    let _ = fixture_create_vec_u256(1);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u256_array__len_1() {
    let array = fixture_create_vec_u256(1);

    let encoded = DataEncoder::dynamic_u256_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_u256_array__len_8() {
    let _ = fixture_create_vec_u256(8);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_u256_array__len_8() {
    let array = fixture_create_vec_u256(8);

    let encoded = DataEncoder::dynamic_u256_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_b256_array__len_1() {
    let _ = fixture_create_vec_b256(1);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_b256_array__len_1() {
    let array = fixture_create_vec_b256(1);

    let encoded = DataEncoder::dynamic_b256_array(array);
    keep(encoded);
}

#[test]
fn baseline__typed_data_encoder__dynamic_b256_array__len_8() {
    let _ = fixture_create_vec_b256(8);
    keep_ref_type(); // encoded
}

#[test]
fn bench__typed_data_encoder__dynamic_b256_array__len_8() {
    let array = fixture_create_vec_b256(8);

    let encoded = DataEncoder::dynamic_b256_array(array);
    keep(encoded);
}

// Aggregate benchmarks: call every `TypedDataEncoder` method in a single test.
//
// `__all` calls each encoder once. A function called from exactly one site is
// always inlined, so this measures the encoders as inlined into one body, where
// the compiler may both optimize across them and have `asm` blocks interfere
// with optimizations.
//
// `__all_twice` calls each encoder twice (two call sites). Two call sites can
// stop the inliner from inlining, keeping each encoder (and its `asm` block) as
// an out-of-line call. Comparing `net(all_twice)` against `2 * net(all)` exposes
// how much inlining the `asm`-heavy encoders helps or hurts.
//
// Dynamic arrays are exercised at length 1 here; their length scaling is already
// characterized by the dedicated `__len_*` benchmarks above.

#[test]
fn baseline__typed_data_encoder__all() {
    let _ = fixture_create_string();
    let _ = fixture_create_u8();
    let _ = fixture_create_u16();
    let _ = fixture_create_u32();
    let _ = fixture_create_u64();
    let _ = fixture_create_u256();
    let _ = fixture_create_b256();
    let _ = fixture_create_bool();
    let _ = fixture_create_address();
    let _ = fixture_create_contract_id();
    let _ = fixture_create_identity();
    let _ = fixture_create_vec_u8(1);
    let _ = fixture_create_vec_u16(1);
    let _ = fixture_create_vec_u32(1);
    let _ = fixture_create_vec_u64(1);
    let _ = fixture_create_vec_u256(1);
    let _ = fixture_create_vec_b256(1);

    keep_ref_type(); // encode_string
    keep_ref_type(); // encode_u8
    keep_ref_type(); // encode_u16
    keep_ref_type(); // encode_u32
    keep_ref_type(); // encode_u64
    keep_ref_type(); // encode_u256
    keep_ref_type(); // encode_b256
    keep_ref_type(); // encode_bool
    keep_ref_type(); // encode_address
    keep_ref_type(); // encode_contract_id
    keep_ref_type(); // encode_identity
    keep_ref_type(); // dynamic_u8_array
    keep_ref_type(); // dynamic_u16_array
    keep_ref_type(); // dynamic_u32_array
    keep_ref_type(); // dynamic_u64_array
    keep_ref_type(); // dynamic_u256_array
    keep_ref_type(); // dynamic_b256_array
}

#[test]
fn bench__typed_data_encoder__all() {
    keep(DataEncoder::encode_string(fixture_create_string()));
    keep(DataEncoder::encode_u8(fixture_create_u8()));
    keep(DataEncoder::encode_u16(fixture_create_u16()));
    keep(DataEncoder::encode_u32(fixture_create_u32()));
    keep(DataEncoder::encode_u64(fixture_create_u64()));
    keep(DataEncoder::encode_u256(fixture_create_u256()));
    keep(DataEncoder::encode_b256(fixture_create_b256()));
    keep(DataEncoder::encode_bool(fixture_create_bool()));
    keep(DataEncoder::encode_address(fixture_create_address()));
    keep(DataEncoder::encode_contract_id(fixture_create_contract_id()));
    keep(DataEncoder::encode_identity(fixture_create_identity()));
    keep(DataEncoder::dynamic_u8_array(fixture_create_vec_u8(1)));
    keep(DataEncoder::dynamic_u16_array(fixture_create_vec_u16(1)));
    keep(DataEncoder::dynamic_u32_array(fixture_create_vec_u32(1)));
    keep(DataEncoder::dynamic_u64_array(fixture_create_vec_u64(1)));
    keep(DataEncoder::dynamic_u256_array(fixture_create_vec_u256(1)));
    keep(DataEncoder::dynamic_b256_array(fixture_create_vec_b256(1)));
}

#[test]
fn baseline__typed_data_encoder__all_twice() {
    // Call 1
    let _ = fixture_create_string();
    let _ = fixture_create_u8();
    let _ = fixture_create_u16();
    let _ = fixture_create_u32();
    let _ = fixture_create_u64();
    let _ = fixture_create_u256();
    let _ = fixture_create_b256();
    let _ = fixture_create_bool();
    let _ = fixture_create_address();
    let _ = fixture_create_contract_id();
    let _ = fixture_create_identity();
    let _ = fixture_create_vec_u8(1);
    let _ = fixture_create_vec_u16(1);
    let _ = fixture_create_vec_u32(1);
    let _ = fixture_create_vec_u64(1);
    let _ = fixture_create_vec_u256(1);
    let _ = fixture_create_vec_b256(1);

    keep_ref_type(); // encode_string
    keep_ref_type(); // encode_u8
    keep_ref_type(); // encode_u16
    keep_ref_type(); // encode_u32
    keep_ref_type(); // encode_u64
    keep_ref_type(); // encode_u256
    keep_ref_type(); // encode_b256
    keep_ref_type(); // encode_bool
    keep_ref_type(); // encode_address
    keep_ref_type(); // encode_contract_id
    keep_ref_type(); // encode_identity
    keep_ref_type(); // dynamic_u8_array
    keep_ref_type(); // dynamic_u16_array
    keep_ref_type(); // dynamic_u32_array
    keep_ref_type(); // dynamic_u64_array
    keep_ref_type(); // dynamic_u256_array
    keep_ref_type(); // dynamic_b256_array

    // Call 2
    let _ = fixture_create_string();
    let _ = fixture_create_u8();
    let _ = fixture_create_u16();
    let _ = fixture_create_u32();
    let _ = fixture_create_u64();
    let _ = fixture_create_u256();
    let _ = fixture_create_b256();
    let _ = fixture_create_bool();
    let _ = fixture_create_address();
    let _ = fixture_create_contract_id();
    let _ = fixture_create_identity();
    let _ = fixture_create_vec_u8(1);
    let _ = fixture_create_vec_u16(1);
    let _ = fixture_create_vec_u32(1);
    let _ = fixture_create_vec_u64(1);
    let _ = fixture_create_vec_u256(1);
    let _ = fixture_create_vec_b256(1);

    keep_ref_type(); // encode_string
    keep_ref_type(); // encode_u8
    keep_ref_type(); // encode_u16
    keep_ref_type(); // encode_u32
    keep_ref_type(); // encode_u64
    keep_ref_type(); // encode_u256
    keep_ref_type(); // encode_b256
    keep_ref_type(); // encode_bool
    keep_ref_type(); // encode_address
    keep_ref_type(); // encode_contract_id
    keep_ref_type(); // encode_identity
    keep_ref_type(); // dynamic_u8_array
    keep_ref_type(); // dynamic_u16_array
    keep_ref_type(); // dynamic_u32_array
    keep_ref_type(); // dynamic_u64_array
    keep_ref_type(); // dynamic_u256_array
    keep_ref_type(); // dynamic_b256_array
}

#[test]
fn bench__typed_data_encoder__all_twice() {
    // Call 1
    keep(DataEncoder::encode_string(fixture_create_string()));
    keep(DataEncoder::encode_u8(fixture_create_u8()));
    keep(DataEncoder::encode_u16(fixture_create_u16()));
    keep(DataEncoder::encode_u32(fixture_create_u32()));
    keep(DataEncoder::encode_u64(fixture_create_u64()));
    keep(DataEncoder::encode_u256(fixture_create_u256()));
    keep(DataEncoder::encode_b256(fixture_create_b256()));
    keep(DataEncoder::encode_bool(fixture_create_bool()));
    keep(DataEncoder::encode_address(fixture_create_address()));
    keep(DataEncoder::encode_contract_id(fixture_create_contract_id()));
    keep(DataEncoder::encode_identity(fixture_create_identity()));
    keep(DataEncoder::dynamic_u8_array(fixture_create_vec_u8(1)));
    keep(DataEncoder::dynamic_u16_array(fixture_create_vec_u16(1)));
    keep(DataEncoder::dynamic_u32_array(fixture_create_vec_u32(1)));
    keep(DataEncoder::dynamic_u64_array(fixture_create_vec_u64(1)));
    keep(DataEncoder::dynamic_u256_array(fixture_create_vec_u256(1)));
    keep(DataEncoder::dynamic_b256_array(fixture_create_vec_b256(1)));

    // Call 2
    keep(DataEncoder::encode_string(fixture_create_string()));
    keep(DataEncoder::encode_u8(fixture_create_u8()));
    keep(DataEncoder::encode_u16(fixture_create_u16()));
    keep(DataEncoder::encode_u32(fixture_create_u32()));
    keep(DataEncoder::encode_u64(fixture_create_u64()));
    keep(DataEncoder::encode_u256(fixture_create_u256()));
    keep(DataEncoder::encode_b256(fixture_create_b256()));
    keep(DataEncoder::encode_bool(fixture_create_bool()));
    keep(DataEncoder::encode_address(fixture_create_address()));
    keep(DataEncoder::encode_contract_id(fixture_create_contract_id()));
    keep(DataEncoder::encode_identity(fixture_create_identity()));
    keep(DataEncoder::dynamic_u8_array(fixture_create_vec_u8(1)));
    keep(DataEncoder::dynamic_u16_array(fixture_create_vec_u16(1)));
    keep(DataEncoder::dynamic_u32_array(fixture_create_vec_u32(1)));
    keep(DataEncoder::dynamic_u64_array(fixture_create_vec_u64(1)));
    keep(DataEncoder::dynamic_u256_array(fixture_create_vec_u256(1)));
    keep(DataEncoder::dynamic_b256_array(fixture_create_vec_b256(1)));
}
