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

contract MarketData {
    // market, index, short and long token to chainlink
    mapping(address => address) public oracles;

    constructor() {
        // Markets
        oracles[GM_TOKEN_RENDER_WETH_USDC] = address(0);
        oracles[GM_TOKEN_SUI_WETH_USDC] = address(0);
        oracles[GM_TOKEN_APT_WETH_USDC] = address(0);
        oracles[GM_TOKEN_WLD_WETH_USDC] = address(0);
        oracles[GM_TOKEN_FET_WETH_USDC] = address(0);
        oracles[GM_TOKEN_TRX_WETH_USDC] = address(0);
        oracles[GM_TOKEN_TON_WETH_USDC] = address(0);
        oracles[GM_TOKEN_ONDO_WETH_USDC] = address(0);
        oracles[GM_TOKEN_EIGEN_WETH_USDC] = address(0);
        oracles[GM_TOKEN_KBONK_WETH_USDC] = address(0);
        oracles[GM_TOKEN_FARTCOIN_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_PENGU_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_VIRTUAL_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_BCH_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_KFLOKI_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_INJ_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_FIL_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_ICP_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_BOME_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_XLM_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_AI16Z_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_MSATS_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_MEME_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_MEW_WBTC_USDC] = address(0);
        oracles[GM_TOKEN_DYDX_WBTC_USDC] = address(0);

        oracles[GM_TOKEN_BTC_WBTC_USDC] = CHAINLINK_BTC_USD;
        oracles[GM_TOKEN_ETH_WETH_USDC] = CHAINLINK_ETH_USD;
        oracles[GM_TOKEN_XRP_WETH_USDC] = CHAINLINK_XRP_USD;
        oracles[GM_TOKEN_TRUMP_WETH_USDC] = CHAINLINK_TRUMP_USD;
        oracles[GM_TOKEN_DOGE_WETH_USDC] = CHAINLINK_DOGE_USD;
        oracles[GM_TOKEN_UNI_UNI_USDC] = CHAINLINK_UNI_USD;
        oracles[GM_TOKEN_BERA_WETH_USDC] = CHAINLINK_BERA_USD;
        oracles[GM_TOKEN_LTC_WETH_USDC] = CHAINLINK_LTC_USD;
        oracles[GM_TOKEN_NEAR_WETH_USDC] = CHAINLINK_NEAR_USD;
        oracles[GM_TOKEN_ENA_WETH_USDC] = CHAINLINK_ENA_USD;
        oracles[GM_TOKEN_MELANIA_WETH_USDC] = CHAINLINK_MELANIA_USD;
        oracles[GM_TOKEN_SEI_WETH_USDC] = CHAINLINK_SEI_USD;
        oracles[GM_TOKEN_LDO_WETH_USDC] = CHAINLINK_LDO_USD;
        oracles[GM_TOKEN_TAO_WBTC_USDC] = CHAINLINK_TAO_USD;
        oracles[GM_TOKEN_ATOM_WETH_USDC] = CHAINLINK_ATOM_USD;
        oracles[GM_TOKEN_DOT_WBTC_USDC] = CHAINLINK_DOT_USD;
        oracles[GM_TOKEN_POL_WETH_USDC] = CHAINLINK_POL_USD;
        oracles[GM_TOKEN_TIA_WETH_USDC] = CHAINLINK_TIA_USD;
        oracles[GM_TOKEN_STX_WBTC_USDC] = CHAINLINK_STX_USD;
        oracles[GM_TOKEN_KSHIB_WETH_USDC] = CHAINLINK_SHIB_USD;
        oracles[GM_TOKEN_ADA_WBTc_USDC] = CHAINLINK_ADA_USD;
        oracles[GM_TOKEN_ORDI_WBTC_USDC] = CHAINLINK_ORDI_USD;
    }
}

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

    // index, short and long token to chainlink
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
                marketToken: GM_TOKEN_BTC_WBTC_USDC,
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
