```shell
cp .env.sample .env

# memo
cast block-number --rpc-url $FORK_URL

forge test --fork-url $FORK_URL --fork-block-number 307946258 --match-path test/Swap.test.sol -vvv
```
