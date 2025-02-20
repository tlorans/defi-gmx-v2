// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {IDataStore} from "../src/interfaces/IDataStore.sol";
import {
    WETH,
    DAI,
    USDC,
    DATA_STORE,
    CHAINLINK_DATA_STREAM_PROVIDER
} from "../src/Constants.sol";
import "../src/lib/Keys.sol";

contract Dev is Test {
    IChainlinkDataStreamProvider provider;

    function setUp() public {
        provider = IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);
    }

    function get(address token) internal view returns (uint256) {
        address addr =
            IDataStore(DATA_STORE).getAddress(Keys.priceFeedKey(token));
        console.log("addr: ", addr);
        return
            IDataStore(DATA_STORE).getUint(Keys.priceFeedMultiplierKey(token));
    }

    function test() public {
        {
            uint256 m = get(DAI);
            console.log("DAI %e", m);
        }
        {
            uint256 m = get(USDC);
            console.log("USDC %e", m);
        }
        {
            uint256 m = get(WETH);
            console.log("WETH %e", m);
        }

        return;
        address token = address(1);
        bytes memory data = "";

        vm.mockCall(
            address(provider),
            abi.encodeCall(
                IChainlinkDataStreamProvider.getOraclePrice, (token, data)
            ),
            abi.encode(
                OracleUtils.ValidatedPrice({
                    token: token,
                    // 1e12 = 1 USD
                    min: 1,
                    max: 100,
                    timestamp: 99,
                    provider: address(provider)
                })
            )
        );

        address oracle = provider.oracle();
        console.log("oracle", oracle);

        OracleUtils.ValidatedPrice memory res =
            provider.getOraclePrice(token, data);
        console.log("min", res.min);
        console.log("max", res.max);
    }
}
