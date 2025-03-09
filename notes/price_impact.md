# Price impact

TODO: virtual inventory

`SwapPricingUtils.getPriceImpactUsd`

`PricingUtils.getPriceImpactUsdForSameSideRebalance`

`PricingUtils.getPriceImpactUsdForCrossoverRebalance`

[Graph - price impact](https://www.desmos.com/calculator/sykma4sbbb)

### Imbalance

```
imbalance = swap = long tokens in pool USD - short tokens in pool USD
          = long and short = long open interest - short open interes
```

If an action (swap, long, short, deposit)

- Reduces imbalance = positive impact
- Increases imbalance = negative impact

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
