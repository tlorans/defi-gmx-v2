// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// TODO: remove unused
import {console} from "forge-std/Test.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {IExchangeRouter} from "../../interfaces/IExchangeRouter.sol";
import {IDataStore} from "../../interfaces/IDataStore.sol";
import {IReader} from "../../interfaces/IReader.sol";
import {Math} from "../../lib/Math.sol";
import {Keys} from "../../lib/Keys.sol";
import {Order} from "../../types/Order.sol";
import {Position} from "../../types/Position.sol";
import {Market} from "../../types/Market.sol";
import {MarketUtils} from "../../types/MarketUtils.sol";
import {Price} from "../../types/Price.sol";
import {ReaderPositionUtils} from "../../types/ReaderPositionUtils.sol";
import {IBaseOrderUtils} from "../../types/IBaseOrderUtils.sol";
import {Oracle} from "../../lib/Oracle.sol";
import "../../Constants.sol";

abstract contract GmxHelper {
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IReader constant reader = IReader(READER);
    // Note: both long and short token price must return 8 decimals (1e8 = 1 USD)
    uint256 private constant CHAINLINK_MULTIPLIER = 1e8;
    uint256 private constant CHAINLINK_DECIMALS = 8;

    IERC20 public immutable marketToken;
    IERC20 public immutable longToken;
    IERC20 public immutable shortToken;
    uint256 public immutable longTokenDecimals;
    uint256 public immutable shortTokenDecimals;
    uint256 public immutable longTokenMultiplier;
    uint256 public immutable shortTokenMultiplier;
    address public immutable chainlinkLongToken;
    address public immutable chainlinkShortToken;
    Oracle immutable oracle;

    constructor(
        address _marketToken,
        address _longToken,
        address _shortToken,
        uint256 _longTokenDecimals,
        uint256 _shortTokenDecimals,
        address _chainlinkLongToken,
        address _chainlinkShortToken,
        address _oracle
    ) {
        marketToken = IERC20(_marketToken);
        longToken = IERC20(_longToken);
        shortToken = IERC20(_shortToken);

        longTokenDecimals = _longTokenDecimals;
        shortTokenDecimals = _shortTokenDecimals;

        longTokenMultiplier = 10 ** longTokenDecimals;
        shortTokenMultiplier = 10 ** longTokenDecimals;

        chainlinkLongToken = _chainlinkLongToken;
        chainlinkShortToken = _chainlinkShortToken;
        oracle = Oracle(_oracle);
    }

    function getPositionKey() internal view returns (bytes32 positionKey) {
        return Position.getPositionKey({
            account: address(this),
            market: address(marketToken),
            collateralToken: address(longToken),
            isLong: false
        });
    }

    function getPosition(bytes32 positionKey)
        internal
        view
        returns (Position.Props memory)
    {
        return reader.getPosition(address(dataStore), positionKey);
    }

    function getPositionPnlInToken() internal view returns (int256) {
        bytes32 positionKey = getPositionKey();
        Position.Props memory position = getPosition(positionKey);
        if (position.numbers.sizeInUsd == 0) {
            return 0;
        }

        uint256 longTokenPrice = oracle.getPrice(chainlinkLongToken);
        uint256 shortTokenPrice = oracle.getPrice(chainlinkShortToken);

        // +/- 1% of current prices
        uint256 minLongTokenPrice = longTokenPrice
            * 10 ** (30 - CHAINLINK_DECIMALS - longTokenDecimals) * 999 / 1000;
        uint256 maxLongTokenPrice = longTokenPrice
            * 10 ** (30 - CHAINLINK_DECIMALS - longTokenDecimals) * 1001 / 1000;

        MarketUtils.MarketPrices memory prices = MarketUtils.MarketPrices({
            indexTokenPrice: Price.Props({
                min: minLongTokenPrice,
                max: maxLongTokenPrice
            }),
            longTokenPrice: Price.Props({
                min: minLongTokenPrice,
                max: maxLongTokenPrice
            }),
            shortTokenPrice: Price.Props({
                min: shortTokenPrice
                    * 10 ** (30 - CHAINLINK_DECIMALS - shortTokenDecimals) * 999 / 1000,
                max: shortTokenPrice
                    * 10 ** (30 - CHAINLINK_DECIMALS - shortTokenDecimals) * 1001 / 1000
            })
        });

        ReaderPositionUtils.PositionInfo memory info = reader.getPositionInfo({
            dataStore: address(dataStore),
            referralStorage: REFERRAL_STORAGE,
            positionKey: positionKey,
            prices: prices,
            sizeDeltaUsd: 0,
            uiFeeReceiver: address(0),
            usePositionSizeAsSizeDeltaUsd: true
        });

        // TODO: remove
        // pnl after price impact / execution price? - fees
        console.log("------- PNL -------------");
        console.log("pnl USD %e", info.pnlAfterPriceImpactUsd);
        uint256 pnl = 0;
        if (info.pnlAfterPriceImpactUsd < 0) {
            pnl = uint256(-info.pnlAfterPriceImpactUsd)
                / (longTokenPrice * 101 / 100) / 1e4;
            console.log(
                "pnl ETH %e",
                uint256(-info.pnlAfterPriceImpactUsd)
                    / (longTokenPrice * 101 / 100) / 1e4
            );
        }
        console.log("price impact %e", info.executionPriceResult.priceImpactUsd);
        console.log(
            "execution price %e", info.executionPriceResult.executionPrice
        );
        console.log("long token price %e", longTokenPrice * 1e4);
        console.log("total cost %e", info.fees.totalCostAmount);
        console.log("col %e", position.numbers.collateralAmount);
        console.log(
            "rem %e",
            position.numbers.collateralAmount - info.fees.totalCostAmount
        );

        console.log("----- calc ---");
        int256 collateralUsd =
            Math.toInt256(position.numbers.collateralAmount * minLongTokenPrice);
        int256 collateralCostUsd =
            Math.toInt256(info.fees.totalCostAmount * minLongTokenPrice);

        int256 remainingCollateralUsd =
            collateralUsd + info.pnlAfterPriceImpactUsd - collateralCostUsd;

        int256 remainingCollateral =
            remainingCollateralUsd / Math.toInt256(minLongTokenPrice);

        console.log("collateral usd %e", collateralUsd);
        console.log("collateral cost usd %e", collateralCostUsd);
        console.log("rem col usd %e", remainingCollateralUsd);
        console.log("rem col %e", remainingCollateral);
        console.log("--------------");

        return remainingCollateral;
    }

    function getSizeDeltaUsd(
        uint256 longTokenPrice,
        uint256 sizeInUsd,
        uint256 collateralAmount,
        uint256 longTokenAmount,
        bool isIncrease
    ) internal view returns (uint256 sizeDeltaUsd) {
        if (isIncrease) {
            // new position size = long token price * new collateral amount
            // new collateral amount = position.collateralAmount + longTokenAmount
            // sizeDeltaUsd = new position size - position.sizeInUsd
            uint256 newCollateralAmount = collateralAmount + longTokenAmount;
            uint256 newPositionSizeInUsd = newCollateralAmount * longTokenPrice
                * 10 ** (30 - longTokenDecimals - CHAINLINK_DECIMALS);
            sizeDeltaUsd = newPositionSizeInUsd - sizeInUsd;
        } else {
            // new position size = long token price * new collateral amount
            // new collateral amount = position.collateralAmount - longTokenAmount
            // sizeDeltaUsd = new position size - position.sizeInUsd
            uint256 newCollateralAmount = collateralAmount - longTokenAmount;
            uint256 newPositionSizeInUsd = newCollateralAmount * longTokenPrice
                * 10 ** (30 - longTokenDecimals - CHAINLINK_DECIMALS);
            sizeDeltaUsd = sizeInUsd - newPositionSizeInUsd;
        }
    }

    // TODO: handle order is executed and resulted in error
    function createIncreaseShortPositionOrder(
        uint256 executionFee,
        uint256 longTokenAmount
    ) internal returns (bytes32 orderKey) {
        uint256 longTokenPrice = oracle.getPrice(chainlinkLongToken);
        bytes32 positionKey = getPositionKey();
        Position.Props memory position = getPosition(positionKey);

        uint256 sizeDeltaUsd = getSizeDeltaUsd({
            longTokenPrice: longTokenPrice,
            sizeInUsd: position.numbers.sizeInUsd,
            collateralAmount: position.numbers.collateralAmount,
            longTokenAmount: longTokenAmount,
            isIncrease: true
        });

        // 90% of current price
        uint256 acceptablePrice =
            longTokenPrice * 1e12 / CHAINLINK_MULTIPLIER * 90 / 100;

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
                    // Set by amount of collateral sent to ORDER_VAULT
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

    function createDecreaseShortPositionOrder(
        uint256 executionFee,
        uint256 longTokenAmount,
        address receiver,
        address callbackContract,
        uint256 callbackGasLimit
    ) internal returns (bytes32 orderKey) {
        uint256 longTokenPrice = oracle.getPrice(chainlinkLongToken);
        bytes32 positionKey = getPositionKey();
        Position.Props memory position = getPosition(positionKey);

        require(position.numbers.sizeInUsd > 0, "position size = 0");
        // TODO: require longTokenAmount <= position.sizeInTokens or position.collateralAmount?

        longTokenAmount =
            Math.min(longTokenAmount, position.numbers.collateralAmount);
        require(longTokenAmount > 0, "long token amount = 0");

        uint256 sizeDeltaUsd = getSizeDeltaUsd({
            longTokenPrice: longTokenPrice,
            sizeInUsd: position.numbers.sizeInUsd,
            collateralAmount: position.numbers.collateralAmount,
            longTokenAmount: longTokenAmount,
            isIncrease: false
        });

        // 110% of current price
        uint256 acceptablePrice =
            longTokenPrice * 1e12 / CHAINLINK_MULTIPLIER * 110 / 100;

        exchangeRouter.sendWnt{value: executionFee}({
            receiver: ORDER_VAULT,
            amount: executionFee
        });

        return exchangeRouter.createOrder(
            IBaseOrderUtils.CreateOrderParams({
                addresses: IBaseOrderUtils.CreateOrderParamsAddresses({
                    receiver: receiver,
                    cancellationReceiver: address(0),
                    callbackContract: callbackContract,
                    uiFeeReceiver: address(0),
                    market: address(marketToken),
                    initialCollateralToken: address(longToken),
                    swapPath: new address[](0)
                }),
                numbers: IBaseOrderUtils.CreateOrderParamsNumbers({
                    sizeDeltaUsd: sizeDeltaUsd,
                    initialCollateralDeltaAmount: longTokenAmount,
                    triggerPrice: 0,
                    acceptablePrice: acceptablePrice,
                    executionFee: executionFee,
                    callbackGasLimit: callbackGasLimit,
                    minOutputAmount: 0,
                    validFromTime: 0
                }),
                orderType: Order.OrderType.MarketDecrease,
                decreasePositionSwapType: Order
                    .DecreasePositionSwapType
                    .SwapPnlTokenToCollateralToken,
                isLong: false,
                shouldUnwrapNativeToken: false,
                autoCancel: false,
                referralCode: bytes32(uint256(0))
            })
        );
    }

    function cancelOrder(bytes32 orderKey) internal {
        // TODO: validate order?
        exchangeRouter.cancelOrder(orderKey);
    }

    function claimFundingFees() internal {
        address[] memory markets = new address[](1);
        markets[0] = address(marketToken);

        address[] memory tokens = new address[](1);
        tokens[0] = address(longToken);

        exchangeRouter.claimFundingFees({
            markets: markets,
            tokens: tokens,
            receiver: address(this)
        });
    }
}
