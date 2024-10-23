# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

Description of the upcoming release here.

### Added

- [#152](https://github.com/FuelLabs/sway-standards/pull/152) Adds inline documentation examples to the SRC-6 standard.

### Changed

- [#154](https://github.com/FuelLabs/sway-standards/pull/154) Updates the examples in the standards specififcations to use the offical abi name.
- [#157](https://github.com/FuelLabs/sway-standards/pull/157) Updates the name of the SRC-7 standard to "Onchain Native Asset Metadata Standard".

### Fixed

- [#153](https://github.com/FuelLabs/sway-standards/pull/153) Actually write to storage in `set_src20_data()` in the SRC-20 multi asset example.

#### Breaking

- Some breaking change here 1
- Some breaking change here 2

## [Version 0.6.1]

Description of the upcoming release here.

### Added v0.6.1

- [#149](https://github.com/FuelLabs/sway-standards/pull/149) Adds struct field getters, `new()`, and `Eq` implementations to SRC-10's `DepositMessage` and `MetadataMessage` types and SRC-11's `SecurityInformation` type.
- [#149](https://github.com/FuelLabs/sway-standards/pull/149) Adds `Eq` implementation to SRC-5's `AccessError` error.
- [#149](https://github.com/FuelLabs/sway-standards/pull/149) Adds check functions and `Eq` implementation to SRC-5's `State` type and SRC-10's `DepositType` type.
- [#149](https://github.com/FuelLabs/sway-standards/pull/149) Adds struct field getters, `new()`, `log()`, and `Eq` implementations to SRC-6's `Deposit`, and `Withdraw` types, SRC-20's `SetNameEvent`, `SetSymbolEvent`, `SetDecimalsEvent`, and `TotalSupplyEvent` events, and SRC-7's `SetMetadataEvent` event.

### Changed v0.6.1

- [#135](https://github.com/FuelLabs/sway-standards/pull/135) Updates standards, examples and CI to latest forc 0.63.3.
- [#147](https://github.com/FuelLabs/sway-standards/pull/147) Prepares for the v0.6.1 release.

### Fixed v0.6.1

- [#137](https://github.com/FuelLabs/sway-standards/pull/137) Resolves warnings for SRC-6, SRC-14, and SRC-5 standard examples.
- [#136](https://github.com/FuelLabs/sway-standards/pull/136) Fixes SRC14 to recommend namespacing all non-standardized storage variables under the SRC14 namespace, fixes typos, and improves markdown in docs and inline documentation.
- [#142](https://github.com/FuelLabs/sway-standards/pull/142) Fixes errors in inline documentation for SRC-10, SRC-12, SRC-14, SRC-20, SRC-3, SRC-5, SRC-7 standards.
- [#151](https://github.com/FuelLabs/sway-standards/pull/151) Fixes SRC-6 standard examples conform to the latest SRC-20 spec of logging values after updates.
- [#151](https://github.com/FuelLabs/sway-standards/pull/151) Formats code of SRC-6 examples, and fixes some comments.

## [Version 0.6.0]

### Added v0.6.0

- [#130](https://github.com/FuelLabs/sway-standards/pull/130) Adds the `SetNameEvent`, `SetSymbolEvent`, `SetDecimalsEvent` and `TotalSupplyEvent` to the SRC-20 standard.
- [#130](https://github.com/FuelLabs/sway-standards/pull/130) Adds the `SetMetadataEvent` to the SRC-7 standard.

### Changed v0.6.0

- [#130](https://github.com/FuelLabs/sway-standards/pull/130) Splits examples into seperate workspace projects for improved continuous integration.
- [#139](https://github.com/FuelLabs/sway-standards/pull/139) Prepares for the v0.6.0 release.

### Breaking v0.6.0

- [#131](https://github.com/FuelLabs/sway-standards/pull/131) Makes the SRC-3 `mint()` function's `SubId` argument an `Option`.

Before:

```sway
mint(Identity::Address(Address::zero()), SubId::zero(), 100);
```

After:

```sway
mint(Identity::Address(Address::zero()), Some(SubId::zero()), 100);
```

## [Version 0.5.2]

### Changed v0.5.2

- [#126](https://github.com/FuelLabs/sway-standards/pull/126) Prepares for v0.5.2 release.

### Fixed v0.5.2

- [#121](https://github.com/FuelLabs/sway-standards/pull/121) Fixes the `deposit` function in the SRC-6 standard, uses try_read instead of read in order to allow first time deposits to a vault.
- [#122](https://github.com/FuelLabs/sway-standards/pull/122) Fixes the SRC-6 example contract from a critical bug where the contract can be drained.
- [#124](https://github.com/FuelLabs/sway-standards/pull/124) Fixes compiler warnings for libraries

## [Version 0.5.1]

### Added v0.5.1

- [#107](https://github.com/FuelLabs/sway-standards/pull/107) Adds the `proxy_owner()` function to the SRC-14 standard.
- [#104](https://github.com/FuelLabs/sway-standards/pull/104) Adds the CHANGELOG.md file to Sway-Standards.
- [#110](https://github.com/FuelLabs/sway-standards/pull/110) Adds the `proxy_target()` function to the SRC-14 standard.
- [#103](https://github.com/FuelLabs/sway-standards/pull/103) Adds Sway-Standards to the [docs hub](https://docs.fuel.network/docs/sway-standards/).

### Changed v0.5.1

- [#103](https://github.com/FuelLabs/sway-standards/pull/103) Removes standards in the `./SRC` folder in favor of `./docs`.
- [#106](https://github.com/FuelLabs/sway-standards/pull/106) Updates links from the Sway Book to Docs Hub.
- [#120](https://github.com/FuelLabs/sway-standards/pull/120) Updates repository to forc v0.61.0 and uses new namespace in SRC-14 example.

### Fixed v0.5.1

- [#107](https://github.com/FuelLabs/sway-standards/pull/107) resolves the conflict when SRC-5's `owner()` function is used in both the proxy and target contract in the SRC-14 standard.
- [#99](https://github.com/FuelLabs/sway-standards/pull/99) Fixes links and typos in the SRC-14 standard.
- [#112](https://github.com/FuelLabs/sway-standards/pull/112) Fixes inline documentation code in the SRC-3 standard.
- [#115](https://github.com/FuelLabs/sway-standards/pull/115) Hotfixes the Cargo.toml version to the v0.5.1 release.

### Breaking v0.5.1

- [#110](https://github.com/FuelLabs/sway-standards/pull/110) Breaks the `SRC14` abi by adding the `proxy_target()` function. This will need to be added to any SRC14 implementation. The new abi is as follows:

```sway
abi SRC14 {
    #[storage(read, write)]
    fn set_proxy_target(new_target: ContractId);
    #[storage(read)]
    fn proxy_target() -> Option<ContractId>;
}
```
