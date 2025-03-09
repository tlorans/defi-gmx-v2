# Funding fee

Larger side pays smaller side

How is borrowing rate calculated?

How is borrowing fee updated for trader?

How is borrowing claimed by LP? -> claim from increased pool amount

`MarketUtils.getNextFundingAmountPerSize`

`MarketUtils.getNextFundingFactorPerSecond`

`funding usd = larger side open interest * funding per sec * dt from last update`

```
f = |o - s| ^ e / (o  + s)
Fi = funding increase factor per sec

if Fi = 0
   funding factor per sec = min(f * F_market, max funding factor per sec)


if is_skew_same_dir_as_funding
   if f > stable funding threshold
      increase funding rate
   else if f < decrease threshold
      decrease funding rate
else
   increase funding rate

if Fi > 0
   if funding rate increase
      funding factor per sec = prev funding factor per sec + f * Fi * dt

   if funding rate decrease
      if prev funding factor per sec <= Fd * dt
         funding factor per sec = +/- 1 (preserve prev sign)
      else
         funding factor per sec = +/- 1 (preserve prev sign) * (funding factor per sec - Fd * dt)

TODO: bound funding factor per sec

funding fee in USD per size = f * dt * size of larger side / size of smaller side
```

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

ExecuteOrderUtils.executeOrder
    PositionUtils.updateFundingAndBorrowingState (update funding fee)
       MarketUtils.updateFundingState
        applyDeltaToFundingFeeAmountPerSize
        applyDeltaToClaimableFundingAmountPerSize
    processOrder
       DecreasetOrderUtils.processOrder
          DecreasePositionUtils.decreasePosition
            DecreasePositionCollateralUtils.processCollateral
                PositionPricingUtils.getPositionFees
            PositionUtils.incrementClaimableFundingAmount
            position.setFundingFeeAmountPerSize
            position.setLongTokenClaimableFundingAmountPerSize
            position.setShortTokenClaimableFundingAmountPerSize
```
