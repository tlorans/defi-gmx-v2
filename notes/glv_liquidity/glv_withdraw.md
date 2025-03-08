# GLV withdraw

### Create withdrawal

```
1. Send GLV token to GLV vault
2. Send execution fee to GLV vault
3. Create withdrawal order

GlvRouter.createGlvWithdrawal
└ GlvHandler.createGlvWithdrawal
    └ GlvWithdrawalUtils.createGlvWithdrawal
        ├ GlvVault.recordTransferIn
        └ GGlvWithdrawalStoreUtils.set
```

### Execute withdrawal

```
GlvHandler
└ executeGlvWithdrawal
    ├ GlvDepositStoreUtils.get
    └ _executeGlvWithdrawal
        └ GlvWithdrawalUtils.executeGlvWithdrawal
            ├ GlvWithdrawalStoreUtils.remove
            └ _processMarketWithdrawal
               ├ Glv.transferOut
               └ ExecuteWithdrawalUtils.executeWithdrawal
```
