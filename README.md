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
  - vest to convert esGMX to GMX
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
- [Short ETH](https://arbiscan.io/tx/0x910aceeabc176d44788500403b2db3f7973bd8118fb79f57c490c8ab0505b295)
- [Short ETH (part 2? receive ETH)](https://arbiscan.io/tx/0x5212c55508b8f888f666220a17b584adc73623d044548c0822400ba52a6af8c8)
- [Swap DAI to GMX (part 1)](https://arbiscan.io/tx/0x35572d81e52d1a2f254bcdeb30232e4fae9c4fc178f8b92240f9169951f70c36)
- [Swap DAI to GMX (part 2 - receive GMX)](https://arbiscan.io/tx/0xb44af9795a4f728a3813aed7cafc7a66a5e4b6c12a2e1cfc3999be1ff960e9cd)
- [Stake GMX](https://arbiscan.io/tx/0x0ed2a66323713c2e78dd53750612f3e9bcc97f2f8c02633a433a413889142067)
- [Buy GLV (part 1)](https://arbiscan.io/tx/0x8d7d6e6b99fbeb095aeee4e495c528e4187bbabd0a3f728ef874f6b31bf73405)
- [Buy GLV (part 2)](https://arbiscan.io/tx/0x3cfcd9e1bdcc57a727dd66d6ed38afe78bbf3430015072078876240d183129f3)
- [Buy GM ETH/USD (part 1)](https://arbiscan.io/tx/0x6021800ad3d31003082fa6dc7fb5b6b8ff83208cadfcca98ffaa0774d6f652b8)
- [Buy GM ETH/USD (part 2)](https://arbiscan.io/tx/0x719b63dbef8d38006918c0e787b98a8373606b6147b77ae84a91fe2338132f4a)
