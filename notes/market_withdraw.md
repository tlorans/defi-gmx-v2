# market withdraw

### create withdrawal

```
1. Send market token to withdrawal vault
2. Send execution fee to withdrawal vault
3. Create withdrawal order

ExchangeRouter.createWithdrawal
└ WithdrawalHandler.createWithdrawal
    └ WithdrawalUtils.createWithdrawal
        ├ WithdrawalVault.recordTransferIn
        ├ WithdrawalVault.recordTransferIn
        └ WithdrawalStoreUtils.set
```

### execute withdrawal

```
WithdrawalHandler.executeWithdrawal
├ WithdrawalStoreUtils.get
└ _executeWithdrawal
    └ ExecuteWithdrawalUtils.executeWithdrawal
        ├ WithdrawalStoreUtils.remove
        ├ MarketUtils.distributePositionImpactPool
        ├ PositionUtils.updateFundingAndBorrowingState
        └ _executeWithdrawal
            ├ _getOutputAmounts
            │   ├ MarketUtils.getPoolAmount
            │   └ MarketUtils.getPoolAmount
            ├ MarketUtils.applyDeltaToPoolAmount
            ├ MarketUtils.applyDeltaToPoolAmount
            ├ MarketToken.burn
            ├ _swap
            │   └ SwapUtils.swap
            └ _swap
                └ SwapUtils.swap
```
