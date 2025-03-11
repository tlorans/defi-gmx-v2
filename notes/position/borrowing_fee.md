# Borrowing fee

- Paid from position holder (trader) to liquidity provider.
- Discourages a user opening equal longs / shorts and unnecessarily taking up capacity

> How is borrowing fee rate calculated?

`MarketUtils.updateCumulativeBorrowingFactor`

```
PositionUtils.updateFundingAndBorrowingState
└ MarketUtils.updateCumulativeBorrowingFactor
    ├ getNextCumulativeBorrowingFactor
    │    ├ getSecondsSinceCumulativeBorrowingFactorUpdated
    │    ├ getBorrowingFactorPerSecond
    │    │  ├ getOptimalUsageFactor
    │    │  ├ if optimal usage factor != 0
    │    │  │  └ getKinkBorrowingFactor
    │    │  │      └ getUsageFactor
    │    │  ├ getBorrowingExponentFactor
    │    │  └ getBorrowingFactor
    │    └ getCumulativeBorrowingFactor
    └ incrementCumulativeBorrowingFactor
```

> How is borrowing fee calculated for trader?

`MarketUtils.getBorrowingFees`

`MarketUtils.getTotalPendingBorrowingFees`

> How is borrowing fee updated for trader?

Increase or decrease in position increases pool amount

```
ExecuteOrderUtils.executeOrder
├ PositionUtils.updateFundingAndBorrowingState
└ processOrder
    └ IncreaseOrderUtils.processOrder
        └ IncreasePositionUtils.increasePosition
            ├ processCollateral
            │   ├ PositionPricingUtils.getPositionFees
            │   │  └ MarketUtils.getBorrowingFees
            │   ├ MarketUtils.applyDeltaToCollateralSum
            │   └ MarketUtils.applyDeltaToPoolAmount
            ├ params.position.setCollateralAmount
            ├ MarketUtils.getCumulativeBorrowingFactor
            ├ PositionUtils.updateTotalBorrowing
            └ params.position.setBorrowingFactor

ExecuteOrderUtils.executeOrder
├ PositionUtils.updateFundingAndBorrowingState
└ processOrder
    └ DecreaseOrderUtils.processOrder
        └ DecreasePositionUtils.decreasePosition
            ├ DecreasePositionCollateralUtils.processCollateral
            │   ├ PositionPricingUtils.getPositionFees
            │   │  └ MarketUtils.getBorrowingFees
            │   └ MarketUtils.applyDeltaToPoolAmount
            ├ MarketUtils.getCumulativeBorrowingFactor
            ├ PositionUtils.updateTotalBorrowing
            ├ params.position.setBorrowingFactor
            ├ params.position.setCollateralAmount
            └ MarketUtils.applyDeltaToCollateralSum
```

> How is borrowing claimed by LP?

Claim from increased pool amount
