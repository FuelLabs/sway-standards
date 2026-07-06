library;

use benchmarking::*;
use src16::*;
use std::string::*;


#[inline(never)]
pub fn fixture_create_src16_domain() -> SRC16Domain {
    SRC16Domain::new(
        Some(String::from_ascii_str("SampleDomain")),
        Some(String::from_ascii_str("1")),
        Some(0),
        Some(ContractId::zero()),
        None,
    )
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
