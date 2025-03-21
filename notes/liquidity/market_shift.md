# Market shift

### Create shift

```
1. Send GM token to shift vault
2. Send execution fee to shift vault
3. Create shift order

ExchangeRouter.createShift
└ ShiftHandler.createShift
    └ ShiftUtils.createShift
        ├ ShiftVault.recordTransferIn
        ├ ShiftVault.recordTransferIn
        └ ShiftStoreUtils.set
```

### Execute shift

```
ShiftHandler.executeShift
├ ShiftStoreUtils.get
└ _executeShift
    └ ShiftUtils.executeShift
        ├ ShiftStoreUtils.remove
        ├ ExecuteWithdrawalUtils.executeWithdrawal
        ├ ShiftVault.recordTransferIn
        ├ ShiftVault.recordTransferIn
        └ ExecuteDepositUtils.executeDeposit
```
