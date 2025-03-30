# `Vault` Exercises

## Task 1: Implement `getSizeDeltaUsd`

## Test

```shell
forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/app/Vault.test.sol -vvv
```

## Integration test

Test all contracts (`Vault`, `Strategy` and `WithdrawCallback`).

```shell
forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/app/VaultAndStrategy.test.sol -vvv
```
