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
    <a href="https://crates.io/crates/forc/0.48.1" alt="forc">
        <img src="https://img.shields.io/badge/forc-v0.48.1-orange" />
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

- [SRC-20; Token Standard](./standards/src_20/) defines the implementation of a standard API for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) using the Sway Language.
- [SRC-2; Inline Documentation](./standards/src_2/) defines how to document your Sway files.
- [SRC-3; Mint and Burn](./standards/src_3/) is used to enable mint and burn functionality for Native Assets.
- [SRC-5; Ownership Standard](./standards/src_5/) is used to restrict function calls to admin users in contracts.
- [SRC-7; Arbitrary Asset Metadata Standard](./standards/src_7/) is used to store metadata for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets).
- [SRC-9; Metadata Keys Standard](./standards/src_9/) is used to store standardized metadata keys for [Native Assets](https://fuellabs.github.io/sway/v0.44.0/book/blockchain-development/native_assets.html) in combination with the SRC-7 standard.

## Using a standard

To import a standard the following should be added to the project's `Forc.toml` file under `[dependencies]` with the most recent release:

```rust
standard = { git = "https://github.com/FuelLabs/sway-standards", tag = "v0.1.0" }
```

You may then import your desired standard in your Sway Smart Contract as so:

```rust
use standard::<standard_abi>;
```

For example, to import the SRC-20 Token Standard use the following statements in your `Forc.toml` and Sway Smart Contract file respectively:

```rust
src_20 = { git = "https://github.com/FuelLabs/sway-standards", tag = "v0.1.1" }
```

```rust
use src_20::SRC20;
```

### Examples of Standards

Minimal example implementations for every standard can be found in the [`examples/`](./examples/) folder.

#### SRC-20; Token Standard Examples

##### - [Single Native Assset](./examples/src_20/single_asset/src/single_asset.sw)

Example of the SRC-20 implementation where a contract contains a single asset with one `SubId`. This implementation is recommended for users that intend to deploy a single asset with their contract.

##### - [Multi Native Asset](./examples/src_20/multi_asset/src/multi_asset.sw)

Example of the SRC-20 implementation where a contract contains multiple assets with differing `SubId`s. This implementation is recommended for users that intend to deploy multiple assets with their contract.

#### SRC-3; Mint and Burn Standard Examples

##### - [Single Native Asset](./examples/src_3/single_asset/src/single_asset.sw)

Example of the SRC-3 implementation where a contract only mints a single asset with one `SubId`.

##### - [Multi Native Asset](./examples/src_3/multi_asset/src/multi_asset.sw)

Example of the SRC-3 implementation where a contract mints multiple assets with differing `SubId`s.

#### SRC-5; Ownership Examples

##### - [Uninitalized](./examples/src_5/uninitialized_example/src/uninitialized_example.sw)

Example of the SRC-5 implementation where a contract does not have an owner set at compile time with the intent to set it during runtime.

##### - [Initialized](./examples/src_5/initialized_example/src/initialized_example.sw)

Example of the SRC-5 implementation where a contract has an owner set at compile time.

#### SRC-7; Arbitrary Asset Metadata Standard Examples

##### - [Single Native Asset](./examples/src_7/single_asset/src/single_asset.sw)

Example of the SRC-7 implementation where metadata exists for only a single asset with one `SubId`.

##### - [Mutli Native Asset](./examples/src_7/multi_asset/src/multi_asset.sw)

Example of the SRC-7 implementation where metadata exists for multiple assets with differing `SubId`s.

> **Note**
> All standards currently use `forc v0.48.1`.

<!-- TODO:
## Contributing

Check out the [book](https://fuellabs.github.io/sway-libs/book/index.html) for more info! 
-->

> **Note**
> The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in these documents are to be interpreted as described in RFC 2119: https://www.ietf.org/rfc/rfc2119.txt
