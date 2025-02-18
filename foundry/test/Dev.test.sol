// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
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
        address oracle = provider.oracle();
        console.log("oracle", oracle);
    }
}
