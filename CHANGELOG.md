# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

Description of the upcoming release here.

### Added Unreleased

- Something new here 1
- Something new here 2

### Changed Unreleased

- Something changed here 1
- Something changed here 2

### Fixed Unreleased

- Some fix here 1
- Some fix here 2

#### Breaking Unreleased

- Some breaking change here 1
- Some breaking change here 2

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