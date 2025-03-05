# Market long

## Execute order

```shell
OrderHandler.executeOrder
├─ OracleModule.withOraclePrices
│  └─ Oracle.setPrices
├─ OrderStoreUtils.get
├─ _executeOrder
│  └─ ExecuteOrderUtils.executeOrder
│     ├─ OrderStoreUtils.remove
│     ├─ MarketUtils.getMarketPrices
│     ├─ MarketUtils.distributePositionImpactPool
│     ├─ PositionUtils.updateFundingAndBorrowingState
│     ├─ processOrder
│     │  └─ IncreaseOrderUtils.processOrder
│     │     ├─ SwapUtils.swap
│     │     ├─ PositionStoeUtils.get
│     │     └─ IncreasePositionUtils.increasePosition
│     │        ├─ processCollateral
│     │        │  ├─ PositionPricingUtils.getPositionFees
│     │        │  ├─ MarketUtils.applyDeltaToCollateralSum
│     │        │  └─ MarketUtils.applyDeltaToPoolAmount
│     │        ├─ MarketUtils.updateTotalBorrowing
│     │        ├─ PositionStoeUtils.set
│     │        └─ PositionUtils.updateOpenInterest
│     └─ GasUtils.payExecutionFee
└─ OracleModule.withOraclePrices
   └─ Oracle.clearAllPrices
```
