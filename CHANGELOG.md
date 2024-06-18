# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - yyyy-mm-dd

Description of the upcoming release here.

### Added

- [#107](https://github.com/FuelLabs/sway-standards/pull/107) Adds the `proxy_owner()` function to the SRC-14 standard.
- [#110](https://github.com/FuelLabs/sway-standards/pull/110) Adds the `proxy_target()` function to the SRC-14 standard.
- Something new here 2

### Changed

- Something changed here 1
- Something changed here 2

### Fixed

- [#107](https://github.com/FuelLabs/sway-standards/pull/107) resolves the conflict when SRC-5's `owner()` function is used in both the proxy and target contract in the SRC-14 standard.

#### Breaking

- [#110](https://github.com/FuelLabs/sway-standards/pull/110) Breaks the `SRC14` abi by adding the `proxy_target()` function. This will need to be added to any SRC14 implementation. The new abi is as follows:

```sway
abi SRC14 {
    #[storage(read, write)]
    fn set_proxy_target(new_target: ContractId);
    #[storage(read)]
    fn proxy_target() -> Option<ContractId>;
}
```
