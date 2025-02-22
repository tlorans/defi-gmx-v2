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
    CHAINLINK_DATA_STREAM_PROVIDER,
    GM_TOKEN_WETH_USDC
} from "../src/Constants.sol";
import "../src/lib/Keys.sol";

contract Dev is Test {
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IChainlinkDataStreamProvider constant provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

    function getMinCollateralFactor(address market)
        internal
        view
        returns (uint256)
    {
        return dataStore.getUint(Keys.minCollateralFactorKey(market));
    }

    function test() public {
        uint256 f = getMinCollateralFactor(GM_TOKEN_WETH_USDC);
        console.log("f %e", f);
    }
}
