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
import {Math} from "../../src/lib/Math.sol";
import {Role} from "../../src/lib/Role.sol";
import {Oracle} from "../../src/lib/Oracle.sol";
// TODO: path to exercise
import {Strategy} from "../../src/solutions/app/Strategy.sol";

contract StrategyTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IReader constant reader = IReader(READER);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);
    uint256 constant EXECUTION_FEE = 0.01 * 1e18;

    TestHelper testHelper;
    Oracle oracle;
    Strategy strategy;
    address keeper;

    // Oracle params
    address[] tokens;
    address[] providers;
    bytes[] data;
    TestHelper.OracleParams[] oracles;
    bytes32 positionKey;

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

        positionKey = Position.getPositionKey({
            account: address(strategy),
            market: GM_TOKEN_ETH_WETH_USDC,
            collateralToken: WETH,
            isLong: false
        });
    }

    function open(uint256 wethAmount) public {
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);

        bytes32 orderKey = strategy.increase{value: EXECUTION_FEE}(wethAmount);

        Order.Props memory order = reader.getOrder(DATA_STORE, orderKey);

        assertEq(
            order.addresses.receiver, address(strategy), "open: order receiver"
        );
        assertEq(order.addresses.market, GM_TOKEN_ETH_WETH_USDC, "open: market");
        assertEq(
            order.addresses.initialCollateralToken,
            WETH,
            "open: initial collateral token"
        );
        assertEq(
            uint256(order.numbers.orderType),
            uint256(Order.OrderType.MarketIncrease),
            "open: order type"
        );
        assertEq(
            order.numbers.initialCollateralDeltaAmount,
            wethAmount,
            "open: initial collateral delta amount"
        );
        assertApproxEqRel(
            order.numbers.sizeDeltaUsd,
            ethPrice * wethAmount * 1e30 / 1e26,
            1e18 / 100,
            "open: size delta USD"
        );
        assertEq(order.flags.isLong, false, "open: not short");

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

        Position.Props memory position =
            reader.getPosition(DATA_STORE, positionKey);
        console.log("pos.sizeInUsd %e", position.numbers.sizeInUsd);
        console.log("pos.sizeInTokens %e", position.numbers.sizeInTokens);
        console.log(
            "pos.collateralAmount %e", position.numbers.collateralAmount
        );

        assertApproxEqRel(
            position.numbers.sizeInUsd,
            ethPrice * wethAmount * 1e4,
            1e18 * 2 / 100,
            "open: position size"
        );
        assertGe(
            position.numbers.collateralAmount,
            wethAmount * 99 / 100,
            "open: position collateral amount"
        );
        assertEq(
            position.addresses.account,
            address(strategy),
            "open: position account"
        );
    }

    function close(uint256 wethAmount) public {
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);

        bytes32 orderKey = strategy.decrease{value: EXECUTION_FEE}(wethAmount);

        Position.Props memory position =
            reader.getPosition(DATA_STORE, positionKey);
        Order.Props memory order = reader.getOrder(DATA_STORE, orderKey);

        assertEq(
            order.addresses.receiver, address(strategy), "close: order receiver"
        );
        assertEq(
            order.addresses.market, GM_TOKEN_ETH_WETH_USDC, "close: market"
        );
        assertEq(
            order.addresses.initialCollateralToken,
            WETH,
            "close: initial collateral token"
        );
        assertEq(
            uint256(order.numbers.orderType),
            uint256(Order.OrderType.MarketDecrease),
            "close: order type"
        );
        assertEq(
            order.numbers.initialCollateralDeltaAmount,
            Math.min(wethAmount, position.numbers.collateralAmount),
            "close: initial collateral delta amount"
        );
        assertApproxEqRel(
            order.numbers.sizeDeltaUsd,
            ethPrice * wethAmount * 1e30 / 1e26,
            1e18 / 100,
            "close: size delta USD"
        );
        assertEq(order.flags.isLong, false, "close: not short");

        // Execute close order
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

        testHelper.set("WETH strategy", weth.balanceOf(address(strategy)));
        testHelper.set("USDC strategy", usdc.balanceOf(address(strategy)));

        uint256 wethBal = testHelper.get("WETH strategy");
        uint256 usdcBal = testHelper.get("USDC strategy");

        console.log("WETH %e", wethBal);
        console.log("USDC %e", usdcBal);

        // assertGe(wethBal, wethAmount, "WETH balance < initial collateral");
        // assertEq(usdcBal, 0, "USDC balance != 0");

        position = reader.getPosition(DATA_STORE, positionKey);
        console.log("pos.sizeInUsd %e", position.numbers.sizeInUsd);
        console.log("pos.sizeInTokens %e", position.numbers.sizeInTokens);
        console.log(
            "pos.collateralAmount %e", position.numbers.collateralAmount
        );

        assertEq(position.numbers.sizeInUsd, 0, "close: position size != 0");
        assertEq(
            position.numbers.collateralAmount,
            0,
            "close: position collateral amount != 0"
        );
    }

    function testOpenShort() public {
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);


        open(wethAmount);

        strategy.totalValue();

        skip(1);
        close(wethAmount);
    }
}
