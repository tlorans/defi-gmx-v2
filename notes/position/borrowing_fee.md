# Borrowing fee

How is borrowing rate calculated?

```
PositionUtils.updateFundingAndBorrowingState
└ MarketUtils.updateCumulativeBorrowingFactor
    └ getNextCumulativeBorrowingFactor
        ├ getSecondsSinceCumulativeBorrowingFactorUpdated
        ├ getBorrowingFactorPerSecond
        │  ├ getReservedUsd
        │  ├ getPoolUsdWithoutPnl
        │  ├ if optimal usage factor != 0
        │  │  └ getKinkBorrowingFactor
        │  ├ getBorrowingExponentFactor
        │  └ getBorrowingFactor
        ├ getCumulativeBorrowingFactor
        └ incrementCumulativeBorrowingFactor
```

How is borrowing fee calculated for trader?

`MarketUtils.getBorrowingFees`

```solidity
function getBorrowingFees(DataStore dataStore, Position.Props memory position) internal view returns (uint256) {
    uint256 cumulativeBorrowingFactor = getCumulativeBorrowingFactor(dataStore, position.market(), position.isLong());
    if (position.borrowingFactor() > cumulativeBorrowingFactor) {
        revert Errors.UnexpectedBorrowingFactor(position.borrowingFactor(), cumulativeBorrowingFactor);
    }
    uint256 diffFactor = cumulativeBorrowingFactor - position.borrowingFactor();
    return Precision.applyFactor(position.sizeInUsd(), diffFactor);
}
```

How is borrowing updated for trader? -> increase / decrease position -> increase pool amount

```
ExecuteOrderUtils.executeOrder
├ PositionUtils.updateFundingAndBorrowingState
└ processOrder
    └ IncreaseOrderUtils.processOrder
        └ IncreasePositionUtils.increasePosition
            ├ processCollateral
            │   ├ PositionPricingUtils.getPositionFees
            │   │  └ MarketUtils.getBorrowingFees
            │   └ MarketUtils.applyDeltaToPoolAmount
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
            └ params.position.setBorrowingFactor
```

How is borrowing claimed by LP? -> claim from increased pool amount
