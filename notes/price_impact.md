If a trade:

- Reduce Skew = Positive Impact
- Increase Skew = Negative Impact

```
imbalance = long USD - short USD

price impact =
  (initial imbalance) ^ (price impact exponent) * (price impact factor / 2)
- (next imbalance) ^ (price impact exponent) * (price impact factor / 2)
```

https://www.desmos.com/calculator/zx48kftgxw

https://www.desmos.com/calculator/fywgtpxsci

```
is same side = (token A USD <= token B USD) == (next token A USD <= next token B USD)
             =    long 0 <= short 0 and long 1 <= short 1
               or long 0 >  short 0 and long 1 >  short 1

```
