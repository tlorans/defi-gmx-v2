# borrowing fee

TODO: how is borrowing calculated for trader?
TODO: how is borrowing updated for trader?
TODO: how is borrowing claimed by LP?

```
ExecuteOrderUtils
ExecuteDepositUtils
ExecuteWithdrawalUtils


            params.position.setBorrowingFactor(cache.nextPositionBorrowingFactor);

PositionUtils.updateFundingAndBorrowingState
   MarketUtils.updateCumulativeBorrowingFactor
      getNextCumulativeBorrowingFactor
         getSecondsSinceCumulativeBorrowingFactorUpdated
         getBorrowingFactorPerSecond
            getReservedUsd
            getPoolUsdWithoutPnl
            if optimal usage factor != 0
               getKinkBorrowingFactor
            getBorrowingExponentFactor
            getBorrowingFactor
         getCumulativeBorrowingFactor
      incrementCumulativeBorrowingFactor
   MarketUtils.updateCumulativeBorrowingFactor
```

```solidity
    function getKinkBorrowingFactor(
        DataStore dataStore,
        Market.Props memory market,
        bool isLong,
        uint256 reservedUsd,
        uint256 poolUsd,
        uint256 optimalUsageFactor
    ) internal view returns (uint256) {
        uint256 usageFactor = getUsageFactor(
            dataStore,
            market,
            isLong,
            reservedUsd,
            poolUsd
        );

        uint256 baseBorrowingFactor = dataStore.getUint(Keys.baseBorrowingFactorKey(market.marketToken, isLong));

        uint256 borrowingFactorPerSecond = Precision.applyFactor(
            usageFactor,
            baseBorrowingFactor
        );

        if (usageFactor > optimalUsageFactor && Precision.FLOAT_PRECISION > optimalUsageFactor) {
            uint256 diff = usageFactor - optimalUsageFactor;

            uint256 aboveOptimalUsageBorrowingFactor = dataStore.getUint(Keys.aboveOptimalUsageBorrowingFactorKey(market.marketToken, isLong));
            uint256 additionalBorrowingFactorPerSecond;

            if (aboveOptimalUsageBorrowingFactor > baseBorrowingFactor) {
                additionalBorrowingFactorPerSecond = aboveOptimalUsageBorrowingFactor - baseBorrowingFactor;
            }

            uint256 divisor = Precision.FLOAT_PRECISION - optimalUsageFactor;

            borrowingFactorPerSecond += additionalBorrowingFactorPerSecond * diff / divisor;
        }

        return borrowingFactorPerSecond;
    }
```
