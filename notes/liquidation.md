# Liquidation

PositionUtils.sol

```solidity
info.remainingCollateralUsd =
    cache.collateralUsd.toInt256()
    + cache.positionPnlUsd
    + cache.priceImpactUsd
    - collateralCostUsd.toInt256();

cache.minCollateralFactor = MarketUtils.getMinCollateralFactor(dataStore, market.marketToken);

// validate if (remaining collateral) / position.size is less than the min collateral factor (max leverage exceeded)
// this validation includes the position fee to be paid when closing the position
// i.e. if the position does not have sufficient collateral after closing fees it is considered a liquidatable position
info.minCollateralUsdForLeverage = Precision.applyFactor(position.sizeInUsd(), cache.minCollateralFactor).toInt256();

if (shouldValidateMinCollateralUsd) {
    info.minCollateralUsd = dataStore.getUint(Keys.MIN_COLLATERAL_USD).toInt256();
    if (info.remainingCollateralUsd < info.minCollateralUsd) {
        return (true, "min collateral", info);
    }
}

if (info.remainingCollateralUsd <= 0) {
    return (true, "< 0", info);
}

if (info.remainingCollateralUsd < info.minCollateralUsdForLeverage) {
    return (true, "min collateral for leverage", info);
}
```
