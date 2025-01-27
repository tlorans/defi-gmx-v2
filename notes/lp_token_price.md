# LP token price

`MarketUtils.getMarketTokenPrice`

```
LP token price = pool value USD / total market token supply

pool value USD = value of liquidity provider tokens in the pool - pending trader pnl
               = value of long + value of short - pnl

value of long = long amount in pool / divisor * long token price
value of short = short amount in pool / divisor * short token price
divisor = if long == short -> 2
          else             -> 1
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
