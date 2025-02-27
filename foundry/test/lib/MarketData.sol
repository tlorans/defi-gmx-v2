// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../../src/Constants.sol";

contract MarketData {
    struct Info {
        string name;
        address oracle;
    }
    // market, index, short and long token to chainlink

    mapping(address => Info) public info;
    address[] public tokens;

    function set(string memory name, address token, address oracle) internal {
        require(info[token].oracle == address(0), "duplicate");
        info[token] = Info(name, oracle);
        tokens.push(token);
    }

    constructor() {
        // Short and long
        set("WETH", WETH, CHAINLINK_ETH_USD);
        set("WBTC", WBTC, CHAINLINK_BTC_USD);
        set("USDC", USDC, CHAINLINK_USDC_USD);
        set("DAI", DAI, CHAINLINK_DAI_USD);
        set("AAVE", AAVE, CHAINLINK_AAVE_USD);

        // Index
        set(
            "GMX_RENDER_WETH_USDC_INDEX", GMX_RENDER_WETH_USDC_INDEX, address(0)
        );
        set("GMX_SUI_WETH_USDC_INDEX", GMX_SUI_WETH_USDC_INDEX, address(0));
        set("GMX_APT_WETH_USDC_INDEX", GMX_APT_WETH_USDC_INDEX, address(0));
        set("GMX_WLD_WETH_USDC_INDEX", GMX_WLD_WETH_USDC_INDEX, address(0));
        set("GMX_FET_WETH_USDC_INDEX", GMX_FET_WETH_USDC_INDEX, address(0));
        set("GMX_TRX_WETH_USDC_INDEX", GMX_TRX_WETH_USDC_INDEX, address(0));
        set("GMX_TON_WETH_USDC_INDEX", GMX_TON_WETH_USDC_INDEX, address(0));
        set("GMX_ONDO_WETH_USDC_INDEX", GMX_ONDO_WETH_USDC_INDEX, address(0));
        set("GMX_EIGEN_WETH_USDC_INDEX", GMX_EIGEN_WETH_USDC_INDEX, address(0));
        set("GMX_KBONK_WETH_USDC_INDEX", GMX_KBONK_WETH_USDC_INDEX, address(0));
        set(
            "GMX_FARTCOIN_WBTC_USDC_INDEX",
            GMX_FARTCOIN_WBTC_USDC_INDEX,
            address(0)
        );
        set("GMX_PENGU_WBTC_USDC_INDEX", GMX_PENGU_WBTC_USDC_INDEX, address(0));
        set(
            "GMX_VIRTUAL_WBTC_USDC_INDEX",
            GMX_VIRTUAL_WBTC_USDC_INDEX,
            address(0)
        );
        set("GMX_BCH_WBTC_USDC_INDEX", GMX_BCH_WBTC_USDC_INDEX, address(0));
        set(
            "GMX_KFLOKI_WBTC_USDC_INDEX", GMX_KFLOKI_WBTC_USDC_INDEX, address(0)
        );
        set("GMX_INJ_WBTC_USDC_INDEX", GMX_INJ_WBTC_USDC_INDEX, address(0));
        set("GMX_FIL_WBTC_USDC_INDEX", GMX_FIL_WBTC_USDC_INDEX, address(0));
        set("GMX_ICP_WBTC_USDC_INDEX", GMX_ICP_WBTC_USDC_INDEX, address(0));
        set("GMX_BOME_WBTC_USDC_INDEX", GMX_BOME_WBTC_USDC_INDEX, address(0));
        set("GMX_XLM_WBTC_USDC_INDEX", GMX_XLM_WBTC_USDC_INDEX, address(0));
        set("GMX_AI16Z_WBTC_USDC_INDEX", GMX_AI16Z_WBTC_USDC_INDEX, address(0));
        set("GMX_MSATS_WBTC_USDC_INDEX", GMX_MSATS_WBTC_USDC_INDEX, address(0));
        set("GMX_MEME_WBTC_USDC_INDEX", GMX_MEME_WBTC_USDC_INDEX, address(0));
        set("GMX_MEW_WBTC_USDC_INDEX", GMX_MEW_WBTC_USDC_INDEX, address(0));
        set("GMX_DYDX_WBTC_USDC_INDEX", GMX_DYDX_WBTC_USDC_INDEX, address(0));

        set(
            "GMX_BTC_WBTC_USDC_INDEX",
            GMX_BTC_WBTC_USDC_INDEX,
            CHAINLINK_BTC_USD
        );
        set(
            "GMX_ETH_WETH_USDC_INDEX",
            GMX_ETH_WETH_USDC_INDEX,
            CHAINLINK_ETH_USD
        );
        set(
            "GMX_XRP_WETH_USDC_INDEX",
            GMX_XRP_WETH_USDC_INDEX,
            CHAINLINK_XRP_USD
        );
        set(
            "GMX_TRUMP_WETH_USDC_INDEX",
            GMX_TRUMP_WETH_USDC_INDEX,
            CHAINLINK_TRUMP_USD
        );
        set(
            "GMX_DOGE_WETH_USDC_INDEX",
            GMX_DOGE_WETH_USDC_INDEX,
            CHAINLINK_DOGE_USD
        );
        set(
            "GMX_BERA_WETH_USDC_INDEX",
            GMX_BERA_WETH_USDC_INDEX,
            CHAINLINK_BERA_USD
        );
        set(
            "GMX_LTC_WETH_USDC_INDEX",
            GMX_LTC_WETH_USDC_INDEX,
            CHAINLINK_LTC_USD
        );
        set(
            "GMX_NEAR_WETH_USDC_INDEX",
            GMX_NEAR_WETH_USDC_INDEX,
            CHAINLINK_NEAR_USD
        );
        set(
            "GMX_ENA_WETH_USDC_INDEX",
            GMX_ENA_WETH_USDC_INDEX,
            CHAINLINK_ENA_USD
        );
        set(
            "GMX_MELANIA_WETH_USDC_INDEX",
            GMX_MELANIA_WETH_USDC_INDEX,
            CHAINLINK_MELANIA_USD
        );
        set(
            "GMX_SEI_WETH_USDC_INDEX",
            GMX_SEI_WETH_USDC_INDEX,
            CHAINLINK_SEI_USD
        );
        set(
            "GMX_LDO_WETH_USDC_INDEX",
            GMX_LDO_WETH_USDC_INDEX,
            CHAINLINK_LDO_USD
        );
        set(
            "GMX_TAO_WBTC_USDC_INDEX",
            GMX_TAO_WBTC_USDC_INDEX,
            CHAINLINK_TAO_USD
        );
        set(
            "GMX_ATOM_WETH_USDC_INDEX",
            GMX_ATOM_WETH_USDC_INDEX,
            CHAINLINK_ATOM_USD
        );
        set(
            "GMX_DOT_WBTC_USDC_INDEX",
            GMX_DOT_WBTC_USDC_INDEX,
            CHAINLINK_DOT_USD
        );
        set(
            "GMX_POL_WETH_USDC_INDEX",
            GMX_POL_WETH_USDC_INDEX,
            CHAINLINK_POL_USD
        );
        set(
            "GMX_TIA_WETH_USDC_INDEX",
            GMX_TIA_WETH_USDC_INDEX,
            CHAINLINK_TIA_USD
        );
        set(
            "GMX_STX_WBTC_USDC_INDEX",
            GMX_STX_WBTC_USDC_INDEX,
            CHAINLINK_STX_USD
        );
        set(
            "GMX_KSHIB_WETH_USDC_INDEX",
            GMX_KSHIB_WETH_USDC_INDEX,
            CHAINLINK_SHIB_USD
        );
        set(
            "GMX_ADA_WBTC_USDC_INDEX",
            GMX_ADA_WBTC_USDC_INDEX,
            CHAINLINK_ADA_USD
        );
        set(
            "GMX_ORDI_WBTC_USDC_INDEX",
            GMX_ORDI_WBTC_USDC_INDEX,
            CHAINLINK_ORDI_USD
        );
    }

    function get(address token) external returns (Info memory) {
        return info[token];
    }
}
