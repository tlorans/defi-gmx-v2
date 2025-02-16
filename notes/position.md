# Position

```
long
    // for long positions, pnl is calculated as:
    // (position.sizeInTokens * indexTokenPrice) - position.sizeInUsd

short
    // for short positions, pnl is calculated as:
    // position.sizeInUsd -  (position.sizeInTokens * indexTokenPrice)
```
