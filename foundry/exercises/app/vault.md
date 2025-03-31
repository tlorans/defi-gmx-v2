# `Vault` Exercises

## Task 1: Implement `deposit`

```solidity
function deposit(uint256 wethAmount)
    external
    guard
    returns (uint256 shares)
{}
```

This function will deposit WETH from `msg.sender` and mint shares.

- Call the function `strategy.claim` to claim funding fees

## Task 2: Implement `withdraw`

```solidity
function withdraw(uint256 shares)
    external
    payable
    guard
    returns (uint256 wethSent, bytes32 withdrawOrderKey)
{}
```

- Call the function `strategy.claim` to claim funding fees

## Task 3: Implement `cancelWithdrawOrder`

```solidity
function cancelWithdrawOrder(bytes32 key) external guard {}
```

## Task 4: Implement `removeWithdrawOrder`

```solidity
function removeWithdrawOrder(bytes32 key, bool ok) external auth {}
```

## Test

```shell
forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/app/Vault.test.sol -vvv
```

## Integration test

Test all contracts (`Vault`, `Strategy` and `WithdrawCallback`).

```shell
forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/app/VaultAndStrategy.test.sol -vvv
```
