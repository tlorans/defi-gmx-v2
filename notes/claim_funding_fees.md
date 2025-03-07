# Claim funding fees

```
ExchangeRouter.claimFundingFees
└─ for loop for each market
   └─ MarketUtils.claimFundingFees
      ├─ Keys.claimableFundingAmountKey(market, token, account);
      ├─ DataStore.getUint(key)
      ├─ DataStore.setUint(key, 0)
      ├─ DataStore.decrementUint
      └─ MarketToken.transferOut
```

```
ExecuteOrderUtils.executeOrder
    PositionUtils.updateFundingAndBorrowingState (update funding fee)
       MarketUtils.updateFundingState
        applyDeltaToFundingFeeAmountPerSize
        applyDeltaToClaimableFundingAmountPerSize
    processOrder
       IncreaseOrderUtils.processOrder
          IncreasePositionUtils.increasePosition
             if position.sizeInUsd = 0 (set funding fee to latest for new position)
                position.setFundingFeeAmountPerSize
                position.setLongTokenClaimableFundingAmountPerSize
                position.setShortTokenClaimableFundingAmountPerSize
             processCollateral
                PositionPricingUtils.getPositionFees
                  MarketUtils.getFundingFeeAmountPerSize (get latest funding fees for position)
                  MarketUtils.getClaimableFundingAmountPerSize
                  MarketUtils.getClaimableFundingAmountPerSize
                  getFundingFees (calculate funding fees and claimable fees)
                      MarketUtils.getFundingAmount
                      MarketUtils.getFundingAmount
                      MarketUtils.getFundingAmount
             PositionUtils.incrementClaimableFundingAmount (store claimable funding fees)
                MarketUtils.incrementClaimableFundingAmount
             position.setFundingFeeAmountPerSize (update funding fees to latest)
             position.setLongTokenClaimableFundingAmountPerSize
             position.setShortTokenClaimableFundingAmountPerSize

DecreasePositionUtils.decreasePosition
   PositionUtils.incrementClaimableFundingAmount
      MarketUtils.incrementClaimableFundingAmount
```
