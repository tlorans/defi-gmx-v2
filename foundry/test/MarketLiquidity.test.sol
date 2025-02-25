// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IDepositHandler} from "../src/interfaces/IDepositHandler.sol";
import {IReader} from "../src/interfaces/IReader.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {Deposit} from "../src/types/Deposit.sol";
import {
    WBTC,
    USDC,
    CHAINLINK_BTC_USD,
    CHAINLINK_WBTC_USD,
    CHAINLINK_USDC_USD,
    DATA_STORE,
    READER,
    DEPOSIT_HANDLER,
    CHAINLINK_DATA_STREAM_PROVIDER,
    GM_TOKEN_WBTC_USDC,
    GMX_EOA_1
} from "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";
// TODO: import from exercises
import {MarketLiquidity} from "../src/solutions/MarketLiquidity.sol";

contract MarketLiquidityTest is Test {
    IERC20 constant wbtc = IERC20(WBTC);
    IERC20 constant usdc = IERC20(USDC);
    IERC20 constant gmToken = IERC20(GM_TOKEN_WBTC_USDC);
    IDepositHandler constant depositHandler = IDepositHandler(DEPOSIT_HANDLER);
    IReader constant reader = IReader(READER);

    TestHelper helper;
    MarketLiquidity marketLiquidity;
    address keeper;

    // Oracle params
    address[] tokens;
    address[] providers;
    bytes[] data;
    TestHelper.OracleParams[] oracles;

    function setUp() public {
        helper = new TestHelper();
        keeper = helper.getRoleMember(Role.ORDER_KEEPER);

        marketLiquidity = new MarketLiquidity();
        deal(USDC, address(this), 1000 * 1e6);

        tokens = new address[](3);
        tokens[0] = GMX_EOA_1;
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

    function testMarketLiquidity() public {
        uint256 executionFee = 0.1 * 1e18;
        uint256 usdcAmount = 1000 * 1e6;
        usdc.approve(address(marketLiquidity), usdcAmount);

        helper.set("ETH keeper before", keeper.balance);
        helper.set(
            "ETH marketLiquidity before", address(marketLiquidity).balance
        );

        bytes32 depositKey =
            marketLiquidity.createDeposit{value: executionFee}(usdcAmount);

        Deposit.Props memory deposit = reader.getDeposit(DATA_STORE, depositKey);
        assertEq(
            deposit.addresses.receiver,
            address(marketLiquidity),
            "deposit receiver"
        );
        assertEq(deposit.addresses.market, GM_TOKEN_WBTC_USDC, "deposit market");
        assertGt(
            deposit.numbers.initialShortTokenAmount,
            0,
            "deposit initial short token amount"
        );

        helper.set("ETH keeper after", keeper.balance);
        helper.set(
            "ETH marketLiquidity after", address(marketLiquidity).balance
        );

        console.log("ETH keeper: %e", helper.get("ETH keeper after"));
        console.log(
            "ETH marketLiquidity: %e", helper.get("ETH marketLiquidity after")
        );

        assertGe(
            helper.get("ETH keeper after"),
            helper.get("ETH keeper before"),
            "Keeper execution fee"
        );
        assertGe(
            helper.get("ETH marketLiquidity after"),
            helper.get("ETH marketLiquidity before"),
            "marketLiquidity execution fee refund"
        );

        // Execute deposit
        skip(1);

        helper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        helper.set("ETH keeper before", keeper.balance);
        helper.set(
            "ETH marketLiquidity before", address(marketLiquidity).balance
        );
        helper.set(
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

        helper.set("ETH keeper after", keeper.balance);
        helper.set(
            "ETH marketLiquidity after", address(marketLiquidity).balance
        );
        helper.set(
            "GM token marketLiquidity after",
            gmToken.balanceOf(address(marketLiquidity))
        );

        console.log("ETH keeper: %e", helper.get("ETH keeper after"));
        console.log(
            "ETH marketLiquidity: %e", helper.get("ETH marketLiquidity after")
        );
        console.log(
            "GM token marketLiquidity: %e",
            helper.get("GM token marketLiquidity after")
        );

        assertGe(
            helper.get("ETH keeper after"),
            helper.get("ETH keeper before"),
            "Keeper execution fee"
        );
        assertGe(
            helper.get("ETH marketLiquidity after"),
            helper.get("ETH marketLiquidity before"),
            "marketLiquidity execution fee refund"
        );
        assertGt(
            helper.get("GM token marketLiquidity after"),
            helper.get("GM token marketLiquidity before"),
            "GM token marketLiquidity"
        );
    }
}
