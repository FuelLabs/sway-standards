# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [Version 0.52.0] - 2024-06-12

Description of the upcoming release here.

### Added

- [#107](https://github.com/FuelLabs/sway-standards/pull/107): Adds the `proxy_owner()` function to the SRC-14 standard.
- [#104](https://github.com/FuelLabs/sway-standards/pull/104): Adds the CHANGELOG.md file to Sway-Standards.
- [#103](https://github.com/FuelLabs/sway-standards/pull/103): Adds Sway-Standards to the [docs hub](https://docs.fuel.network/docs/sway-standards/).

### Changed

- [#103](https://github.com/FuelLabs/sway-standards/pull/103) Removes standards in the `./SRC` folder in favor of `./docs`.

### Fixed

- [#107](https://github.com/FuelLabs/sway-standards/pull/107) resolves the conflict when SRC-5's `owner()` function is used in both the proxy and target contract in the SRC-14 standard.
- [#99](https://github.com/FuelLabs/sway-standards/pull/99) Fixes links and typos in the SRC-14 standard.

#### Breaking

- None