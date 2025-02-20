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

contract GmxTestHelper is Test {
    IRoleStore constant roleStore = IRoleStore(ROLE_STORE);
    IChainlinkDataStreamProvider constant provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

    function getRoleMember(bytes32 key) public view returns (address) {
        address[] memory addrs = roleStore.getRoleMembers(key, 0, 1);
        return addrs[0];
    }

    function mockOraclePrices(
        address[] memory tokens,
        address[] memory providers,
        bytes[] memory data,
        address[] memory chainlinks,
        uint256[] memory multipliers
    ) public returns (uint256[] memory prices) {
        uint256 n = tokens.length;

        prices = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            (, int256 answer,,,) = IPriceFeed(chainlinks[i]).latestRoundData();
            prices[i] = uint256(answer) * multipliers[i];
        }

        for (uint256 i = 0; i < n; i++) {
            vm.mockCall(
                address(provider),
                abi.encodeCall(
                    IChainlinkDataStreamProvider.getOraclePrice,
                    (tokens[i], data[i])
                ),
                abi.encode(
                    OracleUtils.ValidatedPrice({
                        token: tokens[i],
                        min: prices[i] * 999 / 1000,
                        max: prices[i] * 1001 / 1000,
                        // NOTE: oracle timestamp must be >= order updated timestamp
                        timestamp: block.timestamp,
                        provider: providers[i]
                    })
                )
            );
        }
    }
}

contract SwapTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant dai = IERC20(DAI);
    IRoleStore constant roleStore = IRoleStore(ROLE_STORE);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IOrderHandler constant orderHandler = IOrderHandler(ORDER_HANDLER);
    IOracle constant oracle = IOracle(ORACLE);
    IChainlinkDataStreamProvider constant provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

    Swap swap;
    GmxTestHelper helper;

    function setUp() public {
        helper = new GmxTestHelper();
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

        console.log("ETH keeper: %e", keeper.balance);

        vm.prank(keeper);
        orderHandler.executeOrder(
            key,
            OracleUtils.SetPricesParams({
                tokens: tokens,
                providers: providers,
                data: data
            })
        );

        console.log("ETH keeper: %e", keeper.balance);
        console.log("ETH: %e", address(this).balance);
        console.log("DAI %e", dai.balanceOf(address(this)));
    }
}
