// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import {IExchangeRouter} from "../src/interfaces/IExchangeRouter.sol";
import {IOrderHandler} from "../src/interfaces/IOrderHandler.sol";
import {Order} from "../src/types/Order.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {IBaseOrderUtils} from "../src/types/IBaseOrderUtils.sol";
import {
    WETH,
    DAI,
    USDC,
    CHAINLINK_ETH_USD,
    CHAINLINK_DAI_USD,
    CHAINLINK_USDC_USD,
    ROUTER,
    EXCHANGE_ROUTER,
    ORDER_HANDLER,
    ORDER_VAULT,
    CHAINLINK_DATA_STREAM_PROVIDER,
    GM_TOKEN_USDC_DAI,
    GM_TOKEN_WETH_USDC
} from "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";

contract Swap {}

contract SwapTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant dai = IERC20(DAI);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);

    TestHelper helper;
    Swap swap;

    function setUp() public {
        helper = new TestHelper();
        swap = new Swap();
        deal(DAI, address(this), 1000 * 1e18);
        deal(WETH, address(this), 1000 * 1e18);
    }

    receive() external payable {}

    function testSwap() public {
        uint256 executionFee = 0.1 * 1e18;
        uint256 wethAmount = 1e18;

        // Send gas fee
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Send token
        weth.approve(ROUTER, wethAmount);
        exchangeRouter.sendTokens({
            token: WETH,
            receiver: ORDER_VAULT,
            amount: wethAmount
        });

        // Create order
        // TODO: how to specify swap path? -> initialCollateralToken + gm tokens
        address[] memory swapPath = new address[](2);
        swapPath[0] = GM_TOKEN_WETH_USDC;
        swapPath[1] = GM_TOKEN_USDC_DAI;

        bytes32 key = exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: address(0),
                    initialCollateralToken: WETH,
                    swapPath: swapPath
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: 0,
                    initialCollateralDeltaAmount: 0,
                    triggerPrice: 0,
                    acceptablePrice: 0,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 1,
                    // NOTE: must be 0 for market swap
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketSwap,
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: false,
                shouldUnwrapNativeToken: true,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );

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

        uint256[] memory diffs = new uint256[](3);
        diffs[0] = keeper.balance;
        diffs[1] = address(this).balance;
        diffs[2] = dai.balanceOf(address(this));

        vm.prank(keeper);
        orderHandler.executeOrder(
            key,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        diffs[0] = keeper.balance - diffs[0];
        diffs[1] = address(this).balance - diffs[1];
        diffs[2] = dai.balanceOf(address(this)) - diffs[2];

        console.log("ETH user: %e", diffs[1]);
        console.log("ETH keeper: %e", diffs[0]);
        console.log("DAI %e", diffs[2]);
    }
}
