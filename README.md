<p align="center">
    <picture>
        <source media="(prefers-color-scheme: dark)" srcset=".docs/sway-standards-logo-dark-theme.png">
        <img alt="Sway Standards logo" width="400px" src=".docs/sway-standards-logo-light-theme.png">
    </picture>
</p>

<p align="center">
    <a href="https://github.com/FuelLabs/sway-standards/actions/workflows/ci.yml" alt="CI">
        <img src="https://github.com/FuelLabs/sway-standards/actions/workflows/ci.yml/badge.svg" />
    </a>
    <a href="https://crates.io/crates/forc/0.49.1" alt="forc">
        <img src="https://img.shields.io/badge/forc-v0.49.1-orange" />
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

- [SRC-20; Native Asset Standard](./SRCs/src-20.md) defines the implementation of a standard API for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) using the Sway Language.
- [SRC-3; Mint and Burn](./SRCs/src-3.md) is used to enable mint and burn functionality for Native Assets.
- [SRC-7; Arbitrary Asset Metadata Standard](./SRCs/src-7.md) is used to store metadata for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets).
- [SRC-9; Metadata Keys Standard](./SRCs/src-9.md) is used to store standardized metadata keys for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) in combination with the SRC-7 standard.
- [SRC-6; Vault Standard](./SRCs/src-6.md) defines the implementation of a standard API for asset vaults developed in Sway.

### Access Control

- [SRC-5; Ownership Standard](./SRCs/src-5.md) is used to restrict function calls to admin users in contracts.

### Contracts

- [SRC-12; Contract Factory](./SRCs/src-12.md) defines the implementation of a standard API for contract factories.

### Bridge

- [SRC-8; Bridged Asset](./SRCs/src-8.md) defines the metadata required for an asset bridged to the Fuel Network.
- [SRC-10; Native Bridge Standard](./SRCs/src-10.md) defines the standard API for the Native Bridge between the Fuel Chain and the canonical base chain.

### Documentation

- [SRC-2; Inline Documentation](./SRCs/src-2.md) defines how to document your Sway files.

## Using a standard

To import a standard the following should be added to the project's `Forc.toml` file under `[dependencies]` with the most recent release:

```rust
standards = { git = "https://github.com/FuelLabs/sway-standards", tag = "v0.1.0" }
```

> **NOTE:** 
> Be sure to set the tag to the latest release.

You may then import your desired standard in your Sway Smart Contract as so:

```rust
use standards::<standard>::<standard_abi>;
```

For example, to import the SRC-20 Native Asset Standard use the following statement in your Sway Smart Contract file:

```rust
use standards::src20::SRC20;
```

### Examples of Standards

Minimal example implementations for every standard can be found in the [`examples/`](./examples/) folder.

#### SRC-20; Native Asset Standard Examples

##### - [Single Native Assset](./examples/src20-native-asset/single_asset/src/single_asset.sw)

Example of the SRC-20 implementation where a contract contains a single asset with one `SubId`. This implementation is recommended for users that intend to deploy a single asset with their contract.

##### - [Multi Native Asset](./examples/src20-native-asset/multi_asset/src/multi_asset.sw)

Example of the SRC-20 implementation where a contract contains multiple assets with differing `SubId`s. This implementation is recommended for users that intend to deploy multiple assets with their contract.

#### SRC-3; Mint and Burn Standard Examples

##### - [Single Native Asset](./examples/src3-mint-burn/single_asset/src/single_asset.sw)

Example of the SRC-3 implementation where a contract only mints a single asset with one `SubId`.

##### - [Multi Native Asset](./examples/src3-mint-burn/multi_asset/src/multi_asset.sw)

Example of the SRC-3 implementation where a contract mints multiple assets with differing `SubId`s.

#### SRC-5; Ownership Examples

##### - [Uninitalized](./examples/src5-ownership/uninitialized_example/src/uninitialized_example.sw)

Example of the SRC-5 implementation where a contract does not have an owner set at compile time with the intent to set it during runtime.

##### - [Initialized](./examples/src5-ownership/initialized_example/src/initialized_example.sw)

Example of the SRC-5 implementation where a contract has an owner set at compile time.

#### SRC-6; Vault Standard Examples

##### [Multi Asset Vault](./examples/src6-vault/multi_asset_vault/)

A basic implementation of the vault standard that supports any number of sub vaults being created for every AssetId.

##### [Single Asset Vault](./examples/src6-vault/single_asset_vault/)

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single AssetId.

##### [Single Asset Single Sub Vault](./examples/src6-vault/single_asset_single_sub_vault/)

A basic implementation of the vault standard demonstrating how to restrict deposits and withdrawals to a single AssetId, and to a single Sub vault.

#### SRC-7; Arbitrary Asset Metadata Standard Examples

##### - [Single Native Asset](./examples/src7-metadata/single_asset/src/single_asset.sw)

Example of the SRC-7 implementation where metadata exists for only a single asset with one `SubId`.

##### - [Multi Native Asset](./examples/src7-metadata/multi_asset/src/multi_asset.sw)

Example of the SRC-7 implementation where metadata exists for multiple assets with differing `SubId`s.

#### SRC-12; Contract Factory Standard Examples

##### [With Configurables](./examples/src12-contract-factory/with_configurables/src/with_configurables.sw)

Example of the SRC-12 implementation where contract deployments contain configurable values that differentiate the bytecode root from other contracts with the same bytecode.

##### [Without Configurables](./examples/src12-contract-factory/without_configurables/src/without_configurables.sw)

Example of the SRC-12 implementation where all contract deployments are identitcal and thus have the same bytecode and root.

> **Note**
> All standards currently use `forc v0.53.0`.

<!-- TODO:
## Contributing

Check out the [book](https://fuellabs.github.io/sway-libs/book/index.html) for more info! 
-->

> **Note**
> The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in these documents are to be interpreted as described in RFC 2119: https://www.ietf.org/rfc/rfc2119.txt
