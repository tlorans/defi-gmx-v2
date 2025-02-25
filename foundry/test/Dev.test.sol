// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {IDataStore} from "../src/interfaces/IDataStore.sol";
import {IReader} from "../src/interfaces/IReader.sol";
import {
    WETH,
    DAI,
    USDC,
    CHAINLINK_BTC_USD,
    READER,
    DATA_STORE,
    CHAINLINK_DATA_STREAM_PROVIDER,
    GM_TOKEN_WETH_USDC
} from "../src/Constants.sol";
import {Market} from "../src/types/Market.sol";
import "../src/lib/Keys.sol";
import {Oracle} from "../src/lib/Oracle.sol";

contract Dev is Test {
    IReader constant reader = IReader(READER);
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IChainlinkDataStreamProvider constant provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

    function test() public {
        Oracle oracle = new Oracle();
        uint256 p = oracle.getPrice(CHAINLINK_BTC_USD);
        console.log("p %e", p);
    }
}
