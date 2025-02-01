# LP token price

`MarketUtils.getMarketTokenPrice`

```
LP token price = pool value USD / total market token supply

pool value USD = value of liquidity provider tokens in the pool + portion of pending borrowing fees - pending trader pnl - impact pool
               = value of long + value of short + portion of pending borrowing fees - pnl - impact pool

value of long = long amount in pool / divisor * long token price
value of short = short amount in pool / divisor * short token price
divisor = if long == short -> 2
          else             -> 1

pending borrowing fees = open interest * cumulative borrowing factor - total borrowing

next cumulative borrowing factor = cumulative borrowing factor + borrowing factor per sec * dt
borrowing factor per sec = linear + kink or exponential

open interest = sum of all position sizes for long/short side

total borrowing = sum of (position.size * position.borrowingFactor)

pending borrowing fee = (open interest * next cumulative borrowing factor) - total borrowing
```

long / short amount storage

```
dataStore.getUint(Keys.poolAmountKey(market.marketToken, token))

  function poolAmountKey(address market, address token) internal pure returns (bytes32) {
      return keccak256(abi.encode(
          POOL_AMOUNT,
          market,
          token));
  }

```
