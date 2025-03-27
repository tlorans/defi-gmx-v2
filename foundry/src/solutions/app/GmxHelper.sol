// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// TODO: remove unused
import {IERC20} from "../../interfaces/IERC20.sol";
import {IExchangeRouter} from "../../interfaces/IExchangeRouter.sol";
import {IDataStore} from "../../interfaces/IDataStore.sol";
import {Keys} from "../../lib/Keys.sol";
import {Order} from "../../types/Order.sol";
import {Position} from "../../types/Position.sol";
import {Market} from "../../types/Market.sol";
import {MarketUtils} from "../../types/MarketUtils.sol";
import {Price} from "../../types/Price.sol";
import {IBaseOrderUtils} from "../../types/IBaseOrderUtils.sol";
import {Oracle} from "../../lib/Oracle.sol";
import "../../Constants.sol";

// TODO: callback here?

contract GmxHelper {
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);

    IERC20 public immutable marketToken;
    IERC20 public immutable longToken;
    IERC20 public immutable shortToken;

    constructor(address _marketToken, address _longToken, address _shortToken) {
        marketToken = IERC20(_marketToken);
        longToken = IERC20(_marketToken);
        shortToken = IERC20(_shortToken);
    }

    receive() external payable {}

    function totalValueInToken() public view returns (uint256) {}

    function createIncreaseShortPositionOrder()
        public
        returns (bytes32 orderKey)
    {
        // TODO: check funding fee is positive
        // TODO: param
        uint256 executionFee;
        uint256 sizeDeltaUsd;
        uint256 acceptablePrice;
        uint256 longTokenAmount;

        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        longToken.approve(ROUTER, longTokenAmount);
        exchangeRouter.sendTokens({
            token: address(longToken),
            receiver: ORDER_VAULT,
            amount: longTokenAmount
        });

        return exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: address(marketToken),
                    initialCollateralToken: address(longToken),
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

    function createDecreaseShortPositionOrder()
        public
        returns (bytes32 orderKey)
    {
        uint256 executionFee;
        uint256 acceptablePrice;
        // TODO: recalculate  sizeDeltaUsd based on collateral amount
        uint256 sizeDeltaUsd;
        uint256 collateralAmount;
        // new position size = collateral amount * collateral price

        // TODO: check that position exists?

        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        return exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: address(this),
                    cancellationReceiver: address(0),
                    callbackContract: address(0),
                    uiFeeReceiver: address(0),
                    market: address(marketToken),
                    initialCollateralToken: address(longToken),
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: sizeDeltaUsd,
                    initialCollateralDeltaAmount: collateralAmount,
                    triggerPrice: 0,
                    acceptablePrice: acceptablePrice,
                    executionFee: executionFee,
                    callbackGasLimit: 0,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketDecrease,
                decreasePositionSwapType: Order.DecreasePositionSwapType.NoSwap,
                isLong: false,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );
    }

    function cancelOrder(bytes32 orderKey) public {
        // TODO: validate order?
        exchangeRouter.cancelOrder(orderKey);
    }

    // TODO: when updated
    function getClaimableAmount(address token) public view returns (uint256) {
        return dataStore.getUint(
            Keys.claimableFundingAmountKey(
                address(marketToken), token, address(this)
            )
        );
    }

    function claimFundingFees() public {
        address[] memory markets = new address[](2);
        markets[0] = address(marketToken);
        markets[1] = address(marketToken);

        address[] memory tokens = new address[](2);
        tokens[0] = address(longToken);
        tokens[1] = address(shortToken);

        exchangeRouter.claimFundingFees({
            markets: markets,
            tokens: tokens,
            receiver: address(this)
        });
    }
}
