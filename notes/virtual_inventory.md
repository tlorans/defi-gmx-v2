# Virtual inventory

Virtual inventory is to help prevent price manipulation.

For example, suppose we have WETH-USDC [WETH], WETH-USDC [AAVE] pools.

A user can split a swap from WETH to USDC across these pools and their price impact would be half, since price impact is based on imbalance within a pool.

Virtual inventory helps prevent this by recoding the imbalance across pools with the same long and short token

`MarketUtils.getVirtualInventoryForSwaps`

```
swap     -> market -> virtual market id key -> virtual market id -> virtual inventory for long and short tokens
position ->                                                      -> virtual inventory for index token
```

`SwapPricingUtils.getPriceImpact`

```
// note that the virtual pool for the long token / short token may be different across pools
// e.g. ETH/USDC, ETH/USDT would have USDC and USDT as the short tokens
// the short token amount is multiplied by the price of the token in the current pool, e.g. if the swap
// is for the ETH/USDC pool, the combined USDC and USDT short token amounts is multiplied by the price of
// USDC to calculate the price impact, this should be reasonable most of the time unless there is a
// large depeg of one of the tokens, in which case it may be necessary to remove that market from being a virtual
// market, removal of virtual markets may lead to incorrect virtual token accounting, the feature to correct for
// this can be added if needed
```
