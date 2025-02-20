// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";

import {IERC20} from "../src/interfaces/IERC20.sol";
import {IExchangeRouter} from "../src/interfaces/IExchangeRouter.sol";
import {IOrderHandler} from "../src/interfaces/IOrderHandler.sol";
import {IRoleStore} from "../src/interfaces/IRoleStore.sol";
import {IOracle} from "../src/interfaces/IOracle.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
import {IPriceFeed} from "../src/interfaces/IPriceFeed.sol";
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
    ROLE_STORE,
    ORACLE,
    ROUTER,
    EXCHANGE_ROUTER,
    ORDER_HANDLER,
    ORDER_VAULT,
    CHAINLINK_DATA_STREAM_PROVIDER,
    GM_TOKEN_USDC_DAI,
    GM_TOKEN_WETH_USDC
} from "../src/Constants.sol";
import {Role} from "../src/lib/Role.sol";
import "../src/lib/Errors.sol";

contract Swap {}

contract SwapTest is Test {
    IERC20 weth = IERC20(WETH);
    IERC20 dai = IERC20(DAI);
    IRoleStore roleStore = IRoleStore(ROLE_STORE);
    IExchangeRouter exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IOrderHandler orderHandler = IOrderHandler(ORDER_HANDLER);
    IOracle oracle = IOracle(ORACLE);
    IChainlinkDataStreamProvider provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

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

        console.log("ETH: %e", address(this).balance);

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
                    // TODO: wat dis? - must be 0 for market swap
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

        /*
        {
            (, int256 a,,,) = IPriceFeed(CHAINLINK_ETH_USD).latestRoundData();
            console.log("ETH %e", a);
        }
        {
            (, int256 a,,,) = IPriceFeed(CHAINLINK_DAI_USD).latestRoundData();
            console.log("DAI %e", a);
        }
        {
            (, int256 a,,,) = IPriceFeed(CHAINLINK_USDC_USD).latestRoundData();
            console.log("USDC %e", a);
        }

        return;
        */

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

        uint256[] memory prices = new uint256[](3);
        prices[0] = 1e12;
        prices[1] = 2719 * 1e12;
        // TODO: why 1e24?
        prices[2] = 1e24;

        uint256 b0 = block.timestamp;

        for (uint256 i = 0; i < tokens.length; i++) {
            vm.mockCall(
                address(provider),
                abi.encodeCall(
                    IChainlinkDataStreamProvider.getOraclePrice,
                    (tokens[i], data[i])
                ),
                abi.encode(
                    OracleUtils.ValidatedPrice({
                        token: tokens[i],
                        // 1e12 = 1 USD
                        min: prices[i] * 99999 / 100000,
                        max: prices[i] * 100001 / 100000,
                        // TODO: why b0 + 1?
                        timestamp: b0 + 1,
                        provider: providers[i]
                    })
                )
            );
        }

        console.log("b0", b0);
        console.log("block", block.timestamp);

        address[] memory addrs =
            roleStore.getRoleMembers(Role.ORDER_KEEPER, 0, 1);

        console.log("ETH keeper: %e", address(addrs[0]).balance);

        vm.prank(addrs[0]);
        orderHandler.executeOrder(
            key,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        console.log("ETH keeper: %e", address(addrs[0]).balance);
        console.log("ETH: %e", address(this).balance);
    }
}
