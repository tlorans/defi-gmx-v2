```shell
# Fill out environment variables inside .env
cp .env.sample .env

# Build exercises
forge build

# Build solutions
FOUNDRY_PROFILE=solution forge build

# Get block number
cast block-number --rpc-url $FORK_URL
FORK_BLOCK_NUM=

# Test exercise
forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/MarketSwap.test.sol -vvv

# Test solution
FOUNDRY_PROFILE=solution forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/MarketSwap.test.sol -vvv
```
