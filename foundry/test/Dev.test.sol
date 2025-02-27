// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {IDataStore} from "../src/interfaces/IDataStore.sol";
import {IReader} from "../src/interfaces/IReader.sol";
import {IGlvReader} from "../src/interfaces/IGlvReader.sol";
import "../src/Constants.sol";
import {Price} from "../src/types/Price.sol";
import {Market} from "../src/types/Market.sol";
import {Glv} from "../src/types/Glv.sol";
import {MarketPoolValueInfo} from "../src/types/MarketPoolValueInfo.sol";
import {Keys} from "../src/lib/Keys.sol";
import {Oracle} from "../src/lib/Oracle.sol";
import {MarketData} from "./lib/MarketData.sol";

contract Dev is Test {
    IReader constant reader = IReader(READER);
    IGlvReader constant glvReader = IGlvReader(GLV_READER);
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IChainlinkDataStreamProvider constant provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

    MarketData marketData = new MarketData();

    function getMarketKeys(uint256 start, uint256 end)
        internal
        view
        returns (address[] memory)
    {
        return dataStore.getAddressValuesAt(Keys.MARKET_LIST, start, end);
    }

    function logMarket(
        address market,
        address index,
        address long,
        address short
    ) private {
        MarketData.Info memory info = marketData.get(market);
        console.log("name:", info.name);
        console.log("market:", market);
        console.log("index:", index);
        console.log("long:", long);
        console.log("short:", short);
        console.log("index = EOA?", index.code.length == 0);
        if (info.oracle != address(0)) {
            console.log("oracle:", info.oracle);
        } else {
            console.log("no oracle");
        }
    }

    function test_glvTokens() public {
        IGlvReader.GlvInfo[] memory info =
            glvReader.getGlvInfoList(DATA_STORE, 0, 100);
        for (uint256 i = 0; i < info.length; i++) {
            for (uint256 j = 0; j < info[i].markets.length; j++) {
                address addr = info[i].markets[j];
                Market.Props memory market = reader.getMarket(DATA_STORE, addr);
                console.log("-------------", i, j);
                logMarket(
                    market.marketToken,
                    market.indexToken,
                    market.longToken,
                    market.shortToken
                );
            }
        }
    }

    function test_getMarketKeys() public {
        vm.skip(true);
        address[] memory keys = getMarketKeys(0, 100);
        for (uint256 i = 0; i < keys.length; i++) {
            console.log("key", i, keys[i]);
        }
    }

    function test_getMarketTokenPrice() public {
        vm.skip(true);
        (int256 p, MarketPoolValueInfo.Props memory info) = reader
            .getMarketTokenPrice({
            dataStore: DATA_STORE,
            market: Market.Props({
                marketToken: GM_TOKEN_BTC_WBTC_USDC,
                indexToken: GMX_BTC_WBTC_USDC_INDEX,
                longToken: WBTC,
                shortToken: USDC
            }),
            indexTokenPrice: Price.Props({
                min: 9.1725761563 * 1e26,
                max: 9.1725761563 * 1e26
            }),
            longTokenPrice: Price.Props({min: 9.1828 * 1e26, max: 9.1828 * 1e26}),
            shortTokenPrice: Price.Props({min: 9.9994 * 1e23, max: 9.9994 * 1e23}),
            pnlFactorType: PNL_FACTOR_TYPE_DEPOSIT,
            maximize: true
        });
        console.log("p %e", p);
    }
}
