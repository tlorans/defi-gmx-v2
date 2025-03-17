# Profit and loss

[`PositionUtils.getPositionPnlUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/PositionUtils.sol#L176-L233)

```
pnl = position pnl - fees +/- funding fee +/- price impact
```

```
Long
(position.sizeInTokens * indexTokenPrice) - position.sizeInUsd

Short
position.sizeInUsd - (position.sizeInTokens * indexTokenPrice)
```
