// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "../lib/TestHelper.sol";
import {DecreaseCallback} from "./DecreaseCallback.sol";
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
import {Strategy} from "@exercises/app/Strategy.sol";

contract StrategyTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IReader constant reader = IReader(READER);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);
    uint256 constant EXECUTION_FEE = 0.01 * 1e18;

    TestHelper testHelper;
    Oracle oracle;
    Strategy strategy;
    DecreaseCallback cb;
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
        cb = new DecreaseCallback();

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

    function inc(uint256 wethAmount) public returns (bytes32 orderKey) {
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);

        orderKey = strategy.increase{value: EXECUTION_FEE}(wethAmount);

        Order.Props memory order = reader.getOrder(DATA_STORE, orderKey);

        assertEq(
            order.addresses.receiver, address(strategy), "inc: order receiver"
        );
        assertEq(order.addresses.market, GM_TOKEN_ETH_WETH_USDC, "inc: market");
        assertEq(
            order.addresses.initialCollateralToken,
            WETH,
            "inc: initial collateral token"
        );
        assertEq(
            uint256(order.numbers.orderType),
            uint256(Order.OrderType.MarketIncrease),
            "inc: order type"
        );
        assertEq(
            order.numbers.initialCollateralDeltaAmount,
            wethAmount,
            "inc: initial collateral delta amount"
        );
        assertApproxEqRel(
            order.numbers.sizeDeltaUsd,
            ethPrice * wethAmount * 1e30 / 1e26,
            1e18 / 100,
            "inc: size delta USD"
        );
        assertEq(order.flags.isLong, false, "inc: not short");

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

        assertApproxEqRel(
            position.numbers.sizeInUsd,
            ethPrice * wethAmount * 1e4,
            1e18 * 2 / 100,
            "inc: position size"
        );
        assertGe(
            position.numbers.collateralAmount,
            wethAmount * 99 / 100,
            "inc: position collateral amount"
        );
        assertEq(
            position.addresses.account,
            address(strategy),
            "inc: position account"
        );
    }

    function dec(uint256 wethAmount, address callback)
        public
        returns (bytes32 orderKey)
    {
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);

        orderKey = strategy.decrease{value: EXECUTION_FEE}(wethAmount, callback);

        Position.Props memory position =
            reader.getPosition(DATA_STORE, positionKey);
        Order.Props memory order = reader.getOrder(DATA_STORE, orderKey);

        address receiver = callback == address(0) ? address(strategy) : callback;
        assertEq(order.addresses.receiver, receiver, "dec: order receiver");

        assertEq(order.addresses.market, GM_TOKEN_ETH_WETH_USDC, "dec: market");
        assertEq(
            order.addresses.initialCollateralToken,
            WETH,
            "dec: initial collateral token"
        );
        assertEq(
            uint256(order.numbers.orderType),
            uint256(Order.OrderType.MarketDecrease),
            "dec: order type"
        );
        assertEq(
            order.numbers.initialCollateralDeltaAmount,
            Math.min(wethAmount, position.numbers.collateralAmount),
            "dec: initial collateral delta amount"
        );
        assertApproxEqRel(
            order.numbers.sizeDeltaUsd,
            ethPrice * wethAmount * 1e30 / 1e26,
            1e18 / 100,
            "dec: size delta USD"
        );
        assertEq(order.flags.isLong, false, "dec: not short");

        // Execute dec order
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

        uint256 wethBal = weth.balanceOf(receiver);
        uint256 usdcBal = usdc.balanceOf(receiver);

        assertGe(
            wethBal, wethAmount * 99 / 100, "WETH balance < initial collateral"
        );
        assertEq(usdcBal, 0, "USDC balance != 0");

        position = reader.getPosition(DATA_STORE, positionKey);

        assertEq(position.numbers.sizeInUsd, 0, "dec: position size != 0");
        assertEq(
            position.numbers.collateralAmount,
            0,
            "dec: position collateral amount != 0"
        );
    }

    // TODO: multiple incs and partial decs

    function testOpenCloseShort() public {
        uint256 totalValue = 0;

        totalValue = strategy.totalValueInToken();
        assertEq(totalValue, 0, "total value != 0");

        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        totalValue = strategy.totalValueInToken();
        assertEq(totalValue, wethAmount, "total value != WETH amount");

        // Open short position
        inc(wethAmount);

        uint256 total = strategy.totalValueInToken();
        assertGe(total, wethAmount * 995 / 1000, "total value");

        // Claim funding fees
        testHelper.set("WETH before", weth.balanceOf(address(strategy)));
        strategy.claim();
        testHelper.set("WETH after", weth.balanceOf(address(strategy)));

        assertGe(testHelper.get("WETH after"), testHelper.get("WETH before"));

        // Close short position
        skip(1);
        dec(wethAmount, address(0));
    }

    function testCancel() public {
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        bytes32 orderKey = strategy.increase{value: EXECUTION_FEE}(wethAmount);

        Order.Props memory order;

        order = reader.getOrder(DATA_STORE, orderKey);
        assertEq(
            order.addresses.receiver,
            address(strategy),
            "cancel: order receiver"
        );

        skip(24 * 3600);
        strategy.cancel(orderKey);

        order = reader.getOrder(DATA_STORE, orderKey);
        assertEq(
            order.addresses.receiver,
            address(0),
            "cancel: order receiver != address(0)"
        );
    }

    function testDecreaseCallback() public {
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        inc(wethAmount);

        skip(1);
        bytes32 decOrderKey = dec(wethAmount, address(cb));

        assertGt(address(cb).balance, 0, "ETH = 0");
        assertEq(cb.orderKey(), decOrderKey, "callback: order key");
        assertTrue(
            cb.status() == DecreaseCallback.Status.Executed, "callback: status"
        );
    }

    function testCancelDecreaseCallback() public {
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        inc(wethAmount);

        skip(1);
        bytes32 decOrderKey =
            strategy.decrease{value: EXECUTION_FEE}(wethAmount, address(cb));

        skip(24 * 3600);
        strategy.cancel(decOrderKey);

        assertGt(address(cb).balance, 0, "ETH = 0");
        assertEq(cb.orderKey(), decOrderKey, "callback: order key");
        assertTrue(
            cb.status() == DecreaseCallback.Status.Canceled, "callback: status"
        );
    }
}
