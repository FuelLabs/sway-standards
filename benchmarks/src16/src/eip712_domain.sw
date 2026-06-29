library;

use benchmarking::*;
use src16::*;
use std::string::*;

use ::common::fixture_create_buffer;

#[inline(never)]
pub fn fixture_create_eip712_domain() -> EIP712Domain {
    EIP712Domain::new(
        String::from_ascii_str("SampleDomain"),
        String::from_ascii_str("1"),
        0,
        ContractId::zero(),
    )
}

#[inline(never)]
pub fn fixture_create_eip712_domain_args() -> (String, String, u256, ContractId) {
    (
        String::from_ascii_str("SampleDomain"),
        String::from_ascii_str("1"),
        0,
        ContractId::zero(),
    )
}

#[test]
fn baseline__eip712_domain__new() {
    let _ = fixture_create_eip712_domain_args();
    keep_ref_type(); // domain
}

#[test]
fn bench__eip712_domain__new() {
    let (name, version, chain_id, verifying_contract) = fixture_create_eip712_domain_args();

    let domain = EIP712Domain::new(name, version, chain_id, verifying_contract);
    keep(domain);
}

#[test]
fn baseline__eip712_domain__abi_encode() {
    let _ = fixture_create_eip712_domain();
    let _ = fixture_create_buffer();
    keep_ref_type(); // encoded
}

#[test]
fn bench__eip712_domain__abi_encode() {
    let domain = fixture_create_eip712_domain();
    let buffer = fixture_create_buffer();

    let encoded = domain.abi_encode(buffer);
    keep(encoded);
}

#[test]
fn baseline__eip712_domain__domain_hash() {
    let _ = fixture_create_eip712_domain();
    keep_ref_type(); // hash
}

#[test]
fn bench__eip712_domain__domain_hash() {
    let domain = fixture_create_eip712_domain();

    let hash = domain.domain_hash();
    keep(hash);
}
