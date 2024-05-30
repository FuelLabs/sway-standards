# Sway Standards

The purpose of the Sway Standards [repository](https://github.com/FuelLabs/sway-standards) is to contain standards for the Sway Language which users can import and use.

Standards in this repository may be in various stages of development. Use of draft standards and feedback on the proposed standards is encouraged. To use a draft, search for a standard using the appropriate GitHub label and implement the standard ABI into your contract.

If you don't find what you're looking for, feel free to create an issue and propose a new standard!

> **Note**
> All standards currently use `forc v0.60.0`.

## Using a standard

To import a standard the following should be added to the project's `Forc.toml` file under `[dependencies]` with the most recent release:

```toml
standards = { git = "https://github.com/FuelLabs/sway-standards", tag = "v0.5.0" }
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

- [SRC-20; Native Asset Standard](./native-asset-src-20.md) defines the implementation of a standard API for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) using the Sway Language.
- [SRC-3; Mint and Burn](./minting-and-burning-src-3.md) is used to enable mint and burn functionality for fungible assets.
- [SRC-7; Arbitrary Asset Metadata Standard](./asset-metadata-src-7.md) is used to store metadata for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets).
- [SRC-9; Metadata Keys Standard](./metadata-keys-src-9.md) is used to store standardized metadata keys for [Native Assets](https://docs.fuel.network/docs/sway/blockchain-development/native_assets) in combination with the SRC-7 standard.
- [SRC-6; Vault Standard](./vault-src-6.md) defines the implementation of a standard API for asset vaults developed in Sway.
- [SRC-13; Soulbound Address](./soulbound-address-src-13.md) defines the implementation of a soulbound address.

### Security and Access Control

- [SRC-5; Ownership Standard](./ownership-src-5.md) is used to restrict function calls to admin users in contracts.
- [SRC-11; Security Information Standard](./security-information-src-11.md) is used to make communication information readily available in the case white hat hackers find a vulnerability in a contract.

### Contracts

- [SRC-12; Contract Factory](./contract-factory-src-12.md) defines the implementation of a standard API for contract factories.
- [SRC-14; Simple Upgradeable Proxies](./simple-upgradeable-proxies-src-14.md) defines the implementation of an upgradeable proxy contract.

### Bridge

- [SRC-8; Bridged Asset](./bridged-asset-src-8.md) defines the metadata required for an asset bridged to the Fuel Network.
- [SRC-10; Native Bridge Standard](./native-bridge-src-10.md) defines the standard API for the Native Bridge between the Fuel Chain and the canonical base chain.

### Documentation

- [SRC-2; Inline Documentation](./inline-documentation-src-2.md) defines how to document your Sway files.
