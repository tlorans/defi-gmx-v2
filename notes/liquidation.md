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

position Pnl USD = long  -> position size * price - position size in USD
                   short -> position size in USD - position size * price

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
