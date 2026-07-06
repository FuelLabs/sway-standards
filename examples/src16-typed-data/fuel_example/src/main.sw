contract;

use src16::{DataEncoder, Domain, Encoding, SRC16Base, SRC16Domain, SRC16Encode};
use std::{bytes::Bytes, contract_id::*, hash::*, string::String};

configurable {
    /// The name of the signing domain.
    DOMAIN: str[8] = __to_str_array("MyDomain"),
    /// The current major version for the signing domain.
    VERSION: str[1] = __to_str_array("1"),
    /// The active chain ID where the signing is intended to be used.
    CHAIN_ID: u64 = 9889u64,
}

/// A demo struct representing a mail message
pub struct Mail {
    /// The sender's address
    pub from: Address,
    /// The recipient's address
    pub to: Address,
    /// The message contents
    pub contents: String,
}

/// The Keccak256 hash of the type Mail as UTF8 encoded bytes.
///
/// "Mail(address from,address to,string contents)"
///
/// 536e54c54e6699204b424f41f6dea846ee38ac369afec3e7c141d2c92c65e67f
///
const MAIL_TYPE_HASH: b256 = 0x536e54c54e6699204b424f41f6dea846ee38ac369afec3e7c141d2c92c65e67f;

impl SRC16Encode for Mail {
    fn type_hash(encoding: Encoding) -> b256 {
        MAIL_TYPE_HASH
    }

    fn struct_hash(self, encoding: Encoding) -> b256 {
        let mut encoded = Bytes::new();
        encoded.append(MAIL_TYPE_HASH.to_be_bytes());
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

impl SRC16Base for Contract {
    fn domain_separator_hash(encoding: Encoding) -> b256 {
        _get_domain_separator().domain_hash()
    }

    fn data_type_hash(encoding: Encoding) -> b256 {
        Mail::type_hash(encoding)
    }

    fn domain_separator(encoding: Encoding) -> Domain {
        Domain::SRC16Domain(_get_domain_separator())
    }
}

abi MailMe {
    fn send_mail_get_hash(from_addr: Address, to_addr: Address, contents: String) -> b256;
}

impl MailMe for Contract {
    /// Sends some mail and returns its encoded hash
    ///
    /// # Arguments
    ///
    /// * `from_addr`: [Address] - The sender's address
    /// * `to_addr`: [Address] - The recipient's address
    /// * `contents`: [String] - The message contents
    ///
    /// # Returns
    ///
    /// * [b256] - The encoded hash of the mail data
    ///
    fn send_mail_get_hash(from_addr: Address, to_addr: Address, contents: String) -> b256 {
        let some_mail = Mail {
            from: from_addr,
            to: to_addr,
            contents: contents,
        };
        let domain = Domain::SRC16Domain(_get_domain_separator());
        some_mail.encode(domain)
    }
}

/// Returns the Fuel SRC16Domain for this contract.
///
/// In a Contract the ContractId can be obtained with ContractId::this()
///
/// In a Predicate or Script it is at the implementor's discretion to
/// use the code root if they wish to constrain the validation to a
/// specific program.
///
fn _get_domain_separator() -> SRC16Domain {
    SRC16Domain::new(
        Some(String::from_ascii_str(from_str_array(DOMAIN))),
        Some(String::from_ascii_str(from_str_array(VERSION))),
        Some((asm(r1: (0, 0, 0, CHAIN_ID)) { r1: u256 })),
        Some(ContractId::this()),
        None,
    )
}
