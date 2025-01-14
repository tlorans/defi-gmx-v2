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

### Protocol

- [ ] What is GMX?
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
