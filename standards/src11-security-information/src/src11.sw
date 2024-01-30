library;

use std::string::String;

/// Contact Information to report bugs to.
pub struct SecurityInformation {
    /// Name of the project.
    name: String,
    /// Website URL of the project.
    project_url: Option<String>,
    /// List of contact information to contact developers of the project.
    /// Should be in the format <contact_type>:<contact_information>.
    /// You should include contact types that will not change over time.
    contact_information: Vec<String>,
    /// Either a link or a text document describing the project's security policy.
    /// This should describe what kind of bounties your project offers and the terms under which you offer them.
    policy: String,
    /// A list of preferred languages (ISO 639-1).
    preferred_languages: Option<Vec<String>>,
    /// A PGP public key block (or similar) or a link to one.
    encryption: Option<String>,
    /// A URL to the project's source code.
    source_code: Option<String>,
    /// The release identifier of this build, ideally corresponding to a tag on git that can be rebuilt to reproduce the same binary.
    /// 3rd party build verification tools will use this tag to identify a matching github releases.
    source_release: Option<String>,
    /// The revision identifier of this build, usually a git sha that can be rebuilt to reproduce the same binary.
    /// 3rd party build verification tools will use this tag to identify a matching github releases.
    source_revision: Option<String>,
    /// A list of people or entities that audited this smart contract, or links to pages where audit reports are hosted.
    /// Note that this field is self-reported by the author of the program and might not be accurate.
    auditors: Option<Vec<String>>,
    /// Either a link or a text document containing acknowledgements to security researchers who have previously found vulnerabilities in the project.
    acknowledgements: Option<String>,
    /// Link or text containing any additional information you want to provide.
    additional_information: Option<String>,
}

abi SRC11 {
    /// Returns security, contact, and audit information about the contract.
    /// White hat hackers can use this information to report bugs to the project.
    ///
    /// # Returns
    ///
    /// * [SecurityInformation] - Security information about the contract.
    #[storage(read)]
    fn security_information() -> SecurityInformation;
}
