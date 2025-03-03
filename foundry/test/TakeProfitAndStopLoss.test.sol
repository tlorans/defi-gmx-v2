// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// TODO: remove unused code
import {Test, console} from "forge-std/Test.sol";
import "./lib/TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IReader} from "../src/interfaces/IReader.sol";
import {IOrderHandler} from "../src/interfaces/IOrderHandler.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {Order} from "../src/types/Order.sol";
import {Position} from "../src/types/Position.sol";
import "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";
import {Oracle} from "../src/lib/Oracle.sol";
// TODO: import from exercises
import {TakeProfitAndStopLoss} from "../src/solutions/TakeProfitAndStopLoss.sol";

contract TakeProfitAndStopLossTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);
    IReader constant reader = IReader(READER);

    TestHelper testHelper;
    Oracle oracle;
    TakeProfitAndStopLoss tpsl;
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
        tpsl = new TakeProfitAndStopLoss(address(oracle));
        deal(USDC, address(this), 1000 * 1e18);

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

    function testTakeProfitAndStopLoss() public {
        uint256 executionFee = 1e18;
        uint256 usdcAmount = 1000 * 1e6;
        usdc.approve(address(tpsl), usdcAmount);

        bytes32[] memory keys =
            tpsl.createTakeProfitAndStopLossOrders{value: executionFee}(usdcAmount);

        console.logBytes32(keys[0]);
        console.logBytes32(keys[1]);
        console.logBytes32(keys[2]);

        Order.Props memory order = reader.getOrder(DATA_STORE, keys[0]);
        assertEq(order.addresses.receiver, address(tpsl), "order receiver");
        assertEq(
            uint256(order.numbers.orderType),
            uint256(Order.OrderType.MarketIncrease),
            "order type"
        );
        assertEq(order.flags.isLong, true, "not long");

        // Execute create long position
        skip(1);

        testHelper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        vm.prank(keeper);
        orderHandler.executeOrder(
            keys[0],
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        bytes32 positionKey = Position.getPositionKey({
            account: address(tpsl),
            market: GM_TOKEN_ETH_WETH_USDC,
            collateralToken: USDC,
            isLong: true
        });

        Position.Props memory position;
        position = reader.getPosition(DATA_STORE, positionKey);

        console.log("pos account", position.addresses.account);
        console.log("pos market", position.addresses.market);
        console.log("pos collateral amount %e", position.numbers.collateralAmount);
        console.log("pos size %e", position.numbers.sizeInUsd);

        assertEq(uint256(1), uint256(0));
        return;

        // Execute stop loss
        skip(1);

        oracles[0].deltaPrice = 0;
        oracles[1].deltaPrice = -20;

        testHelper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            oracles: oracles
        });

        vm.prank(keeper);
        orderHandler.executeOrder(
            keys[1],
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        /*
        testHelper.set("ETH keeper after", keeper.balance);
        testHelper.set("ETH long after", address(long).balance);

        console.log("ETH keeper: %e", testHelper.get("ETH keeper after"));
        console.log("ETH long: %e", testHelper.get("ETH long after"));

        assertGe(
            testHelper.get("ETH keeper after"),
            testHelper.get("ETH keeper before"),
            "Keeper execution fee"
        );
        assertGe(
            testHelper.get("ETH long after"),
            testHelper.get("ETH long before"),
            "Long execution fee refund"
        );

        bytes32 positionKey = Position.getPositionKey({
            account: address(long),
            market: GM_TOKEN_ETH_WETH_USDC,
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
        */
    }
}
