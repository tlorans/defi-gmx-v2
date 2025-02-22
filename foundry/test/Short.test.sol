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
import {Short} from "../src/solutions/Short.sol";

contract ShortTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);
    IReader constant reader = IReader(READER);

    TestHelper helper;
    Oracle oracle;
    Short short;

    function setUp() public {
        helper = new TestHelper();
        oracle = new Oracle();
        short = new Short(address(oracle));
        deal(USDC, address(this), 1000 * 1e18);
    }

    function testShort() public {
        uint256 executionFee = 1e18;
        uint256 usdcAmount = 100 * 1e6;
        usdc.approve(address(short), usdcAmount);

        bytes32 key = short.createShortOrder{value: executionFee}(usdcAmount);

        Order.Props memory order = reader.getOrder(DATA_STORE, key);
        assertEq(order.addresses.receiver, address(short), "order receiver");
        assertEq(
            uint256(order.numbers.orderType),
            uint256(Order.OrderType.MarketIncrease),
            "order type"
        );

        // Execute order
        skip(1);

        address[] memory tokens = new address[](2);
        tokens[0] = USDC;
        tokens[1] = WETH;

        address[] memory providers = new address[](2);
        providers[0] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[1] = CHAINLINK_DATA_STREAM_PROVIDER;

        // NOTE: data kept empty for mock calls
        bytes[] memory data = new bytes[](2);

        address[] memory chainlinks = new address[](2);
        chainlinks[0] = CHAINLINK_USDC_USD;
        chainlinks[1] = CHAINLINK_ETH_USD;

        uint256[] memory multipliers = new uint256[](2);
        multipliers[0] = 1e16;
        multipliers[1] = 1e4;

        helper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            chainlinks: chainlinks,
            multipliers: multipliers
        });

        address keeper = helper.getRoleMember(Role.ORDER_KEEPER);

        uint256[] memory b0 = new uint256[](2);
        b0[0] = keeper.balance;
        b0[1] = address(short).balance;

        vm.prank(keeper);
        orderHandler.executeOrder(
            key,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        uint256[] memory b1 = new uint256[](2);
        b1[0] = keeper.balance;
        b1[1] = address(short).balance;

        console.log("ETH keeper: %e", b1[0]);
        console.log("ETH short: %e", b1[1]);
        assertGe(b1[0], b0[0], "Keeper execution fee");
        assertGe(b1[1], b0[1], "Short execution fee refund");

        bytes32 positionKey = Position.getPositionKey({
            account: address(short),
            market: GM_TOKEN_WETH_USDC,
            collateralToken: USDC,
            isLong: false
        });

        assertEq(short.getPositionKey(), positionKey, "position key");

        Position.Props memory position =
            reader.getPosition(DATA_STORE, positionKey);
        console.log("pos.sizeInUsd %e", position.numbers.sizeInUsd);
        console.log("pos.sizeInTokens %e", position.numbers.sizeInTokens);
        console.log(
            "pos.collateralAmount %e", position.numbers.collateralAmount
        );

        assertGt(
            position.numbers.sizeInUsd,
            usdcAmount * 1e24,
            "position size <= collateral amount"
        );
        assertGt(
            position.numbers.collateralAmount,
            0,
            "position collateral amount = 0"
        );

        assertEq(
            position.addresses.account,
            short.getPosition(positionKey).addresses.account,
            "position"
        );
    }
}
