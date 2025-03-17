# Price impact

`SwapPricingUtils.getPriceImpactUsd`

`PricingUtils.getPriceImpactUsdForSameSideRebalance`

`PricingUtils.getPriceImpactUsdForCrossoverRebalance`

`MarketUtils.getPositionImpactPoolAmount`

`MarketUtils.getSwapImpactPoolAmount`

`MarketUtils.getPoolValueInfo`

[Graph - price impact](https://www.desmos.com/calculator/sykma4sbbb)

## Purpose

If an action (swap, long, short, deposit liquidity)

- Reduces imbalance = positive impact -> rebate
- Increases imbalance = negative impact -> extra fee

## Imbalance

```
Imbalance for long and short = long open interest - short open interest
Imbalance for deposit = ?
```

## Swap

```
Imbalance for swap = long tokens in pool USD - short tokens in pool USD
Positive impact -> bonus to amount out
Negative impact -> fee to amount in
```

[`SwapUtils._swap`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/swap/SwapUtils.sol#L271-L337)

[`SwapPricingUtils.getPriceImpactUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/SwapPricingUtils.sol#L109-L166)

## Long and short

```
Imbalance for long and short = long open interest - short open interest
Positive impact -> ?
Negative impact -> ?
```

[`PositionPricingUtil.getPriceImpactUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PositionPricingUtils.sol#L159-L182)
[`PositionUtils.getExecutionPriceForIncrease`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/PositionUtils.sol#L621-L714)
[`PositionUtils.getExecutionPriceForDecrease`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/PositionUtils.sol#L717-L790)

## Deposit liquidity

## Positions

### Impact pools

- Swap impact pool
  - Pay positive impact to user
  - Store negative impact from user
- Position impact pool
  - Pay positive impact to user
  - Store negative impact from user
  - Slowly released back to pool for LP to claim

### Same side

```
same side = long < short and next long < next short
            or
            long >= short and next long >= next short
```

### Cross over

```
cross over = not same side
```

### Price impact

```
d0 = initial imbalance
d1 = next imbalance
e = exponent factor

# same side
f = impact factor
same side price impact = d0 ^ e * f - d1 ^ e * f

# cross over
p = positive impact factor
n = negative impact factor

p <= n

cross over price impact = d0 ^ e * p - d1 ^ e * n
```

> Why exponents?

Makes price manipulation rapidly expensive

> Why positive impact factor must be <= negative impact factor

`MarketUtils.getAdjustedSwapImpactFactors`

If the positive impact factor is more than the negative impact factor, positions could be opened
and closed immediately for a profit if the difference is sufficient to cover the position fees

```
Example from graph

f_p = 0.3 > f_n = 0.1
x0 = 2, x1 = 1, -> p = 0.9
x0 = 1, x1 = 2  -> p = -0.3
0.9 - 0.3 = 0.6

f_p = 0.3 < f_n = 2
x0 = 2, x1 = 1, -> p = 0.9
x0 = 1, x1 = 2  -> p = -6
0.9 - 6 = -5.1
```
