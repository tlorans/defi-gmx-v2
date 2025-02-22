# Position

```
long
    // for long positions, pnl is calculated as:
    // (position.sizeInTokens * indexTokenPrice) - position.sizeInUsd

short
    // for short positions, pnl is calculated as:
    // position.sizeInUsd -  (position.sizeInTokens * indexTokenPrice)
```

```
size delta USD = size delta long token amount x index price (long token price)?
               = collateral x collateral price x leverage - fees (30 decimals)
```
