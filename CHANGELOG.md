# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Version 0.8.0]

### Added v0.8.0

- [#183](https://github.com/FuelLabs/sway-standards/pull/183) Adds additional comments and recommended cases on when to use the SRC-7 vs the SRC-15 standard.
- [#178](https://github.com/FuelLabs/sway-standards/pull/178) Creates a Offchain Data section in the docs and README.
- [#181](https://github.com/FuelLabs/sway-standards/pull/181) Adds the `global` key to the SRC-9 standard.
- [#182](https://github.com/FuelLabs/sway-standards/pull/182) Adds the `SRC15GlobalMetadataEvent` event to the SRC-15 Standard.
- [#185](https://github.com/FuelLabs/sway-standards/pull/185) Adds CI job to run `forc publish` on version changes in the release branch.

### Changed v0.8.0

- [#184](https://github.com/FuelLabs/sway-standards/pull/184) Updates documentation on adding libraries via `forc add`.
- [#186](https://github.com/FuelLabs/sway-standards/pull/186) Updates to repository to forc `v0.68.7`.

### Fixed v0.8.0

- [#180](https://github.com/FuelLabs/sway-standards/pull/180) Fixes SRC-20 Multi and Single Asset example ordering.

### Breaking v0.8.0

- [#184](https://github.com/FuelLabs/sway-standards/pull/184) Refactors the repository such that each standard is a separate project to be imported with `forc add`.

1. The dependencies in your `Forc.toml` file must be updated.

    Before:

    ```sway
    [dependencies]
    standards = { git = "https://github.com/FuelLabs/sway-standards", tag = "v0.7.1" }
    ```

    After:

    ```sway
    [dependencies]
    src20 = "0.8.0"
    src7 = "0.8.0"
    ```

2. The following imports have changed:

    SRC-3

    Before:

    ```sway
    use standards::src3::*;
    ```

    After:

    ```sway
    use src3::*;
    ```

    SRC-5

    Before:

    ```sway
    use standards::src5::*;
    ```

    After:

    ```sway
    use src5::*;
    ```

    SRC-6

    Before:

    ```sway
    use standards::src6::*;
    ```

    After:

    ```sway
    use src6::*;
    ```

    SRC-7

    Before:

    ```sway
    use standards::src7::*;
    ```

    After:

    ```sway
    use src7::*;
    ```

    SRC-10

    Before:

    ```sway
    use standards::src10::*;
    ```

    After:

    ```sway
    use src10::*;
    ```

    SRC-11

    Before:

    ```sway
    use standards::src11::*;
    ```

    After:

    ```sway
    use src11::*;
    ```

    SRC-12

    Before:

    ```sway
    use standards::src12::*;
    ```

    After:

    ```sway
    use src12::*;
    ```

    SRC-14

    Before:

    ```sway
    use standards::src14::*;
    ```

    After:

    ```sway
    use src14::*;
    ```

    SRC-15

    Before:

    ```sway
    use standards::src15::*;
    ```

    After:

    ```sway
    use src15::*;
    ```

    SRC-16

    Before:

    ```sway
    use standards::src16::*;
    ```

    After:

    ```sway
    use src16::*;
    ```

    SRC-17

    Before:

    ```sway
    use standards::src17::*;
    ```

    After:

    ```sway
    use src17::*;
    ```

    SRC-20

    Before:

    ```sway
    use standards::src20::*;
    ```

    After:

    ```sway
    use src20::*;
    ```

## [Version 0.7.1]

### Added v0.7.1

- [#175](https://github.com/FuelLabs/sway-standards/pull/175) Introduces the SRC-17; Naming Verification Standard.

### Changed v0.7.1

- [#176](https://github.com/FuelLabs/sway-standards/pull/176) Updates the repository to forc `v0.68.1`, fuel-core `v0.43.1`, and Sway-Libs `v0.25.2`.
- [#174](https://github.com/FuelLabs/sway-standards/pull/174) Updates CODEOWNERS from SwayEx to Onchain.
- [#177](https://github.com/FuelLabs/sway-standards/pull/177) Prepares for the `v0.7.1` release.

### Fixed v0.7.1

- None

### Breaking v0.7.1

- None

## [Version 0.7.0]

### Added v0.7.0

- [#169](https://github.com/FuelLabs/sway-standards/pull/169) Adds a metadata section to the README and about page of the docs hub.

### Changed v0.7.0

- [#172](https://github.com/FuelLabs/sway-standards/pull/172) Prepares for the `v0.7.0` release.

### Fixed v0.7.0

- None

### Breaking v0.7.0

- [#172](https://github.com/FuelLabs/sway-standards/pull/172) Updates to the forc `v0.67.0` release. Earlier releases are not compatible.

## [Version 0.6.3]

### New Standards v0.6.3

- [#161](https://github.com/FuelLabs/sway-standards/pull/161) Defines the SRC-16; Typed Structured Data Standard.

### Added v0.6.3

- [#165](https://github.com/FuelLabs/sway-standards/pull/165) Adds the SRC-15 standard to the README.

### Changed v0.6.3

- [#166](https://github.com/FuelLabs/sway-standards/pull/166) Updates standards, examples, and CI to forc `v0.66.6` and fuel-core `v0.40.0`.
- [#167](https://github.com/FuelLabs/sway-standards/pull/167) Prepares for the v0.6.3 release.

### Fixed v0.6.3

- None

### Breaking v0.6.3

- None

## [Version 0.6.2]

### New Standards v0.6.2

- [#159](https://github.com/FuelLabs/sway-standards/pull/159) Defines the SRC-15; Offchain Metadata Standard.

### Added v0.6.2

- [#152](https://github.com/FuelLabs/sway-standards/pull/152) Adds inline documentation examples to the SRC-6 standard.
- [#159](https://github.com/FuelLabs/sway-standards/pull/159) Adds the SRC-15 standard files and docs.
- [#162](https://github.com/FuelLabs/sway-standards/pull/162) Adds link checker to CI.

### Changed v0.6.2

- [#154](https://github.com/FuelLabs/sway-standards/pull/154) Updates the examples in the standards specififcations to use the offical abi name.
- [#157](https://github.com/FuelLabs/sway-standards/pull/157) Updates the name of the SRC-7 standard to "Onchain Native Asset Metadata Standard".
- [#163](https://github.com/FuelLabs/sway-standards/pull/163) Prepares for the v0.6.2 release.

### Fixed v0.6.2

- [#153](https://github.com/FuelLabs/sway-standards/pull/153) Actually write to storage in `set_src20_data()` in the SRC-20 multi asset example.
- [#160](https://github.com/FuelLabs/sway-standards/pull/160) Fixes a typo in the SRC-7 inline docs.

#### Breaking v0.6.2

- None

## [Version 0.6.1]

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
