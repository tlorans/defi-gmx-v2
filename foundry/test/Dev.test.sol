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

contract Dev is Test {
    IReader constant reader = IReader(READER);
    IGlvReader constant glvReader = IGlvReader(GLV_READER);
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

    // token to chainlink
    mapping(address => address) private chainlinks;
    address[] public tokens;

    function set(address token) private {
        if (chainlinks[token] == address(0)) {
            console.log("Set", token);
            if (token == WETH) {
                chainlinks[token] = CHAINLINK_ETH_USD;
            }
            if (token == WBTC) {
                chainlinks[token] = CHAINLINK_WBTC_USD;
            }
            if (token == USDC) {
                chainlinks[token] = CHAINLINK_USDC_USD;
            }
            if (token == DAI) {
                chainlinks[token] = CHAINLINK_DAI_USD;
            }
            require(chainlinks[token] != address(0));
            tokens.push(token);
        }
    }

    function test_glvTokens() public {
        /*
        Market.Props[] memory markets = reader.getMarkets(DATA_STORE, 0, 200);
        for (uint256 i = 0; i < markets.length; i++) {

        }
        */
        IGlvReader.GlvInfo[] memory info =
            glvReader.getGlvInfoList(DATA_STORE, 0, 100);
        for (uint256 i = 0; i < info.length; i++) {
            for (uint256 j = 0; j < info[i].markets.length; j++) {
                address addr = info[i].markets[j];
                Market.Props memory market = reader.getMarket(DATA_STORE, addr);
                set(market.indexToken);
                set(market.longToken);
                set(market.shortToken);

                console.log("-------------", i, j);
                console.log("market", market.marketToken);
                console.log("index", market.indexToken);
                console.log("long", market.longToken);
                console.log("short", market.shortToken);
                console.log("index = EOA?", market.indexToken.code.length == 0);
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
                marketToken: GM_TOKEN_WBTC_USDC,
                indexToken: GMX_EOA_1,
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
