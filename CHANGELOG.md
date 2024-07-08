# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased] - yyyy-mm-dd

Description of the upcoming release here.

### Added Unreleased

- Something new here 1
- Something new here 2

### Changed Unreleased

- Something changed here 1
- Something changed here 2

### Fixed Unreleased

- [#121](https://github.com/FuelLabs/sway-standards/pull/121) Fixes the `deposit` function in the SRC-6 standard, uses try_read instead of read in order to allow first time deposits to a vault.

#### Breaking Unreleased

- Some breaking change here 1
- Some breaking change here 2

## [Version 0.5.1]

Description of the upcoming release here.

### Added

- [#107](https://github.com/FuelLabs/sway-standards/pull/107): Adds the `proxy_owner()` function to the SRC-14 standard.
- [#104](https://github.com/FuelLabs/sway-standards/pull/104): Adds the CHANGELOG.md file to Sway-Standards.
- [#110](https://github.com/FuelLabs/sway-standards/pull/110) Adds the `proxy_target()` function to the SRC-14 standard.
- [#103](https://github.com/FuelLabs/sway-standards/pull/103): Adds Sway-Standards to the [docs hub](https://docs.fuel.network/docs/sway-standards/).

### Changed

- [#103](https://github.com/FuelLabs/sway-standards/pull/103) Removes standards in the `./SRC` folder in favor of `./docs`.
- [#106](https://github.com/FuelLabs/sway-standards/pull/106) Updates links from the Sway Book to Docs Hub.

### Fixed

- [#107](https://github.com/FuelLabs/sway-standards/pull/107) resolves the conflict when SRC-5's `owner()` function is used in both the proxy and target contract in the SRC-14 standard.
- [#99](https://github.com/FuelLabs/sway-standards/pull/99) Fixes links and typos in the SRC-14 standard.
- [#112](https://github.com/FuelLabs/sway-standards/pull/112) Fixes inline documentation code in the SRC-3 standard.
- [#115](https://github.com/FuelLabs/sway-standards/pull/115) Hotfixes the Cargo.toml version to the v0.5.1 release.

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
