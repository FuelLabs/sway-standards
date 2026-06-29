library;

use benchmarking::*;
use src16::*;

use ::src16_domain::fixture_create_src16_domain;
use ::eip712_domain::fixture_create_eip712_domain;

#[inline(never)]
fn fixture_create_src16_payload_with_src16_domain() -> SRC16Payload<SRC16Domain> {
    SRC16Payload {
        domain: fixture_create_src16_domain(),
        data_hash: 0x1616161616161616161616161616161616161616161616161616161616161616,
    }
}

#[inline(never)]
fn fixture_create_src16_payload_with_eip712_domain() -> SRC16Payload<EIP712Domain> {
    SRC16Payload {
        domain: fixture_create_eip712_domain(),
        data_hash: 0x1616161616161616161616161616161616161616161616161616161616161616,
    }
}

#[test]
fn baseline__src16_payload__encode_hash__src16_domain() {
    let _ = fixture_create_src16_payload_with_src16_domain();
    keep_ref_type(); // hash
}

#[test]
fn bench__src16_payload__encode_hash__src16_domain() {
    let payload = fixture_create_src16_payload_with_src16_domain();

    let hash = payload.encode_hash();
    keep(hash);
}

#[test]
fn baseline__src16_payload__encode_hash__eip712_domain() {
    let _ = fixture_create_src16_payload_with_eip712_domain();
    keep_ref_type(); // hash
}

#[test]
fn bench__src16_payload__encode_hash__eip712_domain() {
    let payload = fixture_create_src16_payload_with_eip712_domain();

    let hash = payload.encode_hash();
    keep(hash);
}
