If a trade:

- Reduce Skew = Positive Impact
- Increase Skew = Negative Impact

```
imbalance = long USD - short USD

price impact =
  (initial imbalance) ^ (price impact exponent) * (price impact factor / 2)
- (next imbalance) ^ (price impact exponent) * (price impact factor / 2)
```

https://www.desmos.com/calculator/sykma4sbbb

https://www.desmos.com/calculator/fywgtpxsci

```
is same side = (token A USD <= token B USD) == (next token A USD <= next token B USD)
             =    long 0 <= short 0 and long 1 <= short 1
               or long 0 >  short 0 and long 1 >  short 1

```

Why positive impact factor <= negative impact factor

```
if the positive impact factor is more than the negative impact factor, positions could be opened
and closed immediately for a profit if the difference is sufficient to cover the position fees

example from graph

f_p > f_n
x0 = 2, x1 = 1, -> p = 0.9
x0 = 1, x1 = 2  -> p = -0.3
0.9 - 0.3 = 0.6

f_p < f_n
x0 = 2, x1 = 1, -> p = 0.9
x0 = 1, x1 = 2  -> p = -6
0.9 - 6 = -5.1
```
