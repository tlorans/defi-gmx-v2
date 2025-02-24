// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IReader} from "../src/interfaces/IReader.sol";
import {IOrderHandler} from "../src/interfaces/IOrderHandler.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {Order} from "../src/types/Order.sol";
import {Position} from "../src/types/Position.sol";
import {
    WETH,
    USDC,
    CHAINLINK_ETH_USD,
    CHAINLINK_DAI_USD,
    CHAINLINK_USDC_USD,
    DATA_STORE,
    READER,
    ORDER_HANDLER,
    GM_TOKEN_WETH_USDC,
    CHAINLINK_DATA_STREAM_PROVIDER
} from "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";
import {Oracle} from "../src/lib/Oracle.sol";
// TODO: import from exercises
import {Long} from "../src/solutions/Long.sol";

contract LongTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);
    IReader constant reader = IReader(READER);

    TestHelper helper;
    Oracle oracle;
    Long long;

    function setUp() public {
        helper = new TestHelper();
        oracle = new Oracle();
        long = new Long(address(oracle));
        deal(WETH, address(this), 1000 * 1e18);
    }

    function testLong() public {
        uint256 executionFee = 1e18;
        uint256 wethAmount = 1e18;
        weth.approve(address(long), wethAmount);

        bytes32 longOrderKey =
            long.createLongOrder{value: executionFee}(wethAmount);

        Order.Props memory longOrder = reader.getOrder(DATA_STORE, longOrderKey);
        assertEq(longOrder.addresses.receiver, address(long), "order receiver");
        assertEq(
            uint256(longOrder.numbers.orderType),
            uint256(Order.OrderType.MarketIncrease),
            "order type"
        );
        assertEq(longOrder.flags.isLong, true, "not long");

        // Execute long order
        skip(1);

        address[] memory tokens = new address[](2);
        tokens[0] = USDC;
        tokens[1] = WETH;

        address[] memory providers = new address[](2);
        providers[0] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[1] = CHAINLINK_DATA_STREAM_PROVIDER;

        // NOTE: data kept empty for mock calls
        bytes[] memory data = new bytes[](2);

        TestHelper.OracleParams[] memory oracles =
            new TestHelper.OracleParams[](2);
        oracles[0] = TestHelper.OracleParams({
            chainlink: CHAINLINK_USDC_USD,
            multiplier: 1e16,
            deltaPrice: 0
        });
        oracles[1] = TestHelper.OracleParams({
            chainlink: CHAINLINK_ETH_USD,
            multiplier: 1e4,
            deltaPrice: 0
        });

        helper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        address keeper = helper.getRoleMember(Role.ORDER_KEEPER);

        uint256[] memory b0 = new uint256[](2);
        uint256[] memory b1 = new uint256[](2);

        b0[0] = keeper.balance;
        b0[1] = address(long).balance;

        vm.prank(keeper);
        orderHandler.executeOrder(
            longOrderKey,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        b1[0] = keeper.balance;
        b1[1] = address(long).balance;

        console.log("ETH keeper: %e", b1[0]);
        console.log("ETH long: %e", b1[1]);
        assertGe(b1[0], b0[0], "Keeper execution fee");
        assertGe(b1[1], b0[1], "long execution fee refund");

        bytes32 positionKey = Position.getPositionKey({
            account: address(long),
            market: GM_TOKEN_WETH_USDC,
            collateralToken: WETH,
            isLong: true
        });

        assertEq(long.getPositionKey(), positionKey, "position key");

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
            position.addresses.account,
            long.getPosition(positionKey).addresses.account,
            "position"
        );

        // Create close order
        skip(1);
        bytes32 closeOrderKey = long.createCloseOrder();

        Order.Props memory closeOrder =
            reader.getOrder(DATA_STORE, closeOrderKey);
        assertEq(closeOrder.addresses.receiver, address(long), "order receiver");
        assertEq(
            uint256(closeOrder.numbers.orderType),
            uint256(Order.OrderType.MarketDecrease),
            "order type"
        );

        // Execute close order
        skip(1);

        // NOTE: acceptablePrice in long must be < oracle price + delta price
        oracles[0].deltaPrice = 0;
        oracles[1].deltaPrice = 5;

        helper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        b0[0] = keeper.balance;
        b0[1] = address(long).balance;

        vm.prank(keeper);
        orderHandler.executeOrder(
            closeOrderKey,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        b1[0] = keeper.balance;
        b1[1] = address(long).balance;

        uint256 wethBal = weth.balanceOf(address(long));
        uint256 usdcBal = usdc.balanceOf(address(long));

        console.log("WETH %e", wethBal);
        console.log("USDC %e", usdcBal);

        assertGe(wethBal, wethAmount, "WETH balance < initial collateral");
        assertEq(usdcBal, 0, "USDC balance != 0");

        console.log("ETH keeper: %e", b1[0]);
        console.log("ETH long: %e", b1[1]);
        assertGe(b1[0], b0[0], "Keeper execution fee");
        assertGe(b1[1], b0[1], "Close execution fee refund");

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
    }
}
