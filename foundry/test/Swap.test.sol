// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IOrderHandler} from "../src/interfaces/IOrderHandler.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {
    WETH,
    DAI,
    USDC,
    CHAINLINK_ETH_USD,
    CHAINLINK_DAI_USD,
    CHAINLINK_USDC_USD,
    ORDER_HANDLER,
    CHAINLINK_DATA_STREAM_PROVIDER
} from "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";
// TODO: import from exercises
import {Swap} from "../src/solutions/Swap.sol";

contract SwapTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant dai = IERC20(DAI);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);

    TestHelper helper;
    Swap swap;

    function setUp() public {
        helper = new TestHelper();
        swap = new Swap();
        deal(WETH, address(this), 1000 * 1e18);
    }

    function testSwap() public {
        uint256 executionFee = 1e18;
        uint256 wethAmount = 1e18;
        weth.approve(address(swap), wethAmount);

        bytes32 key = swap.createOrder{value: executionFee}(wethAmount);

        // Execute order
        skip(1);

        address[] memory tokens = new address[](3);
        tokens[0] = DAI;
        tokens[1] = WETH;
        tokens[2] = USDC;

        address[] memory providers = new address[](3);
        providers[0] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[1] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[2] = CHAINLINK_DATA_STREAM_PROVIDER;

        // NOTE: data kept empty for mock calls
        bytes[] memory data = new bytes[](3);

        address[] memory chainlinks = new address[](3);
        chainlinks[0] = CHAINLINK_DAI_USD;
        chainlinks[1] = CHAINLINK_ETH_USD;
        chainlinks[2] = CHAINLINK_USDC_USD;

        uint256[] memory multipliers = new uint256[](3);
        multipliers[0] = 1e4;
        multipliers[1] = 1e4;
        multipliers[2] = 1e16;

        helper.mockOraclePrices({
            tokens: tokens,
            providers: providers,
            data: data,
            chainlinks: chainlinks,
            multipliers: multipliers
        });

        address keeper = helper.getRoleMember(Role.ORDER_KEEPER);

        uint256[] memory b0 = new uint256[](3);
        b0[0] = keeper.balance;
        b0[1] = address(swap).balance;
        b0[2] = dai.balanceOf(address(swap));

        vm.prank(keeper);
        orderHandler.executeOrder(
            key,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        uint256[] memory b1 = new uint256[](3);
        b1[0] = keeper.balance;
        b1[1] = address(swap).balance;
        b1[2] = dai.balanceOf(address(swap));

        console.log("ETH keeper: %e", b1[0]);
        console.log("ETH swap: %e", b1[1]);
        console.log("DAI swap: %e", b1[2]);

        assertGe(b1[0], b0[0], "Keeper execution fee");
        assertGe(b1[1], b0[1], "Swap execution fee refund");
        assertGe(b1[2], b0[2], "Swap DAI");
    }
}
