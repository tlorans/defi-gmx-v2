// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./lib/TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IDepositHandler} from "../src/interfaces/IDepositHandler.sol";
import {IWithdrawalHandler} from "../src/interfaces/IWithdrawalHandler.sol";
import {IReader} from "../src/interfaces/IReader.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {Deposit} from "../src/types/Deposit.sol";
import {Withdrawal} from "../src/types/Withdrawal.sol";
import "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";
// TODO: import from exercises
import {MarketLiquidity} from "../src/solutions/MarketLiquidity.sol";

contract MarketLiquidityTest is Test {
    IERC20 constant wbtc = IERC20(WBTC);
    IERC20 constant usdc = IERC20(USDC);
    IERC20 constant gmToken = IERC20(GM_TOKEN_BTC_WBTC_USDC);
    IDepositHandler constant depositHandler = IDepositHandler(DEPOSIT_HANDLER);
    IWithdrawalHandler constant withdrawalHandler =
        IWithdrawalHandler(WITHDRAWAL_HANDLER);
    IReader constant reader = IReader(READER);

    TestHelper testHelper;
    MarketLiquidity marketLiquidity;
    address keeper;

    // Oracle params
    address[] tokens;
    address[] providers;
    bytes[] data;
    TestHelper.OracleParams[] oracles;

    function setUp() public {
        testHelper = new TestHelper();
        keeper = testHelper.getRoleMember(Role.ORDER_KEEPER);

        marketLiquidity = new MarketLiquidity();
        deal(USDC, address(this), 1000 * 1e6);

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
            // Same as WBTC
            multiplier: 1e8,
            deltaPrice: 0
        });
        oracles[1] = TestHelper.OracleParams({
            chainlink: CHAINLINK_USDC_USD,
            multiplier: 1,
            deltaPrice: 0
        });
        oracles[2] = TestHelper.OracleParams({
            chainlink: CHAINLINK_WBTC_USD,
            multiplier: 1,
            deltaPrice: 0
        });
    }

    function testMarketLiquidity() public {
        uint256 executionFee = 0.1 * 1e18;
        uint256 usdcAmount = 1000 * 1e6;
        usdc.approve(address(marketLiquidity), usdcAmount);

        bytes32 depositKey =
            marketLiquidity.createDeposit{value: executionFee}(usdcAmount);

        Deposit.Props memory deposit = reader.getDeposit(DATA_STORE, depositKey);
        assertEq(
            deposit.addresses.receiver,
            address(marketLiquidity),
            "deposit receiver"
        );
        assertEq(
            deposit.addresses.market, GM_TOKEN_BTC_WBTC_USDC, "deposit market"
        );
        assertGt(
            deposit.numbers.initialShortTokenAmount,
            0,
            "deposit initial short token amount"
        );

        // Execute deposit
        skip(1);

        testHelper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        testHelper.set(
            "GM token marketLiquidity before",
            gmToken.balanceOf(address(marketLiquidity))
        );

        vm.prank(keeper);
        depositHandler.executeDeposit(
            depositKey,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        testHelper.set(
            "GM token marketLiquidity after",
            gmToken.balanceOf(address(marketLiquidity))
        );

        console.log(
            "GM token marketLiquidity: %e",
            testHelper.get("GM token marketLiquidity after")
        );

        assertGt(
            testHelper.get("GM token marketLiquidity after"),
            testHelper.get("GM token marketLiquidity before"),
            "GM token marketLiquidity"
        );

        // Create withdrawal order
        skip(1);

        testHelper.set(
            "GM token marketLiquidity before",
            gmToken.balanceOf(address(marketLiquidity))
        );

        bytes32 withdrawalKey =
            marketLiquidity.createWithdrawal{value: executionFee}();

        testHelper.set(
            "GM token marketLiquidity after",
            gmToken.balanceOf(address(marketLiquidity))
        );

        Withdrawal.Props memory withdrawal =
            reader.getWithdrawal(DATA_STORE, withdrawalKey);
        assertEq(
            withdrawal.addresses.receiver,
            address(marketLiquidity),
            "withdrawal receiver"
        );
        assertEq(
            withdrawal.addresses.market,
            GM_TOKEN_BTC_WBTC_USDC,
            "withdrawal market"
        );
        assertGt(
            withdrawal.numbers.marketTokenAmount,
            0,
            "withdrawal market token amount"
        );

        assertEq(
            testHelper.get("GM token marketLiquidity after"),
            0,
            "GM token marketLiquidity"
        );

        // Execute withdrawal
        skip(1);

        testHelper.set(
            "WBTC marketLiquidity before",
            wbtc.balanceOf(address(marketLiquidity))
        );
        testHelper.set(
            "USDC marketLiquidity before",
            usdc.balanceOf(address(marketLiquidity))
        );
        testHelper.set(
            "GM token marketLiquidity before",
            gmToken.balanceOf(address(marketLiquidity))
        );

        testHelper.mockOraclePrices({
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

        testHelper.set(
            "WBTC marketLiquidity after",
            wbtc.balanceOf(address(marketLiquidity))
        );
        testHelper.set(
            "USDC marketLiquidity after",
            usdc.balanceOf(address(marketLiquidity))
        );
        testHelper.set(
            "GM token marketLiquidity after",
            gmToken.balanceOf(address(marketLiquidity))
        );

        console.log(
            "WBTC marketLiquidity: %e",
            testHelper.get("WBTC marketLiquidity after")
        );
        console.log(
            "USDC marketLiquidity: %e",
            testHelper.get("USDC marketLiquidity after")
        );

        assertGt(
            testHelper.get("WBTC marketLiquidity after"),
            testHelper.get("WBTC marketLiquidity before"),
            "WBTC marketLiquidity"
        );
        assertGt(
            testHelper.get("USDC marketLiquidity after"),
            testHelper.get("USDC marketLiquidity before"),
            "USDC marketLiquidity"
        );
        assertGe(
            testHelper.get("GM token marketLiquidity after"),
            0,
            "GM token marketLiquidity"
        );
    }
}
