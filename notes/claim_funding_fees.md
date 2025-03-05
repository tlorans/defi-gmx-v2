# Claim funding fees

```
ExchangeRouter.claimFundingFees
└─ for loop for each market
   └─ MarketUtils.claimFundingFees
      ├─ Keys.claimableFundingAmountKey(market, token, account);
      ├─ DataStore.getUint(key)
      ├─ DataStore.decrementUint
      └─ MarketToken.transferOut
```
