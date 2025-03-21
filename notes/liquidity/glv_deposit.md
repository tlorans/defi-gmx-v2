# GLV deposit

### Create deposit

```
1. Send tokens to deposit GLV vault
2. Send execution fee to GLV vault
3. Create deposit order

GlvRouter.createGlvDeposit
└ GlvHandler.createGlvDeposit
    └ GlvDepositUtils.createGlvDeposit
        ├ GlvVault.recordTransferIn
        ├ GlvVault.recordTransferIn
        ├ GlvVault.recordTransferIn
        └ GlvDepositStoreUtils.set
```

### Execute deposit

```
GlvHandler
└ executeGlvDeposit
    ├ GlvDepositStoreUtils.get
    └ _executeGlvDeposit
        └ GlvDepositUtils.executeGlvDeposit
            ├ GlvDepositStoreUtils.remove
            ├ _processMarketDeposit
            │  └ ExecuteDepositUtils.executeDeposit
            ├ _getMintAmount
            └ GlvToken.mint
```
