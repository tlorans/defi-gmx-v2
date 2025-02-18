// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

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
    ROUTER,
    EXCHANGE_ROUTER,
    ORDER_HANDLER,
    ORDER_VAULT,
    CHAINLINK_DATA_STREAM_PROVIDER,
    GM_TOKEN_USDC_DAI,
    GM_TOKEN_WETH_USDC
} from "../src/Constants.sol";

contract Swap {}

contract SwapTest is Test {
    IERC20 weth = IERC20(WETH);
    IERC20 dai = IERC20(DAI);
    IExchangeRouter exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IOrderHandler orderHandler = IOrderHandler(ORDER_HANDLER);

    Swap swap;

    function setUp() public {
        swap = new Swap();
        deal(DAI, address(this), 1000 * 1e18);
        deal(WETH, address(this), 1000 * 1e18);
    }

    function test() public {
        // TODO: calculate gas to send
        uint256 gasAmount = 0.1 * 1e18;
        uint256 wntAmount = 1e18;

        // Send gas fee
        exchangeRouter.sendWnt{value: wntAmount}({
            receiver: ORDER_VAULT,
            amount: gasAmount
        });

        // Send token
        weth.approve(ROUTER, wntAmount);
        exchangeRouter.sendTokens({
            token: WETH,
            receiver: ORDER_VAULT,
            amount: wntAmount
        });

        // Create order
        address[] memory swapPath = new address[](2);
        swapPath[0] = GM_TOKEN_USDC_DAI;
        swapPath[1] = GM_TOKEN_WETH_USDC;

        bytes32 key = exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    // TODO: wat dis?
                    market: address(0),
                    initialCollateralToken: WETH,
                    swapPath: swapPath
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    // TODO: wat dis?
                    sizeDeltaUsd: 0,
                    initialCollateralDeltaAmount: 0,
                    triggerPrice: 0,
                    acceptablePrice: 0,
                    // TODO: get estimate
                    executionFee: 0.1 * 1e18,
                    callbackGasLimit: 0,
                    // TODO: output amount
                    minOutputAmount: 1,
                    // TODO: wat dis?
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketSwap,
                // TODO: wat dis?
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: false,
                shouldUnwrapNativeToken: true,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );

        address[] memory tokens = new address[](3);
        tokens[0] = DAI;
        tokens[1] = WETH;
        tokens[2] = USDC;

        address[] memory providers = new address[](3);
        providers[0] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[1] = CHAINLINK_DATA_STREAM_PROVIDER;
        providers[2] = CHAINLINK_DATA_STREAM_PROVIDER;

        bytes[] memory data = new bytes[](3);

        orderHandler.executeOrder(
            key,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );
    }
}
