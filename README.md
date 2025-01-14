# GMX V2

This course provides a comprehensive guide for developers to understand, interact with, and build applications using the GMX protocol.

### Setup Foundry

```shell
cd foundry
forge build
```

## Course

### Introduction

- [ ] Into
- [ ] Prerequisites
- [ ] Goals and expected outcomes
- [ ] Project setup

### ETH to Arbitrum

- [ ] Transactions

### Protocol

- [ ] What is GMX?
  - GMX is a decentralized spot and perpetual exchange
  - Spot exchange
  - Perpetual exchange
- [ ] Key features
- [ ] How the protocol works
  - users (LP, traders, GMX and GM / GLV holders)
  - fee distribution
- [ ] Terminologies and examples
  - [ ] Spot trading
  - [ ] Perpetuals
  - [ ] Futures
  - [ ] Funding rate and open interest
  - [ ] Long
  - [ ] Short
  - [ ] Leverage
  - [ ] Margin
  - [ ] Liquidity pools and markets
  - [ ] Liquidation price
  - [ ] Index
  - [ ] Synthetic asset

### Contract architecture

- [ ] Contract architecture
- [ ] Liquidity (contract calls)
  - GM (GMX market) pools
  - GLV (GMX liquidity vault) pools
- [ ] Foundry exercises (liquidity management)
- [ ] Trading
  - Trading system
  - Market types
  - 2 step transaciton process
  - Trading (contract call)
  - Foundry exercises
- [ ] Managing position (TODO: split position and liquidity?)
  - [ ] Open (contract call)
  - [ ] Close (contract call)
  - [ ] Long (contract call)
  - [ ] Short (contract call)
  - [ ] Deposit collateral (contractl call)
  - [ ] Withdraw collateral (contract call)
  - [ ] Foundry exercises
- [ ] Liquidation
  - [ ] Triggers
    - Limit order take profit, stop loss, auto cancel
    - ADL
  - [ ] Market types
    - Fully backed
    - Synthetic
  - [ ] Fees
    - Open / close
    - Swap
    - Price impact and rebates
    - Funding fees
    - Borrowing fee
    - Newtork fess
  - [ ] Risk management mechanism
    - liquidation and ADL
      - when called
      - implementation details
  - [ ] Foundry exercises?
  - [ ] Staking
    - what tokens can be staked
    - what rewards can be claimed
    - implementation details
    - Foundry exercises

### Tokenomics

Explain utilities, acquistion methods, differences and staking processes.

- [ ] GMX
  - utilities
  - governance
  - buy back mechanism
  - stake
- [ ] esGMX
- [ ] GM
  - what
  - how to obtain
- [ ] GLV
  - what is GLV vault
  - how to obtain
  - utility
- [ ] GLP (V1)
  - quick explanation
- [ ] Foundry exercises

### Application

- TODO: application

## Resources

##### Arbitrum

- [Arbitrum](https://arbitrum.io/)
- [Arbitrum bridge](https://bridge.arbitrum.io/)
- [Bridge DAI from ETH to Arbitrum One tx](https://etherscan.io/tx/0xb15ea04494164f2d1dd6a12222010c65f496190e69f6acd909d0b6c80fbf37cb)
- [Deposit ETH into Arbitrum One tx](https://etherscan.io/tx/0x1752e3449694e4c3d516093294f39a2a3576198db7d3af3975704b0a339bf4b1)

##### GMX

- [GMX](https://gmx.io/)
- [Swap DAI to ETH (part 1)](https://arbiscan.io/tx/0x747665f80ccd64918af4f4cd2d3c7e7c077d061d61bc47fc99f644d1eb4d18f4)
- [Swap DAI to ETH (part 2 - receive ETH)](https://arbiscan.io/tx/0x98658391314497c36fe70a3104ae230fd592b7d67941858e08bd6d207142e9e9)
