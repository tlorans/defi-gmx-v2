```shell
# Fill out environment variables inside .env
cp .env.sample .env

# Build exercises
forge build

# Build solutions
FOUNDRY_PROFILE=solution forge build

# Get block number
FORK_BLOCK_NUM=$(cast block-number --rpc-url $FORK_URL)

# Test exercise
forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/MarketSwap.test.sol -vvv

# Test solution
FOUNDRY_PROFILE=solution forge test --fork-url $FORK_URL --fork-block-number $FORK_BLOCK_NUM --match-path test/MarketSwap.test.sol -vvv
```

### Simple test (for me)

```
source .env
forge create src/Ping.sol:Ping   --rpc-url $TENDERLY_RPC_URL   --private-key $PRIVATE_KEY --broadcast
```