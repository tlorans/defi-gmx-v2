// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IExchangeRouter} from "../interfaces/IExchangeRouter.sol";
import {Order} from "../types/Order.sol";
import {IBaseOrderUtils} from "../types/IBaseOrderUtils.sol";
import {Oracle} from "../lib/Oracle.sol";
import "../Constants.sol";

contract TakeProfitAndStopLoss {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    Oracle immutable oracle;

    constructor(address _oracle) {
        oracle = Oracle(_oracle);
    }

    // Task 1 - Receive execution fee refund from GMX
    receive() external payable {}

    // Task 2 - Create orders to
    // 1. Long ETH with USDC collateral
    // 2. Stop loss for ETH price below 90% of current price
    // 3. Take profit for ETH price above 110% of current price
    function createTakeProfitAndStopLossOrders(
        uint256 leverage,
        uint256 usdcAmount
    ) external payable returns (bytes32[] memory keys) {
        keys = new bytes32[](3);
        uint256 executionFee = 0.1 * 1e18;

        usdc.transferFrom(msg.sender, address(this), usdcAmount);

        // Send execution fee to order vault
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Send USDC to order vault
        usdc.approve(ROUTER, usdcAmount);
        exchangeRouter.sendTokens({
            token: USDC,
            receiver: ORDER_VAULT,
            amount: usdcAmount
        });

        // Create long order to long ETH with USDC collateral
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD);
        // 1 USD = 1e30
        uint256 sizeDeltaUsd = leverage * usdcAmount * 1e24;
        uint256 acceptablePrice = ethPrice * 1e4 * 101 / 100;

        keys[0] = exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: GM_TOKEN_ETH_WETH_USDC,
                    initialCollateralToken: USDC,
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: sizeDeltaUsd,
                    initialCollateralDeltaAmount: 0,
                    triggerPrice: 0,
                    acceptablePrice: acceptablePrice,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketIncrease,
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: true,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );

        // Send execution fee to order vault
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Create stop loss for 90% of current ETH price
        keys[1] = exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: GM_TOKEN_ETH_WETH_USDC,
                    initialCollateralToken: USDC,
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: sizeDeltaUsd,
                    initialCollateralDeltaAmount: usdcAmount,
                    triggerPrice: ethPrice * 1e4 * 90 / 100,
                    acceptablePrice: 0,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.StopLossDecrease,
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: true,
                shouldUnwrapNativeToken: false,
                // NOTE: auto cancel this order when the position is closed
                autoCancel: true,
                referralCode: bytes32(uint256(0))
            })
        );

        // Send execution fee to order vault
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Create order to take profit above 110% of current price
        keys[2] = exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: GM_TOKEN_ETH_WETH_USDC,
                    initialCollateralToken: USDC,
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: sizeDeltaUsd,
                    initialCollateralDeltaAmount: usdcAmount,
                    triggerPrice: ethPrice * 1e4 * 110 / 100,
                    acceptablePrice: ethPrice * 1e4 * 99 / 100,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.LimitDecrease,
                decreasePositionSwapType: Order
                    .DecreasePositionSwapType
                    .SwapPnlTokenToCollateralToken,
                isLong: true,
                shouldUnwrapNativeToken: false,
                // NOTE: auto cancel this order when the position is closed
                autoCancel: true,
                referralCode: bytes32(uint256(0))
            })
        );
    }
}
