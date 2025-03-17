# Price impact

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
```

[`PositionPricingUtil.getPriceImpactUsd`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PositionPricingUtils.sol#L159-L182)

```
Long
  Positive impact -> lower entry price
  Negative impact -> higher entry price
Short
  Positive impact -> higher entry price
  Negative impact -> lower entry price
```

[`PositionUtils.getExecutionPriceForIncrease`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/PositionUtils.sol#L621-L714)

[`PositionUtils.getExecutionPriceForDecrease`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/position/PositionUtils.sol#L717-L790)

[`BaseOrderUtils.getExecutionPriceForDecrease`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/order/BaseOrderUtils.sol#L374-L389)

## Deposit liquidity

```
Imbalance for swap = long tokens in pool USD - short tokens in pool USD
Positive impact -> mint additional market token
Negative impact -> fees deducted from deposit amounts
```

[`ExecuteDepositUtils._executeDeposit`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/deposit/ExecuteDepositUtils.sol#L399-L486)

### Impact pools

- Swap impact pool
  - Pay positive impact to user
  - Store negative impact from user
- Position impact pool
  - Pay positive impact to user
  - Store negative impact from user
  - Slowly released back to pool for LP to claim

[`MarketUtils.getSwapImpactPoolAmount`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L843-L845)

[`MarketUtils.getPositionImpactPoolAmount`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L834-L836)

[`MarketUtils.getPendingPositionImpactPoolDistributionAmount`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L2509-L2532)

[`MarketUtils.distributePositionImpactPool`](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/market/MarketUtils.sol#L2473-L2497)

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

[Graph - price impact](https://www.desmos.com/calculator/sykma4sbbb)

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

[SwapPricingUtils.getPriceImpactUsd](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/SwapPricingUtils.sol#L109-L166)

[PositionPricingUtils.getPriceImpactUsd](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PositionPricingUtils.sol#L159-L182)

[PricingUtils.getPriceImpactUsdForSameSideRebalance](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PricingUtils.sol#L61-L77)

[PricingUtils.getPriceImpactUsdForCrossoverRebalance](https://github.com/gmx-io/gmx-synthetics/blob/caf3dd8b51ad9ad27b0a399f668e3016fd2c14df/contracts/pricing/PricingUtils.sol#L88-L102)

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
