# GMX V2

This course provides a comprehensive guide for developers to understand, interact with, and build applications using the GMX protocol.

### Setup Foundry

```shell
cd foundry
forge build
```

## Course

### Introduction

- [ ] Course intro
  - Prerequisites
    - DAI, WETH, AMM, etc..
    - Advanced Foundry (multicall)
  - Goals and expected outcomes
- [ ] Project setup
- [ ] UI - Quick guide on how to bridge ETH
  - [ ] Transactions

### Protocol

- [ ] What is GMX?
  - Decentralized spot and perpetual exchange
  - Speculate on the price of an underlying asset without owning the asset itself
  - Key features
    - 2 step transactions
      - key
    - 0 price impact?
    - Dynamic funding rate?
    - Isolated pools
- [ ] How the protocol works
  - Users (LP, traders, GMX and GM / GLV holders)
  - Funding mechanism
    - Open interest
    - Price impact?
    - Borrowing fees?
  - Where does profit / loss come from?
  - Fee distribution
- [ ] Terminologies and examples
  - [ ] Spot trading
  - [ ] Perpetuals
    - Use cases
      - Price speculation
      - Hedging
      - Arbitrage
  - [ ] Futures
  - [ ] Funding rate mechanism
  - [ ] Open interest
    - The total number of open contracts that have not been settled or closed out
  - [ ] Market order
  - [ ] Limit order
  - [ ] Long
  - [ ] Short
  - [ ] Leverage
  - [ ] Margin
  - [ ] Initial margin
  - [ ] Maintanence margin
  - [ ] Liquidity pools and markets
  - [ ] Liquidation price
  - [ ] Index
  - [ ] Derivative
  - [ ] Synthetic asset
  - [ ] Well fundedness

### Contract architecture

- [ ] Contract architecture
  - wnt = wrapped native token
  - multicall
  - execution fee
  - bank / vault
  - router
    - ExchangeRouter
    - GlvRouter
  - utils
  - market tokens
  - reader
- Liquidity
  - [notes](./notes/pools.md)
  - [ ] UI
    - Difference between GLV and GM
    - GM (GMX market) pools -> isolated pool?
    - GLV (GMX liquidity vault) pools
    - Buy
      - Single and pair liquidity
      - [ ] Token price
        - `MarketUtils.getMarketTokenPrice`
          - pool value usd / total market token supply
          - TODO: what is impact pool
            - Store funds collected from traders who pay positive price impact fees
            - Pay out traders who receive negative price impact rebates
            - position impact distribution rate
      - [ ] Buy fee
      - [ ] Network fee
    - Sell
      - Pair liquidity
      - [ ] Sell fee
      - [ ] Network fee
    - [ ] Shift
    - [ ] Trade
      - Swap
        - market
        - limit
      - Long
        - market
          - tp / sl
        - limit -> create long above limit
        - tp / sl
        - stop market
      - Short
        - market
          - tp / sl
        - limit -> create short below limit
        - tp / sl
        - stop market
    - [x] Transactions
      - [Buy GLV (part 1)](https://arbiscan.io/tx/0x8d7d6e6b99fbeb095aeee4e495c528e4187bbabd0a3f728ef874f6b31bf73405)
      - [Buy GLV (part 2)](https://arbiscan.io/tx/0x3cfcd9e1bdcc57a727dd66d6ed38afe78bbf3430015072078876240d183129f3)
      - [Buy GM ETH/USD (part 1)](https://arbiscan.io/tx/0x6021800ad3d31003082fa6dc7fb5b6b8ff83208cadfcca98ffaa0774d6f652b8)
      - [Buy GM ETH/USD (part 2)](https://arbiscan.io/tx/0x719b63dbef8d38006918c0e787b98a8373606b6147b77ae84a91fe2338132f4a)
      - [Sell GLV (part 1)](https://arbiscan.io/tx/0xb60ed4fa2252dae32f8252f5702c3caf0cd2f074a9e9b41eaaaae2cea3f760c6)
      - [Sell GLV (part 2)](https://arbiscan.io/tx/0x5120cf011c75d9b67bdffa99c4e3c6fffb5e8bb428f0080fc7ccded361bf98e6)
      - [Sell GM ETH/USD (part 1)](https://arbiscan.io/tx/0xda4bc1d39be6ea85f8323875cbc4920aa33d0af38d7af2eb3f3dd03d174ae98e)
      - [Sell GM ETH/USD (part 2)](https://arbiscan.io/tx/0xbdc46442f47149089f4976190a97c81bf476eb43b0478689e0ac918a9a502641)
      - [Buy BTC/USDC GLV (part 1)](https://arbiscan.io/tx/0x87ed238503646ef7d7045ce639efd59845db94384a00d37aedc174d52050eb83)
      - [Buy BTC/USDC GLV (part 2)](https://arbiscan.io/tx/0x3f0c373aa132815204574ed7981c584d4f044eb2c00a160b7dd992822de66763)
      - [Buy BTC/USDC GM (part 1)](https://arbiscan.io/tx/0xef88d101a155ffd16427fc78d50e6028d612c8bc1e8d46a7810d53882f705f91)
      - [Buy BTC/USDC GM (part 2)](https://arbiscan.io/tx/0x54357ec00e44fa8d3d701368af4a3979a28dd2383b9eb5a3f299253e8ce217a1)
  - [ ] Token pricing
  - [ ] Contract calls (using Tenderly?)
  - [ ] Foundry exercises
    - GM - Buy, sell, shift
    - GLV - Buy, sell
- Trading
  - [ ] UI
    - Market (ETH / USD, WBTC / USD, etc...)
      - Fully backed
      - Synthetic
    - Long / Short / Swap
      - Long -> profit in long asset
      - Short -> profit in stablecoin
      - Profit can be swapped
    - Leverage
    - Open cost
    - Limit, TP / SL
    - Liquidation price
      - Long
      - Short
    - 2 steps transaciton process
    - Managing positions
      - Close, deposit, withdraw collateral
      - Claims (funding fees)
    - [ ] Transactions
  - [ ] Fees (PositionPricingUtils.sol)
    - Open / close
    - Swap
    - Price impact and rebates
    - Funding fees
    - Borrowing fee
    - Newtork fee
    - UI
  - [ ] Example strategies
    - Long ETH, ETH collateral
    - Long ETH, USDC collateral
    - Short ETH, ETH collateral -> delta neutral?
    - Short ETH, USDC collateral
  - [ ] Math - Funding rate -> dynamic borrow fee?
    - adaptive funding rate
  - [ ] Math - liquidation price?
  - [ ] Math - profit / loss?
  - [ ] How is profit fully backed?
  - [ ] Contract calls
    - Swap
    - Long (open / close / deposit / withdraw)
    - Short (open / close / deposit / withdraw)
  - [ ] Foundry exercises
    - Swap
    - Long - open, close, deposit, withdraw
    - Short - open, close, deposit, withdraw
  - [ ] UI - limit order, TP, SL
    - Transactions
  - [ ] Limit order
  - [ ] TP
  - [ ] SL
  - [ ] Auto cancel
  - [ ] ADL
  - [ ] Contract calls?
  - [ ] Foundry exercises
    - Long, short, Limit, TP, SL
- Liquidation
  - [ ] UI
    - Transactions
  - [ ] When executed?
  - [ ] Fees
  - [ ] Contract calls
  - [ ] Foundry exercises? -> Not public function -> no exercise

### Tokenomics

Explain utilities, acquistion methods, differences and staking processes.

- [ ] GMX
  - Utilities
  - Emissions
  - Governance
  - Benefits
    - Protocol revenue
    - Rewards
    - Voting power
  - Buy back mechanism
  - [ ] UI
    - Buy, stake GMX
    - Claim rewards
    - Where are the yield and rewards coming from?
    - [ ] Transactions
  - [ ] Foundry exercises
    - Buy -> DEX, no exercise
    - stake, delegate, unstake, claim rewards
    - [Stake GMX](https://arbiscan.io/tx/0x0ed2a66323713c2e78dd53750612f3e9bcc97f2f8c02633a433a413889142067)
    - [Unstake GMX](https://arbiscan.io/tx/0x2bbfefc59c295349405a86b08f9bd68b020e49836e9775de74e442908732678f)
    - [Claim rewards](https://arbiscan.io/tx/0x23f1f338dc2456cf476692f34ea00838a1e621f8fd2aff330927edf256de8b1d)
    - [Delegate](https://arbiscan.io/tx/0x245404338a81a8faccddf6ad8e944928bac6b687db8d7e217e47fdde94abd84f)
- [ ] esGMX -> has historically been awarded as an incentive for GMX Staking -> TODO: skip?
  - [ ] UI?
    - Vest to convert esGMX to GMX
  - [ ] Foundry exercises?
- [ ] GLP (V1)
  - Quick explanation

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
- [GMX GitHub](https://github.com/gmx-io/gmx-contracts)
- [GMX Synthetics GitHub](https://github.com/gmx-io/gmx-synthetics)
- [Unveiling GMX v2: A Game-Changer for DeFi Derivatives?](https://blog.rudy.capital/unveiling-gmx-v2-a-game-changer-for-defi-derivatives-5ff20f2ab731)

##### Transactions

**_Trades_**

- [Swap DAI to ETH (part 1)](https://arbiscan.io/tx/0x747665f80ccd64918af4f4cd2d3c7e7c077d061d61bc47fc99f644d1eb4d18f4)
- [Swap DAI to ETH (part 2 - receive ETH)](https://arbiscan.io/tx/0x98658391314497c36fe70a3104ae230fd592b7d67941858e08bd6d207142e9e9)
- [Short ETH](https://arbiscan.io/tx/0x910aceeabc176d44788500403b2db3f7973bd8118fb79f57c490c8ab0505b295)
- [Short ETH (part 2? receive ETH)](https://arbiscan.io/tx/0x5212c55508b8f888f666220a17b584adc73623d044548c0822400ba52a6af8c8)
- [Short ETH close position (part 1)](https://arbiscan.io/tx/0x35725018aaa145d36a6969ad31f6a20380e428e6a906de97cdcf07e5ca1a0ffa)
- [Short ETH close position - receive USDC (part 2)](https://arbiscan.io/tx/0x0cb45095f9d18d328cd37f3f075e98920e7dbfce4369881c5d62208f903675b9)
- [Swap DAI to GMX (part 1)](https://arbiscan.io/tx/0x35572d81e52d1a2f254bcdeb30232e4fae9c4fc178f8b92240f9169951f70c36)
- [Swap DAI to GMX (part 2 - receive GMX)](https://arbiscan.io/tx/0xb44af9795a4f728a3813aed7cafc7a66a5e4b6c12a2e1cfc3999be1ff960e9cd)
- [Short 0.01 ETH, ETH collateral (part 1)](https://arbiscan.io/tx/0x15f4bb54997d8efbf0816313e64120fe5bf89ab31fe78f4a647f47b61b629eea)
- [Short 0.01 ETH, ETH collateral (part 2](https://arbiscan.io/tx/0x7039c81c3f14f54fbfb45c337fb13e4513b8e795a2d9237b66b2b191e717121e)
- [Close short 0.01 ETH, ETH collateral (part 1)](https://arbiscan.io/tx/0x3825aab5d7bbfac2b68f75c77c1ff55e684496844a8dd605dc43a1348efceb22)
- [Close short 0.01 ETH, ETH collateral (part 2)](https://arbiscan.io/tx/0x8ade23d7ad7ee6fb589a0d04724ee8c64f20e92e32688739e0c049b510c690f0)
- [Short ETH 10 USDC 100x (part 1)](https://arbiscan.io/tx/0x0a7b404d5f3c8c5f2cedd2c452d81840bef1b89f583e4e1a80f4cc2930ddad42)
- [Short ETH 10 USDC 100x (part 2)](https://arbiscan.io/tx/0x7fa1c583e2363ed1013035a33305f79571c760f713bed8065fe24b24e5b739d2)
- [Close ETH 10 USDC 100x (part 1)](https://arbiscan.io/tx/0xc3357725621993a02203d945a52120fdf7172075c372687d917d2b1593a3e3d4)
- [Close ETH 10 USDC 100x (part 2)](https://arbiscan.io/tx/0x8af4c27645b313be8a71cd38a10957e12d7fcd7653dd0de32353b67a0a0fef32)
- [Long ETH 0.005 ETH 10x SL + TP (part 1)](https://arbiscan.io/tx/0xffa7b6142f69d42565acaf36a8dd101cc8fc5b9d1c251d93eea5501b9d4b88d3)
- [Long ETH 0.005 ETH 10x SL + TP (part 2)](https://arbiscan.io/tx/0xbc053961d45b116f305fed005bd1ec7d4ebb6215946ba7d4db27e2eb75b10828)
- [Long ETH 0.005 ETH 10x SL + TP (part 3)](https://arbiscan.io/tx/0xa8c6f918e2478e3b1e0e9ff43b088f4f371505b39fce7b38fe49cb30ab0e565a)
- [Long ETH 0.005 ETH 10x SL + TP (part 4)](https://arbiscan.io/tx/0xa8c6f918e2478e3b1e0e9ff43b088f4f371505b39fce7b38fe49cb30ab0e565a)
- [Claim funding fees](https://arbiscan.io/tx/0x4415830b1a12882409df17e80be26da8c20e4cc929f1764046ca3aae3ca8339e)
- [Long ETH 0.001 75x ~ $190 part 1](https://arbiscan.io/tx/0xcac1ce9014aafcd3d8ae89c27cfd4866de36ff010ded5344a65bd4034d358413)
- [Long ETH 0.001 75x ~ $190 part 2](https://arbiscan.io/tx/0x29d95557ef789fd6d9031c739a29dd5adc112f3ff8aab0524cd6aa9ddfc4e278)
- [Long ETH 0.001 75x ~ close part 3](https://arbiscan.io/tx/0x13cdef0acc7d4017f82df308f0f628996b707396182fc2a2042e78b0ebc4657d)
- [Long ETH 0.001 75x ~ close part 4](https://arbiscan.io/tx/0xf5f5d293ef7bdc6893941cda6a6fd57d67a20876a175aa1e424af9442868bb47)
- [Limit order swap 2.63 USDC to ETH at $2780 (part 1)](https://arbiscan.io/tx/0x5a55b926aadaa832a42c55a4a60b0008193c773767e7289cdeb7eca0e1433595)
- [Limit order swap 2.63 USDC to ETH at $2780 (part 2)](https://arbiscan.io/tx/0x2306c6c8300a10a4e59c6dcc04513c84c0d2469172beb5c8f9cf1820eba308d0)
- [Long ETH 0.01 2x ~ $54.57 TP $2760 50% SL $2680 50%](?)
- [Close short WETH 0.009 (part 1)](https://arbiscan.io/tx/0x53c1b3734b7886f457909f2d785cb62b291be6ba56c79b1bd397371d4d2b44a9)
- [Close short WETH 0.009 (part 2)](https://arbiscan.io/tx/0x4c2c254c93caaffd6d4cdeba0018aeb98f4fcbfe3862102560c426e5a2b62b05)
- [Short ETH 0.01 ~ TP $2200 SL $2260 part 1](https://arbiscan.io/tx/0xfb4a9ddd2b80a4e7f739c0281a3869d89ee3cb96fe796446511098eb917016a4)]
- [Short ETH 0.01 ~ TP $2200 SL $2260 part 2](https://arbiscan.io/tx/0x9a32d9750bc14d77756ab9ebae1141c2b4845f44cdf2091fc74b7df174b32887)

##### Contracts

- [GLV WETH-USDC](https://arbiscan.io/address/0x528a5bac7e746c9a509a1f4f6df58a03d44279f9)
- [GLV WBTC-USDC](https://arbiscan.io/address/0xdf03eed325b82bc1d4db8b49c30ecc9e05104b96)
- [MarketToken - GM market (WBTC / USDC)](https://arbiscan.io/address/0x47c031236e19d024b42f8ae6780e44a573170703)
- [MarketToken (WBTC / USDC)](https://arbiscan.io/address/0x467c4a46287f6c4918ddf780d4fd7b46419c2291)
- [MarketToken (WBTC / USDC)](https://arbiscan.io/address/0x70d95587d40a2caf56bd97485ab3eec10bee6336)
- [MarketToken WBTC?](https://arbiscan.io/address/0x7c11f78ce78768518d743e81fdfa2f860c6b9a77)

##### Perpetual

- [What Are Binance Perpetual Futures Contracts ｜Explained for beginners](https://www.youtube.com/watch?v=H7Irc5jSk0A)
- [What is a Perpetual Contract in Crypto?](https://www.youtube.com/watch?v=NAlXsnbcxIY)
- [What Are Perpetual Contracts and How Funding Rates Work | dYdX Academy](https://www.youtube.com/watch?v=MMjR_LRhfK0)
- [What Are Crypto Derivatives? (Perpetual, Futures Contract Explained)](https://www.youtube.com/watch?v=5vW7hX6k5ho)
- [Bitcoin Derivatives: Perpetual Swaps 101](https://www.youtube.com/watch?v=wfx78LWd3PM)
- [Short VS Long Squeeze: Trading Traps EXPLAINED](https://www.youtube.com/watch?v=2ZblGdw1y-s)
- [dYdX - Perpetual Futures Example](https://www.youtube.com/watch?v=V3sKCP-4FJ4)
- [Forwards and Futures Contracts](https://www.youtube.com/playlist?list=PLSXINdSn1dzXcrlZkoFHVfJzWEjInzoQe)
- [GMX V2: A Guide for Traders and Liquidity Providers](https://www.youtube.com/watch?v=6PEn6iEuFGA)
- [Perps Hackathon Workshop 2a - Mathematical Modeling for Perpetual Swap Exchanges](https://www.youtube.com/watch?v=YIGsc8X_LH8)
- [Perps Hackathon Workshop 3a - risk management](https://www.youtube.com/watch?v=sKL8sgF3_co&list=PLFEm8se77ryMielAM_RuyMSQVrum9CN5S)
- [The Cartoon Guide to Perps](https://www.paradigm.xyz/2021/03/the-cartoon-guide-to-perps)

### TODO: questions to answer

- [x] perpetual contract -> who is the counter party -> GMX
- [x] where does profit / loss come from?
      -> peer to pool trades (<- liquidity provider)
- funding rate mechanism
  - is it price at every 8 hours or accumulated every second?
  - how is payment settled?
- what is the price of perpetual contract?
- how is leverage possible? -> position size USD / collateral USD
- where are the tokens stored? -> market token
- [x] why longs pay shorts when long interest exceeds short interest
  - price up -> demand to open long -> pay premium to shors
- why loss on short when leverage is high and index < open price?
- difference between ETH/USD and ETH market / pool
- difference between BTC/USDC and BTC GM pool
- how is profit fully backed?
  > For example, if there is 1000 ETH and 1 million USDC in the pool and the max long open interest is limited to 900 ETH and the max short open interest is limited to be 900k USDC, then all profits can always be fully backed regardless of the price of ETH.
- why borrowing fee = open interest \* cumulative borrowing
- how LP token price is calculated
- swap calculation for long -> market and short -> market
- how is funding fee calculated?
- what is price impact pool?
- what is position size?
- what is reserve factor?
  -> reserveUSD represents the total value of tokens reserved in USD terms for open positions.
- what is virtual inventory
- crossover
  -> a crossover in balance is for example if the long open interest is larger
  than the short open interest, and a short position is opened such that the
  short open interest becomes larger than the long open interest
- why clear price after order? -> price is set for each execution of order
- why reserve must be below threshold?
- TODO: graph execution price?
- why market index token set to EOA? synthetic assets
- what is an atomic provider?
- how to get GMX dao token? -> stake GMX

- [GMX delegatees](https://www.tally.xyz/gov/gmx/delegates)
- [Chainlink providers](https://docs.chain.link/data-feeds/price-feeds/addresses?network=arbitrum&page=1)
- [ABI ninja](https://abi.ninja)

##### TODO

- remove / clean notes
