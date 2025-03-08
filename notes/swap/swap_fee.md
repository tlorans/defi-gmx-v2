# Swap fee

`SwapPricingUtils.getSwapFees`

```
a = swap -> amount in
  = deposit -> ammount in
  = withdraw -> long and short amount out
f = fee factor (different for price impact and deposit, withdraw, swap, etc...)
u = UI fee factor

fee = f * a  + u * a
```
