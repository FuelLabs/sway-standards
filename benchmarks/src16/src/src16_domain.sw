library;

use benchmarking::*;
use src16::*;
use std::string::*;

use ::common::fixture_create_buffer;

#[inline(never)]
pub fn fixture_create_src16_domain() -> SRC16Domain {
    SRC16Domain::new(
        String::from_ascii_str("SampleDomain"),
        String::from_ascii_str("1"),
        0,
        ContractId::zero(),
    )
}

#[test]
fn baseline__src16_domain__abi_encode() {
    let _ = fixture_create_src16_domain();
    let _ = fixture_create_buffer();
    keep_ref_type(); // encoded
}

#[test]
fn bench__src16_domain__abi_encode() {
    let domain = fixture_create_src16_domain();
    let buffer = fixture_create_buffer();

    let encoded = domain.abi_encode(buffer);
    keep(encoded);
}

#[test]
fn baseline__src16_domain__domain_hash() {
    let _ = fixture_create_src16_domain();
    keep_ref_type(); // hash
}

#[test]
fn bench__src16_domain__domain_hash() {
    let domain = fixture_create_src16_domain();

    let hash = domain.domain_hash();
    keep(hash);
}
