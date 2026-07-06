library;

use benchmarking::*;
use src16::*;
use std::string::*;

#[inline(never)]
pub fn fixture_create_eip712_domain() -> EIP712Domain {
    EIP712Domain::new(
        Some(String::from_ascii_str("SampleDomain")),
        Some(String::from_ascii_str("1")),
        Some(0),
        Some(ContractId::zero()),
        None,
    )
}

#[inline(never)]
pub fn fixture_create_eip712_domain_args() -> (Option<String>, Option<String>, Option<u256>, Option<ContractId>, Option<b256>) {
    (
        Some(String::from_ascii_str("SampleDomain")),
        Some(String::from_ascii_str("1")),
        Some(0),
        Some(ContractId::zero()),
        None,
    )
}

#[test]
fn baseline__eip712_domain__new() {
    let _ = fixture_create_eip712_domain_args();
    keep_ref_type(); // domain
}

#[test]
fn bench__eip712_domain__new() {
    let (name, version, chain_id, verifying_contract, salt) = fixture_create_eip712_domain_args();

    let domain = EIP712Domain::new(name, version, chain_id, verifying_contract, salt);
    keep(domain);
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
