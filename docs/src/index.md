# Sway Standards

The purpose of the Sway Standards [repository](https://github.com/FuelLabs/sway-standards) is to contain standards for the Sway Language which users can import and use.

Standards in this repository may be in various stages of development. Use of draft standards and feedback on the proposed standards is encouraged. To use a draft, search for a standard using the appropriate GitHub label and implement the standard ABI into your contract.

If you don't find what you're looking for, feel free to create an issue and propose a new standard!

> **Note**
> All standards currently use `forc v0.60.0`.

## Using a standard

To import a standard the following should be added to the project's `Forc.toml` file under `[dependencies]` with the most recent release:

```toml
standards = { git = "https://github.com/FuelLabs/sway-standards", tag = "v0.5.1" }
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

## Standards

### Native Assets

- [SRC-20; Native Asset Standard](./src-20-native-asset.md) defines the implementation of a standard API for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) using the Sway Language.
- [SRC-3; Mint and Burn](./src-3-minting-and-burning.md) is used to enable mint and burn functionality for fungible assets.
- [SRC-7; Arbitrary Asset Metadata Standard](./src-7-asset-metadata.md) is used to store metadata for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets).
- [SRC-9; Metadata Keys Standard](./src-9-metadata-keys.md) is used to store standardized metadata keys for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) in combination with the SRC-7 standard.
- [SRC-6; Vault Standard](./src-6-vault.md) defines the implementation of a standard API for asset vaults developed in Sway.
- [SRC-13; Soulbound Address](./src-13-soulbound-address.md) defines the implementation of a soulbound address.

### Security and Access Control

- [SRC-5; Ownership Standard](./src-5-ownership.md) is used to restrict function calls to admin users in contracts.
- [SRC-11; Security Information Standard](./src-11-security-information.md) is used to make communication information readily available in the case white hat hackers find a vulnerability in a contract.

### Contracts

- [SRC-12; Contract Factory](./src-12-contract-factory.md) defines the implementation of a standard API for contract factories.
- [SRC-14; Simple Upgradeable Proxies](./src-14-simple-upgradeable-proxies.md) defines the implementation of an upgradeable proxy contract.

### Bridge

- [SRC-8; Bridged Asset](./src-8-bridged-asset.md) defines the metadata required for an asset bridged to the Fuel Network.
- [SRC-10; Native Bridge Standard](./src-10-native-bridge.md) defines the standard API for the Native Bridge between the Fuel Chain and the canonical base chain.

### Documentation

- [SRC-2; Inline Documentation](./src-2-inline-documentation.md) defines how to document your Sway files.
