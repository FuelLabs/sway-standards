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
{{#include ../examples/src11-security-information/hardcoded-information/src/main.sw}}
```

### Variable information

A basic implementation of the security information standard demonstrating how to return variable information that can be edited to keep it up to date. In this example only the contact_information field is variable, but the same method can be applied to any field which you wish to update.

```sway
{{#include ../examples/src11-security-information/variable-information/src/main.sw}}
```
