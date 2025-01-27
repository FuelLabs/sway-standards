contract;

use standards::src16::{
    DataEncoder,
    DomainHash,
    SRC16,
    SRC16Base,
    SRC16Domain,
    SRC16Encode,
    SRC16Payload,
    TypedDataHash,
};
use std::{bytes::Bytes, contract_id::*, hash::*, string::String};

configurable {
    /// The name of the signing domain.
    DOMAIN: str[8] = __to_str_array("MyDomain"),
    /// The current major version for the signing domain.
    VERSION: str[1] = __to_str_array("1"),
    /// The active chain ID where the signing is intended to be used. Cast to u256 in domain_hash
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

impl TypedDataHash for Mail {
    fn type_hash() -> b256 {
        MAIL_TYPE_HASH
    }

    fn struct_hash(self) -> b256 {
        let mut encoded = Bytes::new();
        // Add the Mail type hash.
        encoded.append(MAIL_TYPE_HASH.to_be_bytes());
        // Use the DataEncoder to encode each field for known types
        encoded.append(DataEncoder::encode_address(self.from).to_be_bytes());
        encoded.append(DataEncoder::encode_address(self.to).to_be_bytes());
        encoded.append(DataEncoder::encode_string(self.contents).to_be_bytes());

        keccak256(encoded)
    }
}

/// Implement the encode function for Mail using SRC16Payload
///
/// # Additional Information
///
/// 1. Get the encodeData hash of the Mail typed data using
///    <Mail>..struct_hash();
/// 2. Obtain the payload to by populating the SRC16Payload struct
///    with the domain separator and data_hash from the previous step.
/// 3. Obtain the final_hash [Some(b256)] or None using the function
///    SRC16Payload::encode_hash()
///
impl SRC16Encode<Mail> for Mail {
    fn encode(s: Mail) -> b256 {
        // encodeData hash
        let data_hash = s.struct_hash();
        // setup payload
        let payload = SRC16Payload {
            domain: _get_domain_separator(),
            data_hash: data_hash,
        };

        // Get the final encoded hash
        match payload.encode_hash() {
            Some(hash) => hash,
            None => revert(0),
        }
    }
}

impl SRC16Base for Contract {
    fn domain_separator_hash() -> b256 {
        _get_domain_separator().domain_hash()
    }

    fn data_type_hash() -> b256 {
        MAIL_TYPE_HASH
    }
}

impl SRC16 for Contract {
    fn domain_separator() -> SRC16Domain {
        _get_domain_separator()
    }
}

abi MailMe {
    fn send_mail_get_hash(from_addr: Address, to_addr: Address, contents: String) -> b256;
}

impl MailMe for Contract {
    /// Sends a some mail and returns its encoded hash
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
        // Create the mail struct from data passed in call
        let some_mail = Mail {
            from: from_addr,
            to: to_addr,
            contents: contents,
        };

        Mail::encode(some_mail)
    }
}

/// A program specific implementation to get the Fuel SRC16Domain
///
/// In a Contract the ContractID can be obtain with ContractId::this()
///
/// In a Predicate or Script it is at the implementors discretion to
/// use the code root if they wish to contrain the validation to a
/// specifc program.
///
fn _get_domain_separator() -> SRC16Domain {
    SRC16Domain::new(
        String::from_ascii_str(from_str_array(DOMAIN)),
        String::from_ascii_str(from_str_array(VERSION)),
        CHAIN_ID,
        ContractId::this(),
    )
}
