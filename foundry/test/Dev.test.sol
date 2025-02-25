// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {IDataStore} from "../src/interfaces/IDataStore.sol";
import {IReader} from "../src/interfaces/IReader.sol";
import "../src/Constants.sol";
import {Price} from "../src/types/Price.sol";
import {Market} from "../src/types/Market.sol";
import {MarketPoolValueInfo} from "../src/types/MarketPoolValueInfo.sol";
import {Keys} from "../src/lib/Keys.sol";
import {Oracle} from "../src/lib/Oracle.sol";

contract Dev is Test {
    IReader constant reader = IReader(READER);
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IChainlinkDataStreamProvider constant provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

    function getMarketKeys(uint256 start, uint256 end)
        internal
        view
        returns (address[] memory)
    {
        return dataStore.getAddressValuesAt(Keys.MARKET_LIST, start, end);
    }

    function test_getMarketKeys() public {
        vm.skip(true);
        address[] memory keys = getMarketKeys(0, 100);
        for (uint256 i = 0; i < keys.length; i++) {
            console.log("key", i, keys[i]);
        }
    }

    function test_getMarketTokenPrice() public {
        (int256 p, MarketPoolValueInfo.Props memory info) = reader
            .getMarketTokenPrice({
            dataStore: DATA_STORE,
            market: Market.Props({
                marketToken: GM_TOKEN_WBTC_USDC,
                indexToken: GMX_EOA_1,
                longToken: WBTC,
                shortToken: USDC
            }),
            indexTokenPrice: Price.Props({min: 1, max: 1}),
            longTokenPrice: Price.Props({min: 1, max: 1}),
            shortTokenPrice: Price.Props({min: 1, max: 1}),
            pnlFactorType: PNL_FACTOR_TYPE_DEPOSIT,
            maximize: true
        });
        console.log("p %e", p);
    }
}
