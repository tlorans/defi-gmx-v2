# Profit and loss

`PositionUtils.getPositionPnlUsd`

```
pnl = position pnl - fees +/- funding fee +/- price impact
```

```
Long
(position.sizeInTokens * indexTokenPrice) - position.sizeInUsd

Short
position.sizeInUsd -  (position.sizeInTokens * indexTokenPrice)
```
