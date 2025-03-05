# Create order

```shell
ExchangeRouter.multicall
├─ ExchangerRouter.sendWnt
├─ ExchangeRouter.sendTokens
└─ ExchangeRouter.createOrder
   └─ OrderHandler.createOrder
      └─ OrderUtils.createOrder
         ├─ OrderVault.recordTransferIn
         ├─ OrderVault.recordTransferIn
         └─ OrderStoreUtils.set
```

# Execute order

```shell
OrderHandler.executeOrder
├─ OracleModule.withOraclePrices
│  └─ Oracle.setPrices
├─ OrderStoreUtils.get
├─ _executeOrder
│  └─ ExecuteOrderUtils.executeOrder
│     ├─ OrderStoreUtils.remove
│     ├─ MarketUtils.getMarketPrices
│     ├─ MarketUtils.distributePositionImpactPool TODO:
│     ├─ MarketUtils.updateFundingAndBorrowingState TODO:
│     ├─ processOrder
│     │  └─ SwapOrderUtils.processOrder
│     │     └─ SwapUtils.swap
│     │        ├─ OrderVault.transferOut
│     │        └─ for loop for each market in swap path
│     │           └─ _swap
│     │              ├─ Oracle.getPrimaryPrice
│     │              ├─ Oracle.getPrimaryPrice
│     │              ├─ SwapPricingUtils.getPriceImpactUsd TODO:
│     │              ├─ SwapPricingUtils.getSwapFees TODO:
│     │              ├─ MarketToken.transferOut
│     │              ├─ MarketUtils.applyDeltaToPoolAmount
│     │              │  └─ applyDeltaToVirtualInventoryForSwaps
│     │              └─ MarketUtils.applyDeltaToPoolAmount
│     │                 └─ applyDeltaToVirtualInventoryForSwaps
│     └─ GasUtils.payExecutionFee
└─ OracleModule.withOraclePrices
   └─ Oracle.clearAllPrices
```
