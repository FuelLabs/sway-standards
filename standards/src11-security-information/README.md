<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/src-6-logo-dark-theme.png">
        <img alt="SRC-6 logo" width="400px" src=".docs/src-6-logo-light-theme.png">
    </picture>
</p>

# Abstract

The following standard allows for contract creators to make communication information readily available to everyone, with the primary purpose of allowing white hat hackers to coordinate a bug-fix or securing of funds.

# Motivation

White hat hackers may find bugs or exploits in contracts that they want to report to the project for safeguarding of funds. It is not immediately obvious from a ContractId, who the right person to contact is. This standard aims to make the process of bug reporting as smooth as possible

# Prior Art

The [security.txt](https://github.com/neodyme-labs/solana-security-txt) library for solana has explored this idea. This standard takes inspiration from the library, with some changes.

# Specification

## Required public functions

The following function MUST be implemented to follow the SRC-11 standard.

### `fn security_information() -> SecurityInformation;`

This function takes no input parameters and returns a struct containing contact information for the project owners, information regarding the bug bounty program, other information related to security, and any other information which the developers find relevant.

- This function MUST return accurate and up to date information.
- This function MAY not return the optional parameters.
- This function MUST return atleast one item in the `contact_information` field's `Vec`. Furthurmore, the string should follow the following format `<contact_type>:<contact_information>`.
- This function MUST NOT return any empty strings. Optional parameters must return `None` if it is unnecessary.
- This function MUST return atleast one item in the `preferred_languages`, if it is not `None`. Furthurmore, the string should only contain the `ISO 639-1` language code and nothing else.
- This function MAY return a link or the information directly for the following fields: `project_url`, `policy`, `encryption`, `source_code`, `auditors`, `acknowledgements`, `additional_information`.
- This function MUST return the information directly for the following fields: `name`, `contact_information`, `preferred_languages`, `source_release`, and `source_revision`.


# Rationale

The return structure discussed covers most information that may want to be conveyed regarding the security of the contract, with an additional field to convey any additional information. This should allow easy communication between the project owners and any white hat hackers if necessary.

# Backwards Compatibility

This standard does not face any issues with backward compatibility. 

// Is this section necessary?

# Security Considerations

The information is entirely self reported and as such might not be accurate. Accuracy of information cannot be enforced and as such, anyone using this information should be aware of that.

# Example ABI

```sway
abi SRC11 {
    #[storage(read)]
    fn security_information() -> SecurityInformation;
}
```

# Example Implementation

## [Hard coded information](../../examples/src11-security-information/hardcoded-information/)

A basic implementation of the security information standard demonstrating how to hardcode information to be returned.

## [Variable information](../../examples/src11-security-information/variable-information/)

A basic implementation of the security information standard demonstrating how to return variable information that can be edited to keep it up to date. In this example only the contact_information field is variable, but the same method can be applied to any field which you wish to update.
