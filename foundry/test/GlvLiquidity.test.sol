// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IGlvHandler} from "../src/interfaces/IGlvHandler.sol";
import {IWithdrawalHandler} from "../src/interfaces/IWithdrawalHandler.sol";
import {IGlvReader} from "../src/interfaces/IGlvReader.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {GlvDeposit} from "../src/types/GlvDeposit.sol";
import {GlvWithdrawal} from "../src/types/GlvWithdrawal.sol";
import "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";
// TODO: import from exercises
import {GlvLiquidity} from "../src/solutions/GlvLiquidity.sol";

contract GlvLiquidityTest is Test {
    IERC20 constant wbtc = IERC20(WBTC);
    IERC20 constant usdc = IERC20(USDC);
    IERC20 constant glvToken = IERC20(GLV_TOKEN);
    IGlvHandler constant glvHandler = IGlvHandler(GLV_HANDLER);
    IWithdrawalHandler constant withdrawalHandler =
        IWithdrawalHandler(WITHDRAWAL_HANDLER);
    IGlvReader constant glvReader = IGlvReader(GLV_READER);

    TestHelper helper;
    GlvLiquidity glvLiquidity;
    address keeper;

    // Oracle params
    address[] tokens;
    address[] providers;
    bytes[] data;
    TestHelper.OracleParams[] oracles;

    function setUp() public {
        helper = new TestHelper();
        keeper = helper.getRoleMember(Role.ORDER_KEEPER);

        glvLiquidity = new GlvLiquidity();
        deal(USDC, address(this), 1000 * 1e6);

        IGlvReader.GlvInfo[] memory glvInfo =
            glvReader.getGlvInfoList(DATA_STORE, 0, 100);
        for (uint256 i = 0; i < glvInfo.length; i++) {
            for (uint256 j = 0; j < glvInfo[i].markets.length; j++) {
                // address market =
            }
        }

        tokens = new address[](3);
        tokens[0] = GMX_BTC_WBTC_USDC_INDEX;
        tokens[1] = USDC;
        tokens[2] = WBTC;

        providers = new address[](3);
        providers[0] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[1] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[2] = CHAINLINK_DATA_STREAM_PROVIDER;

        // NOTE: data kept empty for mock calls
        data = new bytes[](3);

        oracles = new TestHelper.OracleParams[](3);
        oracles[0] = TestHelper.OracleParams({
            chainlink: CHAINLINK_BTC_USD,
            multiplier: 1e14,
            deltaPrice: 0
        });
        oracles[1] = TestHelper.OracleParams({
            chainlink: CHAINLINK_USDC_USD,
            multiplier: 1e16,
            deltaPrice: 0
        });
        oracles[2] = TestHelper.OracleParams({
            chainlink: CHAINLINK_WBTC_USD,
            multiplier: 1e14,
            deltaPrice: 0
        });
    }

    function testGlvLiquidity() public {
        uint256 executionFee = 0.1 * 1e18;
        uint256 usdcAmount = 1000 * 1e6;
        usdc.approve(address(glvLiquidity), usdcAmount);

        bytes32 depositKey =
            glvLiquidity.createGlvDeposit{value: executionFee}(usdcAmount);

        GlvDeposit.Props memory deposit =
            glvReader.getGlvDeposit(DATA_STORE, depositKey);
        assertEq(
            deposit.addresses.receiver,
            address(glvLiquidity),
            "GLV deposit receiver"
        );
        assertEq(
            deposit.addresses.market,
            GM_TOKEN_BTC_WBTC_USDC,
            "GLV deposit market"
        );
        assertGt(
            deposit.numbers.initialShortTokenAmount,
            0,
            "GLV deposit initial short token amount"
        );

        // Execute deposit
        skip(1);

        helper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        helper.set(
            "GM token glvLiquidity before",
            glvToken.balanceOf(address(glvLiquidity))
        );

        vm.prank(keeper);
        glvHandler.executeGlvDeposit(
            depositKey,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        helper.set(
            "GM token glvLiquidity after",
            glvToken.balanceOf(address(glvLiquidity))
        );

        console.log(
            "GM token glvLiquidity: %e",
            helper.get("GM token glvLiquidity after")
        );

        assertGt(
            helper.get("GM token glvLiquidity after"),
            helper.get("GM token glvLiquidity before"),
            "GM token glvLiquidity"
        );

        /*
        // Create withdrawal order
        skip(1);

        helper.set(
            "GM token glvLiquidity before",
            glvToken.balanceOf(address(glvLiquidity))
        );

        bytes32 withdrawalKey =
            glvLiquidity.createWithdrawal{value: executionFee}();

        helper.set(
            "GM token glvLiquidity after",
            glvToken.balanceOf(address(glvLiquidity))
        );

        Withdrawal.Props memory withdrawal =
            glvReader.getWithdrawal(DATA_STORE, withdrawalKey);
        assertEq(
            withdrawal.addresses.receiver,
            address(glvLiquidity),
            "withdrawal receiver"
        );
        assertEq(
            withdrawal.addresses.market, GM_TOKEN_BTC_WBTC_USDC, "withdrawal market"
        );
        assertGt(
            withdrawal.numbers.marketTokenAmount,
            0,
            "withdrawal market token amount"
        );

        assertEq(
            helper.get("GM token glvLiquidity after"),
            0,
            "GM token glvLiquidity"
        );

        // Execute withdrawal
        skip(1);

        helper.set(
            "WBTC glvLiquidity before",
            wbtc.balanceOf(address(glvLiquidity))
        );
        helper.set(
            "USDC glvLiquidity before",
            usdc.balanceOf(address(glvLiquidity))
        );
        helper.set(
            "GM token glvLiquidity before",
            glvToken.balanceOf(address(glvLiquidity))
        );

        helper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        vm.prank(keeper);
        withdrawalHandler.executeWithdrawal(
            withdrawalKey,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        helper.set(
            "WBTC glvLiquidity after",
            wbtc.balanceOf(address(glvLiquidity))
        );
        helper.set(
            "USDC glvLiquidity after",
            usdc.balanceOf(address(glvLiquidity))
        );
        helper.set(
            "GM token glvLiquidity after",
            glvToken.balanceOf(address(glvLiquidity))
        );

        console.log(
            "WBTC glvLiquidity: %e", helper.get("WBTC glvLiquidity after")
        );
        console.log(
            "USDC glvLiquidity: %e", helper.get("USDC glvLiquidity after")
        );

        assertGt(
            helper.get("WBTC glvLiquidity after"),
            helper.get("WBTC glvLiquidity before"),
            "WBTC glvLiquidity"
        );
        assertGt(
            helper.get("USDC glvLiquidity after"),
            helper.get("USDC glvLiquidity before"),
            "USDC glvLiquidity"
        );
        assertGe(
            helper.get("GM token glvLiquidity after"),
            0,
            "GM token glvLiquidity"
        );
        */
    }
}
