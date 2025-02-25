```
1e30 = 1 USD
USD = token amount * oracle price

# USDC example
token = 6 decimals
1 USDC = 0.998 USD

0.998 * 1e30 = 1e6 * oracle price
oracle price = 0.998 * 1e24

# ETH example
token = 18 decimals
1 ETH = 2700 USD

2700 * 1e30 = 1e18 * oracle price
oracle price = 2700 * 1e12
```

```
ChainlinkPriceFeedUtils.sol
formula for decimals for price feed multiplier: 60 - (external price feed decimals) - (token decimals)
```

why EOA for some tokens?

```
we're using a "synthetic" address for BTC markets (both single-sided and market backup by two tokens).
```
