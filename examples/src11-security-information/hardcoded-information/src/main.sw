contract;

use src11::{SecurityInformation, SRC11};

use std::{string::String, vec::Vec,};

impl SRC11 for Contract {
    #[storage(read)]
    fn security_information() -> SecurityInformation {
        let mut contact_information = Vec::new();
        contact_information.push(String::from_ascii_str("email:example@example.com"));
        contact_information.push(String::from_ascii_str("link:https://example.com/security_contact"));
        contact_information.push(String::from_ascii_str("discord:example#1234"));

        let mut preferred_languages = Vec::new();
        preferred_languages.push(String::from_ascii_str("en")); // English
        preferred_languages.push(String::from_ascii_str("ja")); // Japanese
        preferred_languages.push(String::from_ascii_str("zh")); // Chinese
        preferred_languages.push(String::from_ascii_str("hi")); // Hindi
        let mut auditors = Vec::new();
        auditors.push(String::from_ascii_str("https://example.com/auditors"));

        SecurityInformation {
            name: String::from_ascii_str("Example"),
            project_url: Some(String::from_ascii_str("https://example.com")),
            contact_information: contact_information,
            policy: String::from_ascii_str("https://example.com/security_policy"),
            preferred_languages: Some(preferred_languages),
            encryption: Some(String::from_ascii_str(
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
            )),
            source_code: Some(String::from_ascii_str("https://github.com/example/test")),
            source_release: Some(String::from_ascii_str("v1.0.0")),
            source_revision: Some(String::from_ascii_str("a1b2c3d4e5f6")),
            auditors: Some(auditors),
            acknowledgements: Some(String::from_ascii_str("https://example.com/acknowledgements")),
            additional_information: Some(String::from_ascii_str("https://example.com/additional_information")),
        }
    }
}
