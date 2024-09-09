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
    /// The revision identifier of this build, usually a git commit hash that can be rebuilt to reproduce the same binary.
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

impl core::ops::Eq for SecurityInformation {
    fn eq(self, other: Self) -> bool {
        // If both contact info contain data, check each string
        let self_contact_information_len = self.contact_information.len();
        let other_contact_information_len = other.contact_information.len();
        if self_contact_information_len > 0 && other_contact_information_len > 0 {
            // Check each string matches
            let mut iter = 0;
            while iter < self_contact_information_len {
                if self.contact_information.get(iter) != other.contact_information.get(iter)
                {
                    return false;
                }
                iter += 1;
            }
        } else if !(self_contact_information_len == 0 && self_contact_information_len == 0) { // Otherwise both must contain nothing
            return false;
        }

        // If both prefered languages info contain data, check each string
        if self.preferred_languages.is_some() && other.preferred_languages.is_some() {
            let self_preferred_languages = self.preferred_languages.unwrap();
            let other_preferred_languages = self.preferred_languages.unwrap();

            let self_preferred_languages_len = self_preferred_languages.len();
            let other_preferred_languages_len = other_preferred_languages.len();
            // If lengths do not match, we do not need to iterate over the strings
            if self_preferred_languages_len != other_preferred_languages_len
            {
                return false;
            }

            // Check each string matches
            let mut iter = 0;
            while iter < self_preferred_languages_len {
                if self_preferred_languages.get(iter) != other_preferred_languages.get(iter)
                {
                    return false;
                }
                iter += 1;
            }
        } else if !(self.preferred_languages.is_none() && other.preferred_languages.is_none()) { // Otherwise both must be none
            return false;
        }

        // If both auditors info contain data, check each string
        if self.auditors.is_some() && other.auditors.is_some() {
            let self_auditors = self.auditors.unwrap();
            let other_auditors = self.auditors.unwrap();

            let self_auditors_len = self_auditors.len();
            let other_auditors_len = other_auditors.len();
            // If lengths do not match, we do not need to iterate over the strings
            if self_auditors_len != other_auditors_len {
                return false;
            }

            // Check each string matches
            let mut iter = 0;
            while iter < self_auditors_len {
                if self_auditors.get(iter) != other_auditors.get(iter) {
                    return false;
                }
                iter += 1;
            }
        } else if !(self.auditors.is_none() && other.auditors.is_none()) { // Otherwise both must be none
            return false;
        }

        self.name == other.name && self.project_url == other.project_url && self.policy == other.policy && self.encryption == other.encryption && self.source_code == other.source_code && self.source_release == other.source_release && self.source_revision == other.source_revision && self.acknowledgments == other.acknowledgments && self.additional_information == other.additional_information
    }
}

impl SecurityInformation {
    /// Returns a new `SecurityInformation`.
    ///
    /// # Arguments
    ///
    /// * `name`: [String] - Name of the project.
    /// * `project_url`: [Option<String>] - Website URL of the project.
    /// * `contact_information`: [Vec<String>] - List of contact information to contact developers of the project.
    /// * `policy`: [String] - Text describing the project's security policy, or a link to it.
    /// * `preferred_languages`: [Option<Vec<String>>] - A list of preferred languages (ISO 639-1).
    /// * `encryption`: [Option<String>] - A PGP public key block (or similar) or a link to one.
    /// * `source_code`: [Option<String>] - A URL to the project's source code.
    /// * `source_release`: [Option<String>] - The release identifier of this build, ideally corresponding to a tag on git that can be rebuilt to reproduce the same binary.
    /// * `source_revision`: [Option<String>] - The revision identifier of this build, usually a git commit hash that can be rebuilt to reproduce the same binary.
    /// * `auditors`: [Option<Vec<String>>] - A list of people or entities that audited this smart contract, or links to pages where audit reports are hosted.
    /// * `acknowledgments`: [Option<String>] - Text containing acknowledgments to security researchers who have previously found vulnerabilities in the project, or a link to it.
    /// * `additional_information`: [Option<String>] - Text containing any additional information you want to provide, or a link to it.
    ///
    /// # Returns
    ///
    /// * [SecurityInformation] - The newly created `SecurityInformation`.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.name == name);
    ///     assert(security_information.project_url == project_url);
    ///     assert(security_information.contact_information == contact_information);
    ///     assert(security_information.policy == policy);
    ///     assert(security_information.preferred_languages == preferred_languages);
    ///     assert(security_information.encryption == encryption);
    ///     assert(security_information.source_code == source_code);
    ///     assert(security_information.source_release == source_release);
    ///     assert(security_information.source_revision == source_revision);
    ///     assert(security_information.auditors == auditors);
    ///     assert(security_information.acknowledgments == acknowledgments);
    ///     assert(security_information.additional_information == additional_information);
    /// }
    /// ```
    pub fn new(
        name: String,
        project_url: Option<String>,
        contact_information: Vec<String>,
        policy: String,
        preferred_languages: Option<Vec<String>>,
        encryption: Option<String>,
        source_code: Option<String>,
        source_release: Option<String>,
        source_revision: Option<String>,
        auditors: Option<Vec<String>>,
        acknowledgments: Option<String>,
        additional_information: Option<String>,
    ) -> Self {
        Self {
            name,
            project_url,
            contact_information,
            policy,
            preferred_languages,
            encryption,
            source_code,
            source_release,
            source_revision,
            auditors,
            acknowledgments,
            additional_information,
        }
    }

    /// Returns the `name` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `name`: [String] - Name of the project.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.name() == name);
    /// }
    /// ```
    pub fn name(self) -> String {
        self.name
    }

    /// Returns the `project_url` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `project_url`: [Option<String>] - Website URL of the project.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.project_url() == project_url);
    /// }
    /// ```
    pub fn project_url(self) -> Option<String> {
        self.project_url
    }

    /// Returns the `contact_information` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `contact_information`: [Vec<String>] - List of contact information to contact developers of the project.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.contact_information() == contact_information);
    /// }
    /// ```
    pub fn contact_information(self) -> Vec<String> {
        self.contact_information
    }

    /// Returns the `policy` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `policy`: [String] - Text describing the project's security policy, or a link to it.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.policy() == policy);
    /// }
    /// ```
    pub fn policy(self) -> String {
        self.policy
    }

    /// Returns the `preferred_languages` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `preferred_languages`: [Option<Vec<String>>] - A list of preferred languages (ISO 639-1).
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.preferred_languages() == preferred_languages);
    /// }
    /// ```
    pub fn preferred_languages(self) -> Option<Vec<String>> {
        self.preferred_languages
    }

    /// Returns the `encryption` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `encryption`: [Option<String>] - A PGP public key block (or similar) or a link to one.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.encryption() == encryption);
    /// }
    /// ```
    pub fn encryption(self) -> Option<String> {
        self.encryption
    }

    /// Returns the `source_code` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `source_code`: [Option<String>] - A URL to the project's source code.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.source_code() == source_code);
    /// }
    /// ```
    pub fn source_code(self) -> Option<String> {
        self.source_code
    }

    /// Returns the `source_release` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `source_release`: [Option<String>] - The release identifier of this build, ideally corresponding to a tag on git that can be rebuilt to reproduce the same binary.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.source_release() == source_release);
    /// }
    /// ```
    pub fn source_release(self) -> Option<String> {
        self.source_release
    }

    /// Returns the `source_revision` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `source_revision`: [Option<String>] - The revision identifier of this build, usually a git commit hash that can be rebuilt to reproduce the same binary.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.source_revision() == source_revision);
    /// }
    /// ```
    pub fn source_revision(self) -> Option<String> {
        self.source_revision
    }

    /// Returns the `auditors` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `auditors`: [Option<Vec<String>>] - A list of people or entities that audited this smart contract, or links to pages where audit reports are hosted.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.auditors() == auditors);
    /// }
    /// ```
    pub fn auditors(self) -> Option<Vec<String>> {
        self.auditors
    }

    /// Returns the `acknowledgments` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `acknowledgments`: [Option<String>] - Text containing acknowledgments to security researchers who have previously found vulnerabilities in the project, or a link to it.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.acknowledgments() == acknowledgments);
    /// }
    /// ```
    pub fn acknowledgments(self) -> Option<String> {
        self.acknowledgments
    }

    /// Returns the `additional_information` of the `SecurityInformation`.
    ///
    /// # Returns
    ///
    /// * `additional_information`: [Option<String>] - Text containing any additional information you want to provide, or a link to it.
    ///
    /// # Examples
    ///
    /// ```sway
    /// use standards::src11::SecurityInformation;
    ///
    /// fn foo(
    ///     name: String,
    ///     project_url: Option<String>,
    ///     contact_information: Vec<String>,
    ///     policy: String,
    ///     preferred_languages: Option<Vec<String>>,
    ///     encryption: Option<String>,
    ///     source_code: Option<String>,
    ///     source_release: Option<String>,
    ///     source_revision: Option<String>,
    ///     auditors: Option<Vec<String>>,
    ///     acknowledgments: Option<String>,
    ///     additional_information: Option<String>,
    /// ) {
    ///     let security_information = SecurityInformation::new(
    ///         name,
    ///         project_url,
    ///         contact_information,
    ///         policy,
    ///         preferred_languages,
    ///         encryption,
    ///         source_code,
    ///         source_release,
    ///         source_revision,
    ///         auditors,
    ///         acknowledgments,
    ///         additional_information,
    ///     );
    ///     assert(security_information.additional_information() == additional_information);
    /// }
    /// ```
    pub fn additional_information(self) -> Option<String> {
        self.additional_information
    }
}
