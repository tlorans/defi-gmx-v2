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
    struct Info {
        string name;
        address oracle;
    }
    // market, index, short and long token to chainlink

    mapping(address => Info) public info;

    constructor() {
        // Short and long
        info[WETH] = Info("WETH", CHAINLINK_ETH_USD);
        info[WBTC] = Info("WBTC", CHAINLINK_BTC_USD);
        info[USDC] = Info("USDC", CHAINLINK_USDC_USD);
        info[DAI] = Info("DAI", CHAINLINK_DAI_USD);
        info[AAVE] = Info("AAVE", CHAINLINK_AAVE_USD);

        // Markets
        info[GM_TOKEN_RENDER_WETH_USDC] =
            Info("GM_TOKEN_RENDER_WETH_USDC", address(0));
        info[GM_TOKEN_SUI_WETH_USDC] =
            Info("GM_TOKEN_SUI_WETH_USDC", address(0));
        info[GM_TOKEN_APT_WETH_USDC] =
            Info("GM_TOKEN_APT_WETH_USDC", address(0));
        info[GM_TOKEN_WLD_WETH_USDC] =
            Info("GM_TOKEN_WLD_WETH_USDC", address(0));
        info[GM_TOKEN_FET_WETH_USDC] =
            Info("GM_TOKEN_FET_WETH_USDC", address(0));
        info[GM_TOKEN_TRX_WETH_USDC] =
            Info("GM_TOKEN_TRX_WETH_USDC", address(0));
        info[GM_TOKEN_TON_WETH_USDC] =
            Info("GM_TOKEN_TON_WETH_USDC", address(0));
        info[GM_TOKEN_ONDO_WETH_USDC] =
            Info("GM_TOKEN_ONDO_WETH_USDC", address(0));
        info[GM_TOKEN_EIGEN_WETH_USDC] =
            Info("GM_TOKEN_EIGEN_WETH_USDC", address(0));
        info[GM_TOKEN_KBONK_WETH_USDC] =
            Info("GM_TOKEN_KBONK_WETH_USDC", address(0));
        info[GM_TOKEN_FARTCOIN_WBTC_USDC] =
            Info("GM_TOKEN_FARTCOIN_WBTC_USDC", address(0));
        info[GM_TOKEN_PENGU_WBTC_USDC] =
            Info("GM_TOKEN_PENGU_WBTC_USDC", address(0));
        info[GM_TOKEN_VIRTUAL_WBTC_USDC] =
            Info("GM_TOKEN_VIRTUAL_WBTC_USDC", address(0));
        info[GM_TOKEN_BCH_WBTC_USDC] =
            Info("GM_TOKEN_BCH_WBTC_USDC", address(0));
        info[GM_TOKEN_KFLOKI_WBTC_USDC] =
            Info("GM_TOKEN_KFLOKI_WBTC_USDC", address(0));
        info[GM_TOKEN_INJ_WBTC_USDC] =
            Info("GM_TOKEN_INJ_WBTC_USDC", address(0));
        info[GM_TOKEN_FIL_WBTC_USDC] =
            Info("GM_TOKEN_FIL_WBTC_USDC", address(0));
        info[GM_TOKEN_ICP_WBTC_USDC] =
            Info("GM_TOKEN_ICP_WBTC_USDC", address(0));
        info[GM_TOKEN_BOME_WBTC_USDC] =
            Info("GM_TOKEN_BOME_WBTC_USDC", address(0));
        info[GM_TOKEN_XLM_WBTC_USDC] =
            Info("GM_TOKEN_XLM_WBTC_USDC", address(0));
        info[GM_TOKEN_AI16Z_WBTC_USDC] =
            Info("GM_TOKEN_AI16Z_WBTC_USDC", address(0));
        info[GM_TOKEN_MSATS_WBTC_USDC] =
            Info("GM_TOKEN_MSATS_WBTC_USDC", address(0));
        info[GM_TOKEN_MEME_WBTC_USDC] =
            Info("GM_TOKEN_MEME_WBTC_USDC", address(0));
        info[GM_TOKEN_MEW_WBTC_USDC] =
            Info("GM_TOKEN_MEW_WBTC_USDC", address(0));
        info[GM_TOKEN_DYDX_WBTC_USDC] =
            Info("GM_TOKEN_DYDX_WBTC_USDC", address(0));

        info[GM_TOKEN_BTC_WBTC_USDC] =
            Info("GM_TOKEN_BTC_WBTC_USDC", CHAINLINK_BTC_USD);
        info[GM_TOKEN_ETH_WETH_USDC] =
            Info("GM_TOKEN_ETH_WETH_USDC", CHAINLINK_ETH_USD);
        info[GM_TOKEN_XRP_WETH_USDC] =
            Info("GM_TOKEN_XRP_WETH_USDC", CHAINLINK_XRP_USD);
        info[GM_TOKEN_TRUMP_WETH_USDC] =
            Info("GM_TOKEN_TRUMP_WETH_USDC", CHAINLINK_TRUMP_USD);
        info[GM_TOKEN_DOGE_WETH_USDC] =
            Info("GM_TOKEN_DOGE_WETH_USDC", CHAINLINK_DOGE_USD);
        info[GM_TOKEN_UNI_UNI_USDC] =
            Info("GM_TOKEN_UNI_UNI_USDC", CHAINLINK_UNI_USD);
        info[GM_TOKEN_BERA_WETH_USDC] =
            Info("GM_TOKEN_BERA_WETH_USDC", CHAINLINK_BERA_USD);
        info[GM_TOKEN_LTC_WETH_USDC] =
            Info("GM_TOKEN_LTC_WETH_USDC", CHAINLINK_LTC_USD);
        info[GM_TOKEN_NEAR_WETH_USDC] =
            Info("GM_TOKEN_NEAR_WETH_USDC", CHAINLINK_NEAR_USD);
        info[GM_TOKEN_ENA_WETH_USDC] =
            Info("GM_TOKEN_ENA_WETH_USDC", CHAINLINK_ENA_USD);
        info[GM_TOKEN_MELANIA_WETH_USDC] =
            Info("GM_TOKEN_MELANIA_WETH_USDC", CHAINLINK_MELANIA_USD);
        info[GM_TOKEN_SEI_WETH_USDC] =
            Info("GM_TOKEN_SEI_WETH_USDC", CHAINLINK_SEI_USD);
        info[GM_TOKEN_LDO_WETH_USDC] =
            Info("GM_TOKEN_LDO_WETH_USDC", CHAINLINK_LDO_USD);
        info[GM_TOKEN_TAO_WBTC_USDC] =
            Info("GM_TOKEN_TAO_WBTC_USDC", CHAINLINK_TAO_USD);
        info[GM_TOKEN_ATOM_WETH_USDC] =
            Info("GM_TOKEN_ATOM_WETH_USDC", CHAINLINK_ATOM_USD);
        info[GM_TOKEN_DOT_WBTC_USDC] =
            Info("GM_TOKEN_DOT_WBTC_USDC", CHAINLINK_DOT_USD);
        info[GM_TOKEN_POL_WETH_USDC] =
            Info("GM_TOKEN_POL_WETH_USDC", CHAINLINK_POL_USD);
        info[GM_TOKEN_TIA_WETH_USDC] =
            Info("GM_TOKEN_TIA_WETH_USDC", CHAINLINK_TIA_USD);
        info[GM_TOKEN_STX_WBTC_USDC] =
            Info("GM_TOKEN_STX_WBTC_USDC", CHAINLINK_STX_USD);
        info[GM_TOKEN_KSHIB_WETH_USDC] =
            Info("GM_TOKEN_KSHIB_WETH_USDC", CHAINLINK_SHIB_USD);
        info[GM_TOKEN_ADA_WBTC_USDC] =
            Info("GM_TOKEN_ADA_WBTC_USDC", CHAINLINK_ADA_USD);
        info[GM_TOKEN_ORDI_WBTC_USDC] =
            Info("GM_TOKEN_ORDI_WBTC_USDC", CHAINLINK_ORDI_USD);
    }

    function get(address market) external returns (Info memory) {
        return info[market];
    }
}

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

    // index, short and long token to chainlink
    mapping(address => address) private chainlinks;
    address[] public tokens;

    function set(address market, address index, address long, address short) private {
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
                console.log("-------------", i, j);

                set(market.marketToken, market.indexToken, market.longToken, market.shortToken);

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
