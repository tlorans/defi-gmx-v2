# Market decrease

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
│     │  └─ DecreaseOrderUtils.processOrder
│     │     ├─ PositionStoeUtils.get
│     │     ├─ DecreasePositionUtils.decreasePosition
│     │     │  ├─ DecreasePositionCollateralUtils.processCollateral
│     │     │  ├─ PositionUtils.updateTotalBorrowing
│     │     │  ├─ PositionStoreUtils.set or remove
│     │     │  ├─ MarketUtils.applyDeltaToCollateralSum
│     │     │  ├─ PositionUtils.updateOpenInterest
│     │     │  └─ DecreasePositionSwapUtils.swapWithdrawnCollateralToPnlToken
│     │     └─ SwapUtils.swap
│     └─ GasUtils.payExecutionFee
└─ OracleModule.withOraclePrices
   └─ Oracle.clearAllPrices
```
