<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset="assets/sway-standards-logo-dark-theme.png">
        <img alt="Sway Standards logo" width="400px" src="assets/sway-standards-logo-light-theme.png">
    </picture>
</p>

<p align="center">
    <a href="https://github.com/FuelLabs/sway-standards/actions/workflows/ci.yml" alt="CI">
        <img src="https://github.com/FuelLabs/sway-standards/actions/workflows/ci.yml/badge.svg" />
    </a>
    <a href="https://crates.io/crates/forc/0.63.3" alt="forc">
        <img src="https://img.shields.io/badge/forc-v0.63.3-orange" />
    </a>
    <a href="./LICENSE" alt="forc">
        <img src="https://img.shields.io/github/license/FuelLabs/sway-standards" />
    </a>
    <a href="https://discord.gg/xfpK4Pe">
        <img src="https://img.shields.io/discord/732892373507375164?color=6A7EC2&logo=discord&logoColor=ffffff&labelColor=6A7EC2&label=Discord" />
    </a>
</p>

## Overview

The purpose of this repository is to contain standards for the Sway Language which users can import and use.

Standards in this repository may be in various stages of development. Use of draft standards and feedback on the proposed standards is encouraged. To use a draft, search for a standard using the appropriate GitHub label and implement the standard abi into your contract.

If you don't find what you're looking for, feel free to create an issue and propose a new standard!

> **Note**
> Sway is a language under heavy development therefore the standards may not be the most ergonomic. Over time they should receive updates / improvements in order to demonstrate how Sway can be used in real use cases.

## Standards

### Native Assets

- [SRC-20; Native Asset Standard](https://docs.fuel.network/docs/sway-standards/src-20-native-asset/) defines the implementation of a standard API for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) using the Sway Language.
- [SRC-3; Mint and Burn](https://docs.fuel.network/docs/sway-standards/src-3-minting-and-burning/) is used to enable mint and burn functionality for fungible assets.
- [SRC-7; Onchain Asset Metadata Standard](https://docs.fuel.network/docs/sway-standards/src-7-asset-metadata/) is used to store metadata for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets).
- [SRC-9; Metadata Keys Standard](https://docs.fuel.network/docs/sway-standards/src-9-metadata-keys/) is used to store standardized metadata keys for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) in combination with the SRC-7 standard.
- [SRC-6; Vault Standard](https://docs.fuel.network/docs/sway-standards/src-6-vault/) defines the implementation of a standard API for asset vaults developed in Sway.
- [SRC-13; Soulbound Address](https://docs.fuel.network/docs/sway-standards/src-13-soulbound-address/) provides a predicate interface to lock [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) as soulbound.

### Access Control

- [SRC-5; Ownership Standard](https://docs.fuel.network/docs/sway-standards/src-5-ownership/) is used to restrict function calls to admin users in contracts.

### Contracts

- [SRC-12; Contract Factory](https://docs.fuel.network/docs/sway-standards/src-12-contract-factory/) defines the implementation of a standard API for contract factories.
- [SRC-14; Simple Upgradable Proxies](https://docs.fuel.network/docs/sway-standards/src-14-simple-upgradeable-proxies/) defines the implementation of a standard API for simple upgradable proxies.

### Bridge

- [SRC-8; Bridged Asset](https://docs.fuel.network/docs/sway-standards/src-8-bridged-asset/) defines the metadata required for an asset bridged to the Fuel Network.
- [SRC-10; Native Bridge Standard](https://docs.fuel.network/docs/sway-standards/src-10-native-bridge/) defines the standard API for the Native Bridge between the Fuel Chain and the canonical base chain.

### Documentation

- [SRC-2; Inline Documentation](https://docs.fuel.network/docs/sway-standards/src-2-inline-documentation/) defines how to document your Sway files.

## Using a standard

To import a standard the following should be added to the project's `Forc.toml` file under `[dependencies]` with the most recent release:

```toml
standards = { git = "https://github.com/FuelLabs/sway-standards", tag = "v0.6.1" }
```

> **NOTE:**
> Be sure to set the tag to the latest release.

You may then import your desired standard in your Sway Smart Contract as so:

```sway
use standards::<standard>::<standard_abi>;
```

For example, to import the SRC-20 Native Asset Standard use the following statement in your Sway Smart Contract file:

```sway
use standards::src20::SRC20;
```

### Examples of Standards

Minimal example implementations for every standard can be found in the [`examples/`](./examples/) folder.

#### SRC-20; Native Asset Standard Examples

##### - [Single Native Asset](./examples/src20-native-asset/single_asset/src/single_asset.sw)

Example of the SRC-20 implementation where a contract contains a single asset with one `SubId`. This implementation is recommended for users that intend to deploy a single asset with their contract.

##### - [Multi Native Asset](./examples/src20-native-asset/multi_asset/src/multi_asset.sw)

Example of the SRC-20 implementation where a contract contains multiple assets with differing `SubId`s. This implementation is recommended for users that intend to deploy multiple assets with their contract.

#### SRC-3; Mint and Burn Standard Examples

##### - [Single Native Asset](./examples/src3-mint-burn/single_asset/src/single_asset.sw)

Example of the SRC-3 implementation where a contract only mints a single asset with one `SubId`.

##### - [Multi Native Asset](./examples/src3-mint-burn/multi_asset/src/multi_asset.sw)

Example of the SRC-3 implementation where a contract mints multiple assets with differing `SubId`s.

#### SRC-5; Ownership Examples

##### - [Uninitialized](./examples/src5-ownership/uninitialized_example/src/uninitialized_example.sw)

Example of the SRC-5 implementation where a contract does not have an owner set at compile time with the intent to set it during runtime.

##### - [Initialized](./examples/src5-ownership/initialized_example/src/initialized_example.sw)

Example of the SRC-5 implementation where a contract has an owner set at compile time.

#### SRC-6; Vault Standard Examples

##### [Multi Asset Vault](./examples/src6-vault/multi_asset_vault/)

A basic implementation of the vault standard that supports any number of sub vaults being created for every `AssetId`.

##### [Single Asset Vault](./examples/src6-vault/single_asset_vault/)

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single `AssetId`.

##### [Single Asset Single Sub Vault](./examples/src6-vault/single_asset_single_sub_vault/)

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single `AssetId`, and to a single Sub vault.

#### SRC-7; Arbitrary Asset Metadata Standard Examples

##### - [Single Native Asset](./examples/src7-metadata/single_asset/src/single_asset.sw)

Example of the SRC-7 implementation where metadata exists for only a single asset with one `SubId`.

##### - [Multi Native Asset](./examples/src7-metadata/multi_asset/src/multi_asset.sw)

Example of the SRC-7 implementation where metadata exists for multiple assets with differing `SubId`s.

#### SRC-12; Contract Factory Standard Examples

##### [With Configurables](./examples/src12-contract-factory/with_configurables/src/with_configurables.sw)

Example of the SRC-12 implementation where contract deployments contain configurable values that differentiate the bytecode root from other contracts with the same bytecode.

##### [Without Configurables](./examples/src12-contract-factory/without_configurables/src/without_configurables.sw)

Example of the SRC-12 implementation where all contract deployments are identical and thus have the same bytecode and root.

#### SRC-14; Simple Upgradable Proxies Standard Examples

##### [Minimal](./examples/src14-simple-proxy/minimal/src/minimal.sw)

Example of a minimal SRC-14 implementation with no access control.

##### [Owned Proxy](./examples/src14-simple-proxy/owned/src/owned.sw)

Example of a SRC-14 implementation that also implements [SRC-5](https://docs.fuel.network/docs/sway-standards/src-5-ownership/).

> **Note**
> All standards currently use `forc v0.63.3`.

<!-- TODO:
## Contributing

Check out the [book](https://fuellabs.github.io/sway-libs/book/index.html) for more info!
-->

> **Note**
> The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in these documents are to be interpreted as described in RFC 2119: https://www.ietf.org/rfc/rfc2119.txt
