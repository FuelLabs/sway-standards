# Simple Upgradable Proxies

## Abstract

The following proposes a standard for simple upgradable proxies.

## Motivation

We seek to standardize proxy implementation to improve developer experience and enable tooling to automatically deploy or update proxies as needed.

## Prior Art

[This OpenZeppelin blog post](https://blog.openzeppelin.com/the-state-of-smart-contract-upgrades#proxies-and-implementations) is a good survey of the state of the art at this time.

Proxy designs fall into three essential categories:
1. immutable proxies which are lightweight clones of other contracts but can't change targets
2. upgradable proxies such as [UUPS](https://eips.ethereum.org/EIPS/eip-1822) which store a target in storage and delegate all calls to it
3. [Diamonds](https://eips.ethereum.org/EIPS/eip-2535) which are both upgradable and can point to multiple targets on a per method basis

This document falls in the second category. We want to standardize the implementation of simple upgradable passthrough contracts.

The FuelVM provides an `LDC` instruction that is used by Sway's `std::execution::run_external` to provide a similar behavior to EVM's `delegatecall` and execute instructions from another contract while retaining one's own storage context. This is the intended means of implementation of this standard.

## Specification

### Required Behavior

A proxy contract SHOULD maintain the address of its target in its storage and it SHOULD base proxy specific storage fields at `sha256("storage_SRC14")` to avoid collisions with target storage.

The proxy contract MUST delegate any method call not part of its interface to the target contract.

This delegation MUST retain the storage context of the proxy contract.

### Required Public Functions

The following functions MUST be implemented by a proxy contract to follow the SRC-14 standard:

#### `fn set_proxy_address(new_target: ContractId);`

If a valid call is made to this function it MUST change the target of the proxy to the contract at `new_target`.
This method SHOULD implement access controls such that the target can only be changed by a user that possesses the right permissions (typically the proxy owner).

## Rationale

This standard is meant to provide simple upgradability, it deliberately is minimalistic and does not provide the level of functionality of diamonds.

Unlike in UUPS, this standard requires that the upgrade function is part of the proxy and not its target.
This prevents irrecoverable updates if a proxy is made to point to another proxy and no longer has access to upgrade logic.

## Backwards Compatibility

SRC-14 is intended to be compatible with SRC-5 and other standards of contract functionality.

As it is the first attempt to standardize proxy implementation, we do not consider interoperability with other proxy standards.

## Security Considerations

Permissioning proxy target changes is the primary consideration here.
This standard is not opinionated about means of achieving this, use of SRC-5 is recommended.

## Example ABI

```sway
abi SRC14 {
    #[storage(write)]
    fn set_proxy_target(new_target: ContractId);
}
```

## Example Implementation

### [Minimal Proxy](../examples/examples/src14-simple-proxy/owned/src/minimal.sw)

Example of a minimal SRC-14 implementation with no access control.

### [Owned Proxy](../examples/examples/src14-simple-proxy/owned/src/owned.sw)

Example of a SRC-14 implementation that also implements SRC-5.