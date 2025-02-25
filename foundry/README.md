```shell
cp .env.sample .env

# memo
cast block-number --rpc-url $FORK_URL
FORK_BLOCK_NUM=

forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/Swap.test.sol -vvv --via-ir
```
