library;

use benchmarking::*;
use src16::*;
use std::{bytes::Bytes, hash::*, string::String};

use ::src16_domain::fixture_create_src16_domain;
use ::eip712_domain::fixture_create_eip712_domain;

pub struct Mail {
    from: Address,
    to: Address,
    contents: String,
}

/// "Mail(address from,address to,string contents)"
const MAIL_SRC16_TYPE_HASH: b256 = 0x536e54c54e6699204b424f41f6dea846ee38ac369afec3e7c141d2c92c65e67f;

/// "Mail(bytes32 from,bytes32 to,string contents)"
const MAIL_EIP712_TYPE_HASH: b256 = 0xcfc972d321844e0304c5a752957425d5df13c3b09c563624a806b517155d7056;

impl SRC16Encode for Mail {
    fn type_hash(encoding: Encoding) -> b256 {
        match encoding {
            Encoding::SRC16 => MAIL_SRC16_TYPE_HASH,
            Encoding::EIP712 => MAIL_EIP712_TYPE_HASH,
        }
    }

    fn struct_hash(self, encoding: Encoding) -> b256 {
        let type_hash = Self::type_hash(encoding);
        let mut encoded = Bytes::new();
        encoded.append(type_hash.to_be_bytes());
        encoded.append(DataEncoder::encode_address(self.from).to_be_bytes());
        encoded.append(DataEncoder::encode_address(self.to).to_be_bytes());
        encoded.append(DataEncoder::encode_string(self.contents).to_be_bytes());
        let result_buffer: b256 = 0x0000000000000000000000000000000000000000000000000000000000000000;
        asm(hash: result_buffer, ptr: encoded.ptr(), len: encoded.len()) {
            k256 hash ptr len;
            hash: b256
        }
    }
}

#[inline(never)]
fn fixture_create_mail() -> Mail {
    Mail {
        from: Address::zero(),
        to: Address::zero(),
        contents: String::from_ascii_str("Hello, Fuel!"),
    }
}

#[test]
fn baseline__src16_encode__encode__src16_domain() {
    let _ = fixture_create_mail();
    let _ = fixture_create_src16_domain();
    keep_ref_type(); // hash
}

#[test]
fn bench__src16_encode__encode__src16_domain() {
    let mail = fixture_create_mail();
    let domain = Domain::SRC16Domain(fixture_create_src16_domain());
    let hash = mail.encode(domain);
    keep(hash);
}

#[test]
fn baseline__src16_encode__encode__eip712_domain() {
    let _ = fixture_create_mail();
    let _ = fixture_create_eip712_domain();
    keep_ref_type(); // hash
}

#[test]
fn bench__src16_encode__encode__eip712_domain() {
    let mail = fixture_create_mail();
    let domain = Domain::EIP712Domain(fixture_create_eip712_domain());
    let hash = mail.encode(domain);
    keep(hash);
}
