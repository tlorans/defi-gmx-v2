# Market deposit

### Create deposit

```
1. Send long and or short tokens to deposit vault
2. Send execution fee to deposit vault
3. Create deposit order

ExchangeRouter.createDeposit
└ DepositHandler.createDeposit
    └ DepositUtils.createDeposit
        ├ DepositVault.recordTransferIn
        ├ DepositVault.recordTransferIn
        └ DepositStoreUtils.set
```

### Execute deposit

```
DepositHandler.executeDeposit
├ DepositStoreUtils.get
└ _executeDeposit
    └ ExecuteDepositUtils.executeDeposit
        ├ DepositStoreUtils.remove
        ├ MarketUtils.distributePositionImpactPool
        ├ PositionUtils.updateFundingAndBorrowingState
        ├ swap
        │   └ SwapUtils.swap
        ├ swap
        │   └ SwapUtils.swap
        ├ _executeDeposit
        │   ├ MarketUtils.applyDeltaToPoolAmount
        │   └ MarketToken.mint
        └ _executeDeposit
            ├ MarketUtils.applyDeltaToPoolAmount
            └ MarketToken.mint
```
