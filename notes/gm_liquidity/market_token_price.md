# Market token price

`MarketUtils.getMarketTokenPrice`

`MarketUtils.getPoolValueInfo`

```
LP token price = pool value USD / market token total supply

pool value USD = USD values of long + short + portion of pending borrowing fees - pnl - impact pool

value of long = long amount in pool / divisor * long token price
value of short = short amount in pool / divisor * short token price
divisor = if long == short -> 2
          else             -> 1
```
