# Liquidation

```shell
LiquidationHandler.executeLiquidation
├─ LiquidationUtils.createLiquidationOrder
│  ├─ PositionStoreUtils.get
│  └─ OrderStoreUtils.set
└─ ExecuteOrderUtils.executeOrder
   ├─ OrderStoreUtils.remove
   └─ processOrder
      └─ DecreaseOrderUtils.processOrder
         ├─ PositionStoreUtils.get
         ├─ DecreasePositionUtils.decreasePosition
         │  ├─ PositionUtils.isPositionLiquidatable TODO
         │  └─ DecreasePositionCollateralUtils.processCollateral TODO
         └─ MarketToken.transferOut TODO
```

Is position liquidatable?

`PositionUtils.isPositionLiquidatable`

```
liquidatable if
remaining collateral < min collateral USD
or
remaining collateral <= 0
or
remaining collateral < min collateral factor x position size in USD

remaining collateral = collateral USD + position Pnl USD + price impact USD - collateral cost USD

position Pnl USD = long  -> position size in tokens * price - position size in USD
                   short -> position size in USD - position size in tokens * price

price impact USD = max(0, price impact if position was fully closed)

collateral cost USD = position cost in collateral * collateral price

position cost in collateral = position fee + borrowing fee + liquidation fee + UI fee - discount + funding fee
position fee = position size x position fee factor
borrowing fee = depends on market and time in position
liquidation fee = position size x liquidation fee factor
ui fee = position size x UI fee factor
discount = pro tier, referral discounts
funding fee = TODO
```

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
