contract;

use standards::src11::{SecurityInformation, SRC11};

use std::{string::String, vec::Vec,};

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
