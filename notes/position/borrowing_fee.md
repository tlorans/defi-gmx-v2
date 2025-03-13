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

`MarketUtils.getBorrowingFactorPerSecond`

```
if optimal usage factor = 0
    e = borrowing exponent factor
    r = reserve USD
    P = pool USD
    b = borrowing factor
    r^e / P * b
```

`MarketUtils.getUsageFactor`

```
usage factor = max(reserve usage factor, open interest usage factor)
reserve usage factor = reserve usage / max reserve
max reserve = reserve factor * pool usd
open interest usage factor = open interest / max open interest
```

`MarketUtils.getKinkBorrowingFactor`

```
u = usage factor
u_o = optimal usage factor
b0 = base borrowing factor
b1 = above optimal usage borrowing factor

kink borrowing factor per second = b0 * u

if u > u_o
    kink borrowing factor per second += max(b1 - b0, 0) * (u - u_o) / (1 - u_o)
```

> How is borrowing fee calculated for trader?

`MarketUtils.getBorrowingFees`

`MarketUtils.getNextBorrowingFees`

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
