library;

use std::string::String;

/// Contact Information to report bugs to.
pub struct SecurityInformation {
    /// Name of the project.
    pub name: String,
    /// Website URL of the project.
    pub project_url: Option<String>,
    /// List of contact information to contact developers of the project.
    /// Should be in the format <contact_type>:<contact_information>.
    /// You should include contact types that will not change over time.
    pub contact_information: Vec<String>,
    /// Text describing the project's security policy, or a link to it.
    /// This should describe what kind of bounties your project offers and the terms under which you offer them.
    pub policy: String,
    /// A list of preferred languages (ISO 639-1).
    pub preferred_languages: Option<Vec<String>>,
    /// A PGP public key block (or similar) or a link to one.
    pub encryption: Option<String>,
    /// A URL to the project's source code.
    pub source_code: Option<String>,
    /// The release identifier of this build, ideally corresponding to a tag on git that can be rebuilt to reproduce the same binary.
    /// 3rd party build verification tools will use this tag to identify a matching github release.
    pub source_release: Option<String>,
    /// The revision identifier of this build, usually a git sha that can be rebuilt to reproduce the same binary.
    /// 3rd party build verification tools will use this tag to identify a matching github release.
    pub source_revision: Option<String>,
    /// A list of people or entities that audited this smart contract, or links to pages where audit reports are hosted.
    /// Note that this field is self-reported by the author of the program and might not be accurate.
    pub auditors: Option<Vec<String>>,
    /// Text containing acknowledgments to security researchers who have previously found vulnerabilities in the project, or a link to it.
    pub acknowledgments: Option<String>,
    /// Text containing any additional information you want to provide, or a link to it.
    pub additional_information: Option<String>,
}

abi SRC11 {
    /// Returns security, contact, and audit information about the contract.
    /// White hat hackers may use this information to report bugs to the project.
    ///
    /// # Returns
    ///
    /// * [SecurityInformation] - Security information about the contract.
    #[storage(read)]
    fn security_information() -> SecurityInformation;
}
