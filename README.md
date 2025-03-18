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
    - DAI, WETH, USDC, WBTC, decimals, AMM, etc..
    - Advanced Foundry
      - multicall
      - library (delegatecall)
  - Goals and expected outcomes
- [ ] Project setup
  - transaction links
  - exercises
    - types and library functions copied from gmx code
- [ ] UI - Quick guide on how to bridge ETH?
  - [ ] Transactions

### Foundation

- [ ] TODO: What is GMX?
  - Decentralized spot and perpetual exchange
  - Key features
    - 2 step transactions -> why?
    - 0 price impact?
    - Dynamic funding rate
    - Isolated pools
- [x] Terminologies and examples
  - [Perpetual swap](./notes/terms/perp.png)
    - Long
    - Short
  - [Leverage](./notes/terms/lev.png)
  - [Markets](./notes/terms/market.png)
    - Index
    - Long
    - Short
    - Synthetic asset
    - Both tokens are needed
  - [Liquidity provider](./notes/terms/lp.png)
  - [Position size](./notes/terms/pos.png)
  - [Liquidation](./notes/terms/liquidation.png)
    - Collateral
  - [Open interest](./notes/terms/open_interest.png)
  - [Funding fee](./notes/terms/funding_fee.png)
- [x] UI trade
  - 2 steps transaciton process
  - Markets (ETH / USD, WBTC / USD, etc...)
    - Index, long and short tokens
    - Fully backed
    - Synthetic
  - Long / Short / Swap
    - Swap
      - 2 step tx
      - Market
        - Market pools
          - Swap only pools
        - swap fee on amount in
        - execution fee
      - Limit
    - Market
      - Long
        - Open
          - 2 step tx
          - Pay, collateral
          - Pool
            - funding fee
            - open interest
          - Leverage
            - Liquidation price
          - price impact
          - fees
          - network fee
        - Close
          - profit in long asset
          - swap pnl
          - Profit and collateral can be swapped
          - Pool fees
            - open interest
          - Liquidation price
          - Price impact fee
          - Fees
          - Deposit / withdraw collateral
      - Short
        - Open
          - 2 step tx
          - profit in stablecoin?
          - Leverage
          - Pool fees
            - open interest
          - Liquidation price
          - Price impact fee
          - Fees
        - Close
          - Profit and collateral can be swapped
- [x] UI liquidity
  - Difference between GLV and GM
  - GM (GMX market) pools
  - GLV (GMX liquidity vault) pools
  - GM
    - Markets
      - index, long, short
      - swap only
    - Buy
      - Single and pair liquidity
      - Fees
      - Network fee
    - Sell
      - Pair liquidity
      - Fees
      - Network fee
    - Shift
  - GLV
    - BTC-USDC and WETH-USDC
    - Composition
    - Buy
    - Sell

### Contract architecture

- [ ] TODO: excalidraw - How the protocol works
  - Users (traders, LP (GM / GLV holders) and GMX holders, keepers)
  - Funding fees
  - Borrowing fees
  - Price impact
  - Where does profit / loss come from?
    - Default profit paid in long pos -> long token, short pos -> short token
  - Fee distribution
- [ ] TODO: excalidraw - Contract architecture
  - data store
  - bank / vault
  - router
    - ExchangeRouter
    - GlvRouter
  - handlers
  - utils (library)
  - even utils
  - market tokens
  - reader
  - oracle
  - keeper
  - wnt = wrapped native token
  - 2 step transcations
    - user -> create order
      - send execution fee
      - send tokens
      - create order
    - keeper -> execute order
      - execute order
      - send tokens
      - refund execution fee
  - multicall
  - execution fee
- [?] TODO: Code organization

### Trading

- [?] [Code - profit and loss](./notes/position/pnl.md)
- [x] [Graph - example strategies](https://www.desmos.com/calculator/ieq40vs9ve)
  - Long ETH, ETH collateral
  - Long ETH, USDC collateral
  - Short ETH, ETH collateral
  - Short ETH, USDC collateral
- Fees
  - [ ] Common fees
    - Execution fee
      - UI and transcations
    - [Price impact](./notes/price_impact.md)
      - Purpose
      - swap
      - open position
      - close position
      - deposit liquidity
      - impact pool
      - same side
      - cross over
      - [Graph - price impact](https://www.desmos.com/calculator/sykma4sbbb)
        - same side (long >= short)
        - positive / negative price impact
        - price impact negative -> rapid increase in fees
        - area of same side pos price impact >= area of cross over pos price impact
      - [Code - virtual inventory](./notes/virtual_inventory.md)
  - Swap
    - UI
      - Swap fee on amount in
      - Price impact
      - [Code](./notes/swap/swap_fees.md)
  - [Position](./notes/position/position_fees.md)
    - UI
    - [Deposit and withdrawal fees](./notes/swap/swap_fees.md)
    - Price impact
    - Borrowing fees
      - Purpose
      - [Math](./notes/position/borrowing_fee.png)
      - [How to updated borrowing fee](./notes/positions/borrowing_fee.md)
      - [Kink graph](https://www.desmos.com/calculator/9khv07nrfb)
    - Funding fees
      - UI claim (funding fees)
      - Purpose
      - [Math](./notes/positions/funding_fee.png)
      - [How to update and claim](./notes/position/funding_fee.md)
- [ ] Order types
  - Market swaps
  - Limit swaps
  - Market increase
  - Limit increase
  - Market decrease
  - Limit decrease
  - Stop loss decrease
- [ ] Contract calls (2 step tx - create order + execute order)
  - Swap
    - [Market swap](./notes/swap/swap.md)
      - [Token flow](./notes/execute_swap.png)
      - [tx - Swap DAI to ETH part 1](https://arbiscan.io/tx/0x747665f80ccd64918af4f4cd2d3c7e7c077d061d61bc47fc99f644d1eb4d18f4)
      - [tx - Swap DAI to ETH part 2](https://arbiscan.io/tx/0x98658391314497c36fe70a3104ae230fd592b7d67941858e08bd6d207142e9e9)
    - Limit swap
      - [tx - Limit order swap 2.63 USDC to ETH at $2780 part 1](https://arbiscan.io/tx/0x5a55b926aadaa832a42c55a4a60b0008193c773767e7289cdeb7eca0e1433595)
      - [tx - Limit order swap 2.63 USDC to ETH at $2780 part 2](https://arbiscan.io/tx/0x2306c6c8300a10a4e59c6dcc04513c84c0d2469172beb5c8f9cf1820eba308d0)
  - Long (open / close / deposit / withdraw)
    - UI limit, TP / SL, stop market
      - Auto cancel
      - Limit
        - Long -> create long position above limit
        - Short -> create short position below limit
      - TP / SL
        - Long
        - Short
      - Stop market
        - Long
        - Short
    - [Open](./notes/position/market_increase.md)
      - [tx - Long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0xcac1ce9014aafcd3d8ae89c27cfd4866de36ff010ded5344a65bd4034d358413)
        - `market`
        - `initialCollateralToken`
        - `swapPath`
        - `sizeDeltaUsd`
        - `executionFee`
        - `orderType`
      - [tx - Long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0x29d95557ef789fd6d9031c739a29dd5adc112f3ff8aab0524cd6aa9ddfc4e278)
        - `leverage = position size USD / collateral amount USD`
        - `initialCollateralDeltaAmount`
        - `swapPath`
    - [Close](./notes/position/market_decrease.md)
      - [tx - Close long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0x13cdef0acc7d4017f82df308f0f628996b707396182fc2a2042e78b0ebc4657d)
        - `sizeDeltaUsd`
        - `initialCollateralDeltaAmount`
        - `decreasePositionSwapType`
        - Default profit paid in long pos -> long token, short pos -> short token
      - [tx - Close long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0xf5f5d293ef7bdc6893941cda6a6fd57d67a20876a175aa1e424af9442868bb47)
  - Short (open / close / deposit / withdraw)
    - [tx - Short 0.01 ETH part 1](https://arbiscan.io/tx/0x15f4bb54997d8efbf0816313e64120fe5bf89ab31fe78f4a647f47b61b629eea)
    - [tx - Short 0.01 ETH part 2](https://arbiscan.io/tx/0x7039c81c3f14f54fbfb45c337fb13e4513b8e795a2d9237b66b2b191e717121e)
    - [tx - Close short 0.01 ETH part 1](https://arbiscan.io/tx/0x3825aab5d7bbfac2b68f75c77c1ff55e684496844a8dd605dc43a1348efceb22)
    - [tx - Close short 0.01 ETH part 2](https://arbiscan.io/tx/0x8ade23d7ad7ee6fb589a0d04724ee8c64f20e92e32688739e0c049b510c690f0)
  - TP and SL
    - UI limit, TP / SL, stop market TODO: move to later in the course
      - Auto cancel
    - [tx - Short ETH 0.01 ~ TP $2200 SL $2260 part 1](https://arbiscan.io/tx/0xfb4a9ddd2b80a4e7f739c0281a3869d89ee3cb96fe796446511098eb917016a4)]
      - `StopLossDecrease`
      - `LimitDecrease`
    - [tx - Short ETH 0.01 ~ TP $2200 SL $2260 part 2](https://arbiscan.io/tx/0x9a32d9750bc14d77756ab9ebae1141c2b4845f44cdf2091fc74b7df174b32887)
    - [tx - Take profit short ETH 0.01 ~ TP $2200 SL $2260](https://arbiscan.io/tx/0x612165df3da2fd87dc0b6c86e76b7d69a5900208da025a80ad275c1319a012c2)
      - `BaseOrderUtils.validateOrderTriggerPrice`
      - ` OrderUtils.clearAutoCancelOrders`
      - Auto cancel
  - [Claim funding fees](./notes/position/claim_funding_fees.md)
    - [tx - Claim funding fees](https://arbiscan.io/tx/0x4415830b1a12882409df17e80be26da8c20e4cc929f1764046ca3aae3ca8339e)
- [ ] Foundry exercises
  - Market swap
  - Limit swap
  - Long - open, close, deposit, withdraw
  - Short - open, close, deposit, withdraw
  - TP
  - SL
  - Claim funding fees

### Liquidation

- [ ] UI
  - leverage + liquidation price
- [ ] [When executed?](./notes/liquidation.md)
- Fees
- [ ] [Math - liquidation price](./notes/liq_price_approx.png)
  - UI demo
- [ ] [Contract calls](./notes/liquidation.md)
- [x] Foundry exercises? -> Not public function -> no exercise
- [ ] ADL

### Liquidity

- [ ] GM
  - [Token price](./notes/gm_liquidity/market_token_price.md)
  - Fees
- [ ] GLV
  - [Token pricing](./notes/glv_liquidity/glv_token_price.md)
  - Fees
- [ ] Contract calls
  - GM
    - [Mint](./notes/gm_liquidity/market_deposit.md)
      - [tx - Buy GM ETH/USD part 1](https://arbiscan.io/tx/0x6021800ad3d31003082fa6dc7fb5b6b8ff83208cadfcca98ffaa0774d6f652b8)
      - [tx - Buy GM ETH/USD part 2](https://arbiscan.io/tx/0x719b63dbef8d38006918c0e787b98a8373606b6147b77ae84a91fe2338132f4a)
    - [Burn](./notes/gm_liquidity/market_withdraw.md)
      - [tx - Sell GM ETH/USD part 1](https://arbiscan.io/tx/0xda4bc1d39be6ea85f8323875cbc4920aa33d0af38d7af2eb3f3dd03d174ae98e)
      - [tx - Sell GM ETH/USD part 2](https://arbiscan.io/tx/0xbdc46442f47149089f4976190a97c81bf476eb43b0478689e0ac918a9a502641)
    - [Shift](./notes/gm_liquidity/market_shift.md)
      - [tx - Shift ETH/USDC to LDO/USD part 1](https://arbiscan.io/tx/0xaa88b76cd39de8931bdfb3cce46984f634ecfe6ca88b40965191f9b05b50605d)
      - [tx - Shift ETH/USDC to LDO/USD part 2](https://arbiscan.io/tx/0x6b6db0a76a506b76c8cf517f59ca8a506b0f7e8e8f36f578a92ce7da0ddd38dc)
  - GLV
    - [Mint](./notes/glv_liquidity/glv_deposit.md)
      - [tx - Buy GLV part 1](https://arbiscan.io/tx/0x8d7d6e6b99fbeb095aeee4e495c528e4187bbabd0a3f728ef874f6b31bf73405)
      - [tx - Buy GLV part 2](https://arbiscan.io/tx/0x3cfcd9e1bdcc57a727dd66d6ed38afe78bbf3430015072078876240d183129f3)
    - [Burn](./notes/glv_liquidity/glv_withdraw.md)
      - [tx - Sell GLV part 1](https://arbiscan.io/tx/0xb60ed4fa2252dae32f8252f5702c3caf0cd2f074a9e9b41eaaaae2cea3f760c6)
      - [tx - Sell GLV part 2](https://arbiscan.io/tx/0x5120cf011c75d9b67bdffa99c4e3c6fffb5e8bb428f0080fc7ccded361bf98e6)
- [ ] Foundry exercises
  - GM - Buy, sell, shift
  - GLV - Buy, sell

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
- [ ] esGMX -> has historically been awarded as an incentive for GMX Staking -> TODO: skip?
  - [ ] UI?
    - Vest to convert esGMX to GMX
  - [ ] Foundry exercises?
- [ ] GLP (V1)
  - Quick explanation

### Application

- TODO: application

### Footnote

- 63 / 64 gas

### Transactions

Market swaps

- [Swap DAI to ETH part 1](https://arbiscan.io/tx/0x747665f80ccd64918af4f4cd2d3c7e7c077d061d61bc47fc99f644d1eb4d18f4)
- [Swap DAI to ETH part 2](https://arbiscan.io/tx/0x98658391314497c36fe70a3104ae230fd592b7d67941858e08bd6d207142e9e9)
- [Swap DAI to GMX part 1](https://arbiscan.io/tx/0x35572d81e52d1a2f254bcdeb30232e4fae9c4fc178f8b92240f9169951f70c36)
- [Swap DAI to GMX part 2](https://arbiscan.io/tx/0xb44af9795a4f728a3813aed7cafc7a66a5e4b6c12a2e1cfc3999be1ff960e9cd)

Limit swaps

- [Limit order swap 2.63 USDC to ETH at $2780 part 1](https://arbiscan.io/tx/0x5a55b926aadaa832a42c55a4a60b0008193c773767e7289cdeb7eca0e1433595)
- [Limit order swap 2.63 USDC to ETH at $2780 part 2](https://arbiscan.io/tx/0x2306c6c8300a10a4e59c6dcc04513c84c0d2469172beb5c8f9cf1820eba308d0)

Trades

- [Long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0xcac1ce9014aafcd3d8ae89c27cfd4866de36ff010ded5344a65bd4034d358413)
- [Long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0x29d95557ef789fd6d9031c739a29dd5adc112f3ff8aab0524cd6aa9ddfc4e278)
- [Close long ETH 0.001 70x ~ $190 part 1](https://arbiscan.io/tx/0x13cdef0acc7d4017f82df308f0f628996b707396182fc2a2042e78b0ebc4657d)
- [Close long ETH 0.001 70x ~ $190 part 2](https://arbiscan.io/tx/0xf5f5d293ef7bdc6893941cda6a6fd57d67a20876a175aa1e424af9442868bb47)

- [Short 0.01 ETH part 1](https://arbiscan.io/tx/0x15f4bb54997d8efbf0816313e64120fe5bf89ab31fe78f4a647f47b61b629eea)
- [Short 0.01 ETH part 2](https://arbiscan.io/tx/0x7039c81c3f14f54fbfb45c337fb13e4513b8e795a2d9237b66b2b191e717121e)
- [Close short 0.01 ETH part 1](https://arbiscan.io/tx/0x3825aab5d7bbfac2b68f75c77c1ff55e684496844a8dd605dc43a1348efceb22)
- [Close short 0.01 ETH part 2](https://arbiscan.io/tx/0x8ade23d7ad7ee6fb589a0d04724ee8c64f20e92e32688739e0c049b510c690f0)

- [Short ETH 10 USDC 100x part 1](https://arbiscan.io/tx/0x0a7b404d5f3c8c5f2cedd2c452d81840bef1b89f583e4e1a80f4cc2930ddad42)
- [Short ETH 10 USDC 100x part 2](https://arbiscan.io/tx/0x7fa1c583e2363ed1013035a33305f79571c760f713bed8065fe24b24e5b739d2)
- [Close short ETH 10 USDC 100x part 1](https://arbiscan.io/tx/0xc3357725621993a02203d945a52120fdf7172075c372687d917d2b1593a3e3d4)
- [Close short ETH 10 USDC 100x part 2](https://arbiscan.io/tx/0x8af4c27645b313be8a71cd38a10957e12d7fcd7653dd0de32353b67a0a0fef32)

- [Short ETH 0.01 ~ TP $2200 SL $2260 part 1](https://arbiscan.io/tx/0xfb4a9ddd2b80a4e7f739c0281a3869d89ee3cb96fe796446511098eb917016a4)]
- [Short ETH 0.01 ~ TP $2200 SL $2260 part 2](https://arbiscan.io/tx/0x9a32d9750bc14d77756ab9ebae1141c2b4845f44cdf2091fc74b7df174b32887)
- [Take profit short ETH 0.01 ~ TP $2200 SL $2260](https://arbiscan.io/tx/0x612165df3da2fd87dc0b6c86e76b7d69a5900208da025a80ad275c1319a012c2)

- [Claim funding fees](https://arbiscan.io/tx/0x4415830b1a12882409df17e80be26da8c20e4cc929f1764046ca3aae3ca8339e)

- [Long ETH 0.005 ETH 10x SL + TP (part 1)](https://arbiscan.io/tx/0xffa7b6142f69d42565acaf36a8dd101cc8fc5b9d1c251d93eea5501b9d4b88d3)
- [Long ETH 0.005 ETH 10x SL + TP (part 2)](https://arbiscan.io/tx/0xbc053961d45b116f305fed005bd1ec7d4ebb6215946ba7d4db27e2eb75b10828)
- [Long ETH 0.005 ETH 10x SL + TP (part 3)](https://arbiscan.io/tx/0xa8c6f918e2478e3b1e0e9ff43b088f4f371505b39fce7b38fe49cb30ab0e565a)
- [Long ETH 0.005 ETH 10x SL + TP (part 4)](https://arbiscan.io/tx/0xa8c6f918e2478e3b1e0e9ff43b088f4f371505b39fce7b38fe49cb30ab0e565a)

- [Long ETH 0.01 2x ~ $54.57 TP $2760 50% SL $2680 50%](?)
- [Close short WETH 0.009 (part 1)](https://arbiscan.io/tx/0x53c1b3734b7886f457909f2d785cb62b291be6ba56c79b1bd397371d4d2b44a9)
- [Close short WETH 0.009 (part 2)](https://arbiscan.io/tx/0x4c2c254c93caaffd6d4cdeba0018aeb98f4fcbfe3862102560c426e5a2b62b05)

- [Limit long 100x 0.0000534 WBTC part 1](https://arbiscan.io/tx/0xb6edf782be9db8b493b296c5231d7041961c080fc941dcb6f3ca59f207794023)
- [Limit long 100x 0.0000534 WBTC part 2](https://arbiscan.io/tx/0xf732ca126ef2582550bf7fcd0ef2a24f3d076d1456c4050b30974c7fc4d54cc3)

Liquidation

- [Liquidation](https://arbiscan.io/tx/0xa379337b09d07c3fa4c648b5c82567f83102a60f64693ef8106c6782a3791f14)

Liquidity

- [Buy GLV part 1](https://arbiscan.io/tx/0x8d7d6e6b99fbeb095aeee4e495c528e4187bbabd0a3f728ef874f6b31bf73405)
- [Buy GLV part 2](https://arbiscan.io/tx/0x3cfcd9e1bdcc57a727dd66d6ed38afe78bbf3430015072078876240d183129f3)
- [Sell GLV part 1](https://arbiscan.io/tx/0xb60ed4fa2252dae32f8252f5702c3caf0cd2f074a9e9b41eaaaae2cea3f760c6)
- [Sell GLV part 2](https://arbiscan.io/tx/0x5120cf011c75d9b67bdffa99c4e3c6fffb5e8bb428f0080fc7ccded361bf98e6)
- [Buy GM ETH/USD part 1](https://arbiscan.io/tx/0x6021800ad3d31003082fa6dc7fb5b6b8ff83208cadfcca98ffaa0774d6f652b8)
- [Buy GM ETH/USD part 2](https://arbiscan.io/tx/0x719b63dbef8d38006918c0e787b98a8373606b6147b77ae84a91fe2338132f4a)
- [Sell GM ETH/USD part 1](https://arbiscan.io/tx/0xda4bc1d39be6ea85f8323875cbc4920aa33d0af38d7af2eb3f3dd03d174ae98e)
- [Sell GM ETH/USD part 2](https://arbiscan.io/tx/0xbdc46442f47149089f4976190a97c81bf476eb43b0478689e0ac918a9a502641)
- [Buy BTC/USDC GLV part 1](https://arbiscan.io/tx/0x87ed238503646ef7d7045ce639efd59845db94384a00d37aedc174d52050eb83)
- [Buy BTC/USDC GLV part 2](https://arbiscan.io/tx/0x3f0c373aa132815204574ed7981c584d4f044eb2c00a160b7dd992822de66763)
- [Buy BTC/USDC GM part 1](https://arbiscan.io/tx/0xef88d101a155ffd16427fc78d50e6028d612c8bc1e8d46a7810d53882f705f91)
- [Buy BTC/USDC GM part 2](https://arbiscan.io/tx/0x54357ec00e44fa8d3d701368af4a3979a28dd2383b9eb5a3f299253e8ce217a1)
- [Sell BTC/USDC GM part 1](https://arbiscan.io/tx/0xae14c5e75e5f5e5669570fc8e4d288ce7e58aeaa49174f37c4a4588bc3d04aac)
- [Sell BTC/USDC GM part 2](https://arbiscan.io/tx/0xac64686c30e67f7eae3576be759dbaef774122601ebc0c15c8cf9001fb530627)
- [Shift ETH/USDC to LDO/USD part 1](https://arbiscan.io/tx/0xaa88b76cd39de8931bdfb3cce46984f634ecfe6ca88b40965191f9b05b50605d)
- [Shift ETH/USDC to LDO/USD part 2](https://arbiscan.io/tx/0x6b6db0a76a506b76c8cf517f59ca8a506b0f7e8e8f36f578a92ce7da0ddd38dc)

Stake

- [Stake GMX](https://arbiscan.io/tx/0x0ed2a66323713c2e78dd53750612f3e9bcc97f2f8c02633a433a413889142067)
- [Unstake GMX](https://arbiscan.io/tx/0x2bbfefc59c295349405a86b08f9bd68b020e49836e9775de74e442908732678f)
- [Claim rewards](https://arbiscan.io/tx/0x23f1f338dc2456cf476692f34ea00838a1e621f8fd2aff330927edf256de8b1d)
- [Delegate](https://arbiscan.io/tx/0x245404338a81a8faccddf6ad8e944928bac6b687db8d7e217e47fdde94abd84f)

### Links

##### GMX

- [GMX](https://gmx.io/)
- [GMX app](https://app.gmx.io/)
- [GMX doc](https://docs.gmx.io/docs/intro/)
- [GMX GitHub synthetics](https://github.com/gmx-io/gmx-synthetics)
- [GMX GitHub interface](https://github.com/gmx-io/gmx-interface/)
- [GMX delegatees](https://www.tally.xyz/gov/gmx/delegates)
- [Tenderly](https://tenderly.co)
- [Chainlink providers](https://docs.chain.link/data-feeds/price-feeds/addresses?network=arbitrum&page=1)
- [ABI ninja](https://abi.ninja)

##### Arbitrum

- [Arbitrum](https://arbitrum.io/)
- [Arbitrum bridge](https://bridge.arbitrum.io/)
- [Bridge DAI from ETH to Arbitrum One tx](https://etherscan.io/tx/0xb15ea04494164f2d1dd6a12222010c65f496190e69f6acd909d0b6c80fbf37cb)
- [Deposit ETH into Arbitrum One tx](https://etherscan.io/tx/0x1752e3449694e4c3d516093294f39a2a3576198db7d3af3975704b0a339bf4b1)

##### TODO

- remove / clean notes

- How is GLV rebalanced?

- DecreasePositionUtils
- DecreasePositionCollateralUtils.processCollateral
- ExchangeRouter.claimCollateral
- what is an atomic provider?
