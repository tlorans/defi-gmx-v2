# GM pools (GMX market pools)

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

- Fees from leverage and swaps

- Index price feed
- Long token - token backing long positions
- Short token - token backing short positions

### Example

Market: WETH-USDC

- Index price feed: ETH/USD
- Long token: WETH
- Short token: USDC

## Single token backed pools

Both long and short tokens are the same.

### Example

Market: BTC

- Index price feed: BTC/USD
- Long token: BTC
- Short token: BTC

# [Buy BTC/USDC GM (part 1)](https://arbiscan.io/tx/0xef88d101a155ffd16427fc78d50e6028d612c8bc1e8d46a7810d53882f705f91)

### Token transfers

1. User -> ExchangeRouter (10 USDC + 0.000073825089 ETH)
2. ExchangeRouter -> WETH (0.000073825089 ETH -> WETH)
3. ExchangeRouter -> DepositVault (0.000073825089 WETH)
4. ExchangeRouter -> DepositVault (10 USDC)

### Contract calls

```
- ExchangeRouter.sendWnt(receiver = DepositVault)
- ExchangeRouter.sendToken(receiver = DepositVault)
- ExchangeRouter.createDeposit(params)
    - DepositHandler.createDeposit
        - DepositUtils.createDeposit
            - DepositVault.recordTransferIn(long token)
            - DepositVault.recordTransferIn(short token)
            - DepositStoreUtils.set(deposit)
Returns:
key = 0x44b5190b0b9dd6a3d0aa40c1b4ff79ffece9f7c19e676438209d67d5c77fd49c
```

```
params: {
  "receiver": "0xd24cba75f7af6081bff9e6122f4054f32140f49e",
  "callbackContract": "0x0000000000000000000000000000000000000000",
  "uiFeeReceiver": "0xff00000000000000000000000000000000000001",
  "market": "0x47c031236e19d024b42f8ae6780e44a573170703",
  "initialLongToken": "0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f",
  "initialShortToken": "0xaf88d065e77c8cc2239327c5edb3a432268e5831",
  "longTokenSwapPath": [],
  "shortTokenSwapPath": [],
  "minMarketTokens": "4158804842790729588",
  "shouldUnwrapNativeToken": false,
  "executionFee": "73825089000000",
  "callbackGasLimit": "0"
}
```

# [Buy BTC/USDC GM (part 2)](https://arbiscan.io/tx/0x54357ec00e44fa8d3d701368af4a3979a28dd2383b9eb5a3f299253e8ce217a1)

### Token transfers

1. DepositVault -> MarketToken (10 USDC)
2. GMX Market -> User (4.201114891992751348 GM token)
3. DepositVault -> WETH (0.0000564727 WETH -> 0.0000564727 ETH)
4. DepositVault -> Keeper (0.0000564727 ETH)
5. DepositVault -> DepositHandler (0.000017352379 WETH)
6. DepositHandler -> WETH (0.000017352379 WETH -> 0.000017352379 ETH)
7. DepositHandler -> User (0.000017352379 ETH)

### Contract calls

```
- DepositHandler.executeDeposit(key)
    - DepositHandler.setPrices <- TODO: wat dis?
    - DepositStoreUtils.get(key)
    - ExecuteDepositUtils.executeDeposit
        - DepositStoreUtils.remove(key)
        - MarketUtils.getMarketPrices
        - MarketUtils.distributePositionImpactPool <- TODO: wat dis?
        - PositionUtils.updatefundingAndBorrowingState <- TODO: wat dis?
            - MarketUtils.updateFundingState
            - MarketUtils.updateCumulativeBorrowingFactor
        - MarketUtils.validateMaxPnL <- TODO: wat dis?
        - swap <- swap long to market
            - SwapUtils.swap
        - swap <- swap short to market
            - SwapUtils.swap
        - SwapPricingUtils.getPriceImpactUsd <- TODO: wat dis?
        - _executeDeposit
            - FeeUtils.incrementClaimableFeeAmount
            - FeeUtils.incrementClaimableFeeAmount
            - MarketToken.mint
        - _executeDeposit
            - FeeUtils.incrementClaimableFeeAmount
            - FeeUtils.incrementClaimableFeeAmount
            - MarketToken.mint
        - CallbackUtils.afterDepositExecution
        - GasUtils.payExecutionFee
```

```
key: 0x44b5190b0b9dd6a3d0aa40c1b4ff79ffece9f7c19e676438209d67d5c77fd49c
```

`MarketUtils.getPoolValueInfo`
