// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IExchangeRouter} from "../interfaces/IExchangeRouter.sol";
import {IOrderHandler} from "../interfaces/IOrderHandler.sol";
import {IReader} from "../interfaces/IReader.sol";
import {Order} from "../types/Order.sol";
import {Position} from "../types/Position.sol";
import {IBaseOrderUtils} from "../types/IBaseOrderUtils.sol";
import {Oracle} from "../lib/Oracle.sol";
import {
    WETH,
    USDC,
    DATA_STORE,
    READER,
    ROUTER,
    EXCHANGE_ROUTER,
    ORDER_VAULT,
    GM_TOKEN_WETH_USDC,
    CHAINLINK_ETH_USD,
    CHAINLINK_USDC_USD
} from "../Constants.sol";

contract Short {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IReader constant reader = IReader(READER);
    Oracle immutable oracle;

    constructor(address _oracle) {
        oracle = Oracle(_oracle);
    }

    // Receive execution fee refund from GMX
    receive() external payable {}

    // Create order to short WETH with USDC collateral
    function createShortOrder(uint256 usdcAmount)
        external
        payable
        returns (bytes32 key)
    {
        uint256 executionFee = 0.1 * 1e18;

        usdc.transferFrom(msg.sender, address(this), usdcAmount);

        uint256 usdcPrice = oracle.getPrice(CHAINLINK_USDC_USD);
        // TODO: how to calculate sizeDeltaUsd
        // 1 USD = 1e30
        uint256 sizeDeltaUsd = 10 * usdcAmount * usdcPrice * 1e16;
        // NOTE:
        // increase order:
        // - long: executionPrice should be smaller than acceptablePrice
        // - short: executionPrice should be larger than acceptablePrice
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD) * 1e4;
        uint256 acceptablePrice = ethPrice * 99 / 100;

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
        return exchangeRouter.createOrder(
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
                isLong: false,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );
    }

    function createCloseOrder() external payable returns (bytes32 key) {
        uint256 executionFee = 0.1 * 1e18;

        Position.Props memory position = getPosition(getPositionKey());
        require(position.numbers.sizeInUsd > 0, "position size = 0");

        // NOTE:
        // decrease order:
        // - long: executionPrice should be larger than acceptablePrice
        // - short: executionPrice should be smaller than acceptablePrice
        uint256 ethPrice = oracle.getPrice(CHAINLINK_ETH_USD) * 1e4;
        uint256 acceptablePrice = ethPrice * 110 / 100;

        // Send gas fee
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        // Create order
        return exchangeRouter.createOrder(
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
                    sizeDeltaUsd: position.numbers.sizeInUsd,
                    initialCollateralDeltaAmount: position.numbers.collateralAmount,
                    triggerPrice: 0,
                    acceptablePrice: acceptablePrice,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketDecrease,
                // TODO: wat dis?
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: false,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );
    }

    function getPositionKey() public view returns (bytes32 key) {
        return Position.getPositionKey({
            account: address(this),
            market: GM_TOKEN_WETH_USDC,
            collateralToken: USDC,
            isLong: false
        });
    }

    function getPosition(bytes32 key)
        public
        view
        returns (Position.Props memory)
    {
        return reader.getPosition(DATA_STORE, key);
    }
}
