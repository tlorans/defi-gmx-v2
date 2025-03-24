# Long Position Exercises

In this exercise, you'll implement a smart contract that interacts with GMX V2 to create and manage leveraged long positions for ETH using WETH as collateral. This advanced exercise will cover opening positions, querying position details, calculating profit and loss, and closing positions.

You need to complete the implementation of the `Long.sol` contract.

This exercise consists of six tasks:

1. Implementing the `receive` function
2. Creating a long position
3. Getting the position key
4. Retrieving position details
5. Calculating position profit and loss
6. Closing a long position

## Task 1: Receive execution fee refund

Implement the `receive` function to accept ETH refunds from GMX.

## Task 2: Create a long position

Implement the `createLongOrder` function, which allows a user to open a leveraged long position on ETH using WETH as collateral

This function is broken down into three subtasks:

### Task 2.1: Send execution fee to the order vault

Send the execution fee (0.1 ETH) to the order vault.

### Task 2.2: Send WETH to the order vault

Approve and send WETH to the order vault.

### Task 2.3: Create a long order

Create a market increase order with the following requirements:

- Calculate the position size based on the leverage and WETH amount
  > Hints:
  >
  > - Get the current price of ETH from `oracle.getPrice(CHAINLINK_ETH_USD)`
  > - ETH price returned from this oracle has 8 decimals (1e8 = 1 USD)
  > - `sizeDeltaUsd` has 30 decimals (1e30 = 1 USD)
- Set `acceptablePrice` at 1% above current price of ETH
  > Hints:
  >
  > - When opening a long: set `acceptablePrice` higher than execution price
  > - When closing a long: set `acceptablePrice` lower than execution price
- Configure the order as a long position

## Task 3: Get position key

Implement the `getPositionKey` function to calculate the unique key for the position.

> Hint - Look for the function `Position.getPositionKey` inside [gmx-synthetics](https://github.com/gmx-io/gmx-synthetics)

## Task 4: Get position details

Implement the `getPosition` function to fetch the position details using the position key.

> Hint - Call the `reader` contract

## Task 5: Calculate position profit and loss

Implement the `getPositionPnlUsd` function to calculate the profit or loss of the position in USD

- `key` is the position key
- `ethPrice` is the price of ETH used to calculate the profit and loss. `ethPrice` has 8 decimals (1e8 = 1 USD).

> Hints:
>
> - Call `reader.getPositionPnlUsd`
> - Get the position identified by `key` and then retrieve `sizeInUsd`
> - For each prices in `MarketUtils.MarketPrices`, set the min price to -1% and max price to +1% of the current price of the token
> - `indexTokenPrice` for `MarketUtils.MarketPrices` is the price of `ETH`
> - `longTokenPrice` for `MarketUtils.MarketPrices` is the price of `ETH`
> - `shortTokenPrice` for `MarketUtils.MarketPrices` is the price of `USDC`
> - The prices above must have decimals so that when multiplied by the token decimals, it will have 30 decimals.
> - Assume 1 USDC = 1 USD

## Task 6: Close the long position

Implement the `createCloseOrder` function to close an existing long position.

This function is broken down into three subtasks:

### Task 6.1: Get position

Retrieve the current position details.

### Task 6.2: Send execution fee to the order vault

Send the execution fee to the order vault for the closing order.

### Task 6.3: Create a close order

Create a market decrease order to close the position with:

- The full size of the position
- Withdrawal all collateral
- `acceptablePrice` at 1% below current price of ETH
  > Hints:
  >
  > - Get the current price of ETH from `oracle.getPrice(CHAINLINK_ETH_USD)`
  > - When opening a long: set `acceptablePrice` higher than execution price
  > - When closing a long: set `acceptablePrice` lower than execution price

## Price calculations and decimals

When working with prices and calculations, be aware of the following:

- ETH price from Chainlink is in 8 decimals (1e8 = 1 USD)
- WETH has 18 decimals
- `sizeDeltaUsd` has 30 decimals (1e30 = 1 USD)
- `acceptablePrice` has 12 decimals (1e12 = 1 USD)

## Test

```shell
forge test --fork-url $FORK_URL --match-path test/Long.test.sol -vvv
```
