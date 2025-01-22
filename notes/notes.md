# [Buy BTC/USDC GM (part 1)](https://arbiscan.io/tx/0xef88d101a155ffd16427fc78d50e6028d612c8bc1e8d46a7810d53882f705f91)

0. `Sender -> ExchangeRouter.multicall, value = 0.000073825089 ETH`
1. `ExchangeRouter.sendWnt(receiver = DepositVault, amount = 0.000073825089 ETH)`
2. `ExchangeRouter.sendTokens(token = USDC, receiver = DepositVault, amount = 10 USDC)`
3. `ExchangeRouter.createDeposit`
   - `DepositHandler.createDeposit(params)`
     - `DepositUtils.createDeposit`
       - `DepositVault.recordTransferIn`
       - `DepositStoreUtils.set`

```
{
  "receiver": "0xd24cba75f7af6081bff9e6122f4054f32140f49e",
  "callbackContract": "0x0000000000000000000000000000000000000000",
  "uiFeeReceiver": "0xff00000000000000000000000000000000000001",
  "market": "0x47c031236e19d024b42f8ae6780e44a573170703",
  "initialLongToken": "0x2f2a2543b76a4166549f7aab2e75bef0aefc5b0f",
  "initialShortToken": "0xaf88d065e77c8cc2239327c5edb3a432268e5831",
  "longTokenSwapPath": [],
  "shortTokenSwapPath": [],
  "minMarketTokens": "4158804842790729588",
  "shouldUnwrapNativeToken": false,
  "executionFee": "73825089000000",
  "callbackGasLimit": "0"
}
```

- [ExchangeRouter](https://arbiscan.io/address/0x900173a66dbd345006c51fa35fa3ab760fcd843b)
- [Router](https://arbiscan.io/address/0x7452c558d45f8afc8c83dae62c3f8a5be19c71f6)
- [DepositVault](https://arbiscan.io/address/0xf89e77e8dc11691c9e8757e84aafbcd8a67d7a55)
- [DepositHandler](https://arbiscan.io/address/0xfe2df84627950a0fb98ead49c69a1de3f66867d6)
- [DepositUtils](https://arbiscan.io/address/0x5554b2055ab335b1f4c811bb98d1eb62a18d3dee)
- [DepositStoreUtils](https://arbiscan.io/address/0xb683491705eb8f27ed94b06baaf4d64fbb9baec)

# [Buy BTC/USDC GM (part 2)](https://arbiscan.io/tx/0x54357ec00e44fa8d3d701368af4a3979a28dd2383b9eb5a3f299253e8ce217a1)
