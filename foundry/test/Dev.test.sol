// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {
    WETH,
    DAI,
    USDC,
    CHAINLINK_DATA_STREAM_PROVIDER
} from "../src/Constants.sol";

contract Dev is Test {
    IChainlinkDataStreamProvider provider;

    function setUp() public {
        provider = IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);
    }

    function test() public {
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
