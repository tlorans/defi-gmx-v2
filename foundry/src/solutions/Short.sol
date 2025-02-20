// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../interfaces/IERC20.sol";
import {IExchangeRouter} from "../interfaces/IExchangeRouter.sol";
import {IOrderHandler} from "../interfaces/IOrderHandler.sol";
import {Order} from "../types/Order.sol";
import {IBaseOrderUtils} from "../types/IBaseOrderUtils.sol";
import {
    WETH,
    USDC,
    ROUTER,
    EXCHANGE_ROUTER,
    ORDER_VAULT,
    GM_TOKEN_WETH_USDC
} from "../Constants.sol";

contract Short {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);

    // Receive execution fee refund from GMX
    receive() external payable {}

    // Create order to short WETH with USDC collateral
    function createOrder(uint256 usdcAmount)
        external
        payable
        returns (bytes32 key)
    {
        uint256 executionFee = 0.1 * 1e18;

        usdc.transferFrom(msg.sender, address(this), usdcAmount);

        // Send gas fee
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Send token
        usdc.approve(ROUTER, usdcAmount);
        exchangeRouter.sendTokens({
            token: USDC,
            receiver: ORDER_VAULT,
            amount: usdcAmount
        });

        // Create order
        key = exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: GM_TOKEN_WETH_USDC,
                    initialCollateralToken: USDC,
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    // TODO: how to calculate
                    sizeDeltaUsd: 959985411169984104000000000000000,
                    initialCollateralDeltaAmount: 0,
                    triggerPrice: 0,
                    // TODO: 1e12 = 1 USD?
                    // TODO: set price?
                    acceptablePrice: 1,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    // NOTE: must be 0 for market swap
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketIncrease,
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: false,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );
    }
}
