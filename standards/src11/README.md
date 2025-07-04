# SRC-11: Security Information

The following standard allows for contract creators to make communication information readily available to everyone, with the primary purpose of allowing white hat hackers to coordinate a bug-fix or securing of funds.

## Motivation

White hat hackers may find bugs or exploits in contracts that they want to report to the project for safeguarding of funds. It is not immediately obvious from a `ContractId`, who the right person to contact is. This standard aims to make the process of bug reporting as smooth as possible.

## Prior Art

The [`security.txt`](https://github.com/neodyme-labs/solana-security-txt) library for Solana has explored this idea. This standard takes inspiration from the library, with some changes.

## Specification

### Security Information Type

The following describes the `SecurityInformation` type.

- The struct MAY contain `None` for `Option<T>` type fields, if they are deemed unnecessary.
- The struct MUST NOT contain empty `String` or `Vec` fields.
- The struct MAY contain a URL or the information directly for the following fields: `project_url`, `policy`, `encryption`, `source_code`, `auditors`, `acknowledgments`, `additional_information`.
- The struct MUST contain the information directly for the following fields: `name`, `contact_information`, `preferred_languages`, `source_release`, and `source_revision`.
- The struct MUST contain at least one item in the `preferred_languages` field's `Vec`, if it is not `None`. Furthermore, the string should only contain the [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes) language code and nothing else.
- The struct MUST contain at least one item in the `contact_information` field's `Vec`. Furthermore, the string should follow the following format `<contact_type>:<contact_information>`. Where `contact_type` describes the method of contact (e.g. `email` or `discord`) and `contact_information` describes the information needed to contact (e.g. `example@example.com` or `@EXAMPLE`).

#### `name: String`

The name of the project that the contract is associated with.

#### `project_url: Option<String>`

The website URL of the project that the contract is associated with.

#### `contact_information: Vec<String>`

A list of contact information to contact developers of the project. Should be in the format `<contact_type>:<contact_information>`. You should include contact types that will not change over time.

#### `policy: String`

Text describing the project's security policy, or a link to it. This should describe what kind of bounties your project offers and the terms under which you offer them.

#### `preferred_languages: Option<Vec<String>>`

A list of preferred languages [ISO 639-1](https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes).
If the field is not `None`, it MUST contain at least one item.

#### `encryption: Option<String>`

A PGP public key block (or similar) or a link to one.

#### `source_code: Option<String>`

A URL to the project's source code.

#### `source_release: Option<String>`

The release identifier of this build, ideally corresponding to a tag on git that can be rebuilt to reproduce the same binary. 3rd party build verification tools will use this tag to identify a matching GitHub release.

#### `source_revision: Option<String>`

The revision identifier of this build, usually a git commit hash that can be rebuilt to reproduce the same binary. 3rd party build verification tools will use this tag to identify a matching GitHub release.

#### `auditors: Option<Vec<String>>`

A list of people or entities that audited this smart contract, or links to pages where audit reports are hosted. Note that this field is self-reported by the author of the program and might not be accurate.

#### `acknowledgments: Option<String>`

Text containing acknowledgments to security researchers who have previously found vulnerabilities in the project, or a link to it.

#### `additional_information: Option<String>`

Text containing any additional information you want to provide, or a link to it.

### Required Functions

The following function MUST be implemented to follow the SRC-11 standard.

#### `fn security_information() -> SecurityInformation;`

This function takes no input parameters and returns a struct containing contact information for the project owners, information regarding the bug bounty program, other information related to security, and any other information that the developers find relevant.

- This function MUST return accurate and up to date information.
- This function's return values MUST follow the specification for the `SecurityInformation` type.
- This function MUST NOT revert under any circumstances.

## Rationale

The return structure discussed covers most information that may want to be conveyed regarding the security of the contract, with an additional field to convey any additional information. This should allow easy communication between the project owners and any white hat hackers if necessary.

## Backwards Compatibility

This standard does not face any issues with backward compatibility.

## Security Considerations

The information is entirely self reported and as such might not be accurate. Accuracy of information cannot be enforced and as such, anyone using this information should be aware of that.

## Example ABI

```sway
abi SRC11 {
    #[storage(read)]
    fn security_information() -> SecurityInformation;
}
```

## Example Implementation

### Hard coded information

A basic implementation of the security information standard demonstrating how to hardcode information to be returned.

```sway
contract;

use src11::{SecurityInformation, SRC11};

use std::{string::String, vec::Vec};

/// The name of the project
const NAME: str[7] = __to_str_array("Example");
/// The URL of the project
const PROJECT_URL: str[19] = __to_str_array("https://example.com");
/// The contact information of the project
const CONTACT1: str[25] = __to_str_array("email:example@example.com");
const CONTACT2: str[41] = __to_str_array("link:https://example.com/security_contact");
const CONTACT3: str[20] = __to_str_array("discord:example#1234");
/// The security policy of the project
const POLICY: str[35] = __to_str_array("https://example.com/security_policy");
/// The preferred languages of the project
const PREFERRED_LANGUAGES1: str[2] = __to_str_array("en");
const PREFERRED_LANGUAGES2: str[2] = __to_str_array("ja");
const PREFERRED_LANGUAGES3: str[2] = __to_str_array("zh");
const PREFERRED_LANGUAGES4: str[2] = __to_str_array("hi");
/// The encryption key of the project
const ENCRYPTION: str[751] = __to_str_array(
    "-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: Alice's OpenPGP certificate
Comment: https://www.ietf.org/id/draft-bre-openpgp-samples-01.html

mDMEXEcE6RYJKwYBBAHaRw8BAQdArjWwk3FAqyiFbFBKT4TzXcVBqPTB3gmzlC/U
b7O1u120JkFsaWNlIExvdmVsYWNlIDxhbGljZUBvcGVucGdwLmV4YW1wbGU+iJAE
ExYIADgCGwMFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQTrhbtfozp14V6UTmPy
MVUMT0fjjgUCXaWfOgAKCRDyMVUMT0fjjukrAPoDnHBSogOmsHOsd9qGsiZpgRnO
dypvbm+QtXZqth9rvwD9HcDC0tC+PHAsO7OTh1S1TC9RiJsvawAfCPaQZoed8gK4
OARcRwTpEgorBgEEAZdVAQUBAQdAQv8GIa2rSTzgqbXCpDDYMiKRVitCsy203x3s
E9+eviIDAQgHiHgEGBYIACAWIQTrhbtfozp14V6UTmPyMVUMT0fjjgUCXEcE6QIb
DAAKCRDyMVUMT0fjjlnQAQDFHUs6TIcxrNTtEZFjUFm1M0PJ1Dng/cDW4xN80fsn
0QEA22Kr7VkCjeAEC08VSTeV+QFsmz55/lntWkwYWhmvOgE=
=iIGO
-----END PGP PUBLIC KEY BLOCK-----",
);
/// The URL of the project's source code
const SOURCE_CODE: str[31] = __to_str_array("https://github.com/example/test");
/// The release identifier of this build
const SOURCE_RELEASE: str[6] = __to_str_array("v1.0.0");
/// The revision identifier of this build
const SOURCE_REVISION: str[12] = __to_str_array("a1b2c3d4e5f6");
/// The URL of the project's auditors
const AUDITORS: str[28] = __to_str_array("https://example.com/auditors");
/// The URL of the project's acknowledgements
const ACKNOWLEDGEMENTS: str[36] = __to_str_array("https://example.com/acknowledgements");
/// The URL of the project's additional information
const ADDITIONAL_INFORMATION: str[42] = __to_str_array("https://example.com/additional_information");

impl SRC11 for Contract {
    #[storage(read)]
    fn security_information() -> SecurityInformation {
        let mut contact_information = Vec::new();
        contact_information.push(String::from_ascii_str(from_str_array(CONTACT1)));
        contact_information.push(String::from_ascii_str(from_str_array(CONTACT2)));
        contact_information.push(String::from_ascii_str(from_str_array(CONTACT3)));

        let mut preferred_languages = Vec::new();
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES1))); // English
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES2))); // Japanese
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES3))); // Chinese
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES4))); // Hindi
        let mut auditors = Vec::new();
        auditors.push(String::from_ascii_str(from_str_array(AUDITORS)));

        SecurityInformation {
            name: String::from_ascii_str(from_str_array(NAME)),
            project_url: Some(String::from_ascii_str(from_str_array(PROJECT_URL))),
            contact_information: contact_information,
            policy: String::from_ascii_str(from_str_array(POLICY)),
            preferred_languages: Some(preferred_languages),
            encryption: Some(String::from_ascii_str(from_str_array(ENCRYPTION))),
            source_code: Some(String::from_ascii_str(from_str_array(SOURCE_CODE))),
            source_release: Some(String::from_ascii_str(from_str_array(SOURCE_RELEASE))),
            source_revision: Some(String::from_ascii_str(from_str_array(SOURCE_REVISION))),
            auditors: Some(auditors),
            acknowledgments: Some(String::from_ascii_str(from_str_array(ACKNOWLEDGEMENTS))),
            additional_information: Some(String::from_ascii_str(from_str_array(ADDITIONAL_INFORMATION))),
        }
    }
}
```

### Variable information

A basic implementation of the security information standard demonstrating how to return variable information that can be edited to keep it up to date. In this example only the contact_information field is variable, but the same method can be applied to any field which you wish to update.

```sway
contract;

use src11::{SecurityInformation, SRC11};

use std::{storage::{storage_string::*, storage_vec::*}, string::String, vec::Vec};

/// The name of the project
const NAME: str[7] = __to_str_array("Example");
/// The URL of the project
const PROJECT_URL: str[19] = __to_str_array("https://example.com");
/// The security policy of the project
const POLICY: str[35] = __to_str_array("https://example.com/security_policy");
/// The preferred languages of the project
const PREFERRED_LANGUAGES1: str[2] = __to_str_array("en");
const PREFERRED_LANGUAGES2: str[2] = __to_str_array("ja");
const PREFERRED_LANGUAGES3: str[2] = __to_str_array("zh");
const PREFERRED_LANGUAGES4: str[2] = __to_str_array("hi");
/// The encryption key of the project
const ENCRYPTION: str[751] = __to_str_array(
    "-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: Alice's OpenPGP certificate
Comment: https://www.ietf.org/id/draft-bre-openpgp-samples-01.html

mDMEXEcE6RYJKwYBBAHaRw8BAQdArjWwk3FAqyiFbFBKT4TzXcVBqPTB3gmzlC/U
b7O1u120JkFsaWNlIExvdmVsYWNlIDxhbGljZUBvcGVucGdwLmV4YW1wbGU+iJAE
ExYIADgCGwMFCwkIBwIGFQoJCAsCBBYCAwECHgECF4AWIQTrhbtfozp14V6UTmPy
MVUMT0fjjgUCXaWfOgAKCRDyMVUMT0fjjukrAPoDnHBSogOmsHOsd9qGsiZpgRnO
dypvbm+QtXZqth9rvwD9HcDC0tC+PHAsO7OTh1S1TC9RiJsvawAfCPaQZoed8gK4
OARcRwTpEgorBgEEAZdVAQUBAQdAQv8GIa2rSTzgqbXCpDDYMiKRVitCsy203x3s
E9+eviIDAQgHiHgEGBYIACAWIQTrhbtfozp14V6UTmPyMVUMT0fjjgUCXEcE6QIb
DAAKCRDyMVUMT0fjjlnQAQDFHUs6TIcxrNTtEZFjUFm1M0PJ1Dng/cDW4xN80fsn
0QEA22Kr7VkCjeAEC08VSTeV+QFsmz55/lntWkwYWhmvOgE=
=iIGO
-----END PGP PUBLIC KEY BLOCK-----",
);
/// The URL of the project's source code
const SOURCE_CODE: str[31] = __to_str_array("https://github.com/example/test");
/// The release identifier of this build
const SOURCE_RELEASE: str[6] = __to_str_array("v1.0.0");
/// The revision identifier of this build
const SOURCE_REVISION: str[12] = __to_str_array("a1b2c3d4e5f6");
/// The URL of the project's auditors
const AUDITORS: str[28] = __to_str_array("https://example.com/auditors");
/// The URL of the project's acknowledgements
const ACKNOWLEDGEMENTS: str[36] = __to_str_array("https://example.com/acknowledgements");
/// The URL of the project's additional information
const ADDITIONAL_INFORMATION: str[42] = __to_str_array("https://example.com/additional_information");

storage {
    /// The contact information for the security contact.
    contact_information: StorageVec<StorageString> = StorageVec {},
}

abi StorageInformation {
    #[storage(read, write)]
    fn store_contact_information(input: String);
}

impl StorageInformation for Contract {
    #[storage(read, write)]
    fn store_contact_information(input: String) {
        storage.contact_information.push(StorageString {});
        let storage_string = storage.contact_information.get(storage.contact_information.len() - 1).unwrap();
        storage_string.write_slice(input);
    }
}

#[storage(read)]
fn get_contact_information() -> Vec<String> {
    let mut contact_information = Vec::new();

    let mut i = 0;
    while i < storage.contact_information.len() {
        let storage_string = storage.contact_information.get(i).unwrap();
        contact_information.push(storage_string.read_slice().unwrap());
        i += 1;
    }

    contact_information
}

impl SRC11 for Contract {
    #[storage(read)]
    fn security_information() -> SecurityInformation {
        let mut preferred_languages = Vec::new();
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES1))); // English
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES2))); // Japanese
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES3))); // Chinese
        preferred_languages.push(String::from_ascii_str(from_str_array(PREFERRED_LANGUAGES4))); // Hindi
        let mut auditors = Vec::new();
        auditors.push(String::from_ascii_str(from_str_array(AUDITORS)));

        SecurityInformation {
            name: String::from_ascii_str(from_str_array(NAME)),
            project_url: Some(String::from_ascii_str(from_str_array(PROJECT_URL))),
            // Use stored variable contact information instead of hardcoded contact information.
            contact_information: get_contact_information(),
            policy: String::from_ascii_str(from_str_array(POLICY)),
            preferred_languages: Some(preferred_languages),
            encryption: Some(String::from_ascii_str(from_str_array(ENCRYPTION))),
            source_code: Some(String::from_ascii_str(from_str_array(SOURCE_CODE))),
            source_release: Some(String::from_ascii_str(from_str_array(SOURCE_RELEASE))),
            source_revision: Some(String::from_ascii_str(from_str_array(SOURCE_REVISION))),
            auditors: Some(auditors),
            acknowledgments: Some(String::from_ascii_str(from_str_array(ACKNOWLEDGEMENTS))),
            additional_information: Some(String::from_ascii_str(from_str_array(ADDITIONAL_INFORMATION))),
        }
    }
}
```
