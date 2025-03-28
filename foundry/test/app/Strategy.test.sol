// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "../lib/TestHelper.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";
import {IReader} from "../../src/interfaces/IReader.sol";
import {IOrderHandler} from "../../src/interfaces/IOrderHandler.sol";
import {OracleUtils} from "../../src/types/OracleUtils.sol";
import {Order} from "../../src/types/Order.sol";
import {Position} from "../../src/types/Position.sol";
import "../../src/Constants.sol";
import {Role} from "../../src/lib/Role.sol";
import {Oracle} from "../../src/lib/Oracle.sol";
// TODO: path to exercise
import {Strategy} from "../../src/solutions/app/Strategy.sol";

contract StrategyTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IReader constant reader = IReader(READER);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);

    TestHelper testHelper;
    Oracle oracle;
    Strategy strategy;
    address keeper;

    // Oracle params
    address[] tokens;
    address[] providers;
    bytes[] data;
    TestHelper.OracleParams[] oracles;

    function setUp() public {
        testHelper = new TestHelper();
        keeper = testHelper.getRoleMember(Role.ORDER_KEEPER);
        oracle = new Oracle();
        strategy = new Strategy(address(oracle));

        deal(WETH, address(this), 1000 * 1e18);

        tokens = new address[](2);
        tokens[0] = USDC;
        tokens[1] = WETH;

        providers = new address[](2);
        providers[0] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[1] = CHAINLINK_DATA_STREAM_PROVIDER;

        // NOTE: data kept empty for mock calls
        data = new bytes[](2);

        oracles = new TestHelper.OracleParams[](2);
        oracles[0] = TestHelper.OracleParams({
            chainlink: CHAINLINK_USDC_USD,
            multiplier: 1,
            deltaPrice: 0
        });
        oracles[1] = TestHelper.OracleParams({
            chainlink: CHAINLINK_ETH_USD,
            multiplier: 1,
            deltaPrice: 0
        });
    }

    function testOpenShort() public {
        uint256 executionFee = 1e18;
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);

        bytes32 orderKey = strategy.increase{value: executionFee}(wethAmount);

        Order.Props memory order = reader.getOrder(DATA_STORE, orderKey);
        assertEq(order.addresses.receiver, address(strategy), "order receiver");
        assertEq(order.addresses.market, GM_TOKEN_ETH_WETH_USDC, "market");
        assertEq(
            order.addresses.initialCollateralToken,
            WETH,
            "initial collateral token"
        );
        assertEq(
            uint256(order.numbers.orderType),
            uint256(Order.OrderType.MarketIncrease),
            "order type"
        );
        assertEq(
            order.numbers.initialCollateralDeltaAmount,
            wethAmount,
            "initial collateral delta amount"
        );
        assertApproxEqRel(
            order.numbers.sizeDeltaUsd,
            ethPrice * wethAmount * 1e30 / 1e26,
            1e18 / 100,
            "size delta USD"
        );
        assertEq(order.flags.isLong, false, "not short");

        // Execute order
        skip(1);

        testHelper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        vm.prank(keeper);
        orderHandler.executeOrder(
            orderKey,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        bytes32 positionKey = Position.getPositionKey({
            account: address(strategy),
            market: GM_TOKEN_ETH_WETH_USDC,
            collateralToken: WETH,
            isLong: false
        });

        Position.Props memory position;

        position = reader.getPosition(DATA_STORE, positionKey);
        console.log("pos.sizeInUsd %e", position.numbers.sizeInUsd);
        console.log("pos.sizeInTokens %e", position.numbers.sizeInTokens);
        console.log(
            "pos.collateralAmount %e", position.numbers.collateralAmount
        );

        assertGt(
            position.numbers.sizeInUsd,
            wethAmount * 1e12,
            "position size <= collateral amount"
        );
        assertGt(
            position.numbers.collateralAmount,
            0,
            "position collateral amount = 0"
        );
        assertEq(
            position.addresses.account, address(strategy), "position account"
        );

        /*
        // Test position profit and loss
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);
        int256 pnl = strategy.getPositionPnlUsd(positionKey, ethPrice * 110 / 100);
        console.log("pnl %e", pnl);
        assertGt(pnl, 0, "profit <= 0");

        // Create close order
        skip(1);
        bytes32 closeOrderKey = strategy.createCloseOrder();

        Order.Props memory closeOrder =
            reader.getOrder(DATA_STORE, closeOrderKey);
        assertEq(closeOrder.addresses.receiver, address(strategy), "order receiver");
        assertEq(
            uint256(closeOrder.numbers.orderType),
            uint256(Order.OrderType.MarketDecrease),
            "order type"
        );

        // Execute close order
        skip(1);

        // NOTE: acceptablePrice in strategy must be < oracle price + delta price
        oracles[0].deltaPrice = 0;
        oracles[1].deltaPrice = 5;

        testHelper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        testHelper.set("ETH keeper before", keeper.balance);
        testHelper.set("ETH strategy before", address(strategy).balance);

        vm.prank(keeper);
        orderHandler.executeOrder(
            closeOrderKey,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        testHelper.set("ETH keeper after", keeper.balance);
        testHelper.set("ETH strategy after", address(strategy).balance);
        testHelper.set("WETH strategy", weth.balanceOf(address(strategy)));
        testHelper.set("USDC strategy", usdc.balanceOf(address(strategy)));

        uint256 wethBal = testHelper.get("WETH strategy");
        uint256 usdcBal = testHelper.get("USDC strategy");

        console.log("WETH %e", wethBal);
        console.log("USDC %e", usdcBal);

        assertGe(wethBal, wethAmount, "WETH balance < initial collateral");
        assertEq(usdcBal, 0, "USDC balance != 0");
        assertGe(
            testHelper.get("ETH keeper after"),
            testHelper.get("ETH keeper before"),
            "Keeper execution fee"
        );
        assertGe(
            testHelper.get("ETH strategy after"),
            testHelper.get("ETH strategy before"),
            "Close execution fee refund"
        );

        position = reader.getPosition(DATA_STORE, positionKey);
        console.log("pos.sizeInUsd %e", position.numbers.sizeInUsd);
        console.log("pos.sizeInTokens %e", position.numbers.sizeInTokens);
        console.log(
            "pos.collateralAmount %e", position.numbers.collateralAmount
        );

        assertEq(position.numbers.sizeInUsd, 0, "position size != 0");
        assertEq(
            position.numbers.collateralAmount,
            0,
            "position collateral amount != 0"
        );
        */
    }
}
