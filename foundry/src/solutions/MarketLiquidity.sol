// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IExchangeRouter} from "../interfaces/IExchangeRouter.sol";
import {IDataStore} from "../interfaces/IDataStore.sol";
import {IReader} from "../interfaces/IReader.sol";
import {Order} from "../types/Order.sol";
import {Market} from "../types/Market.sol";
import {Price} from "../types/Price.sol";
import {DepositUtils} from "../types/DepositUtils.sol";
import {WithdrawalUtils} from "../types/WithdrawalUtils.sol";
import {Keys} from "../lib/Keys.sol";
import "../Constants.sol";

contract MarketLiquidity {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IERC20 constant gmToken = IERC20(GM_TOKEN_BTC_WBTC_USDC);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IDataStore constant dataStore = IDataStore(DATA_STORE);
    IReader constant reader = IReader(READER);

    // Task 1 - Receive execution fee refund from GMX
    receive() external payable {}

    /*
    function getMarketTokenPrice(
        DataStore dataStore,
        Market.Props memory market,
        Price.Props memory indexTokenPrice,
        Price.Props memory longTokenPrice,
        Price.Props memory shortTokenPrice,
        bytes32 pnlFactorType,
        bool maximize
    ) external view returns (int256, MarketPoolValueInfo.Props memory) {
        return
            MarketUtils.getMarketTokenPrice(
                dataStore,
                market,
                indexTokenPrice,
                longTokenPrice,
                shortTokenPrice,
                pnlFactorType,
                maximize
            );
    }
    */

    function getMarketTokenPrice() public view returns (uint256) {
        uint256 ethPrice = 2000 * 1e8;

        reader.getMarketTokenPrice({
            dataStore: address(dataStore),
            market: Market.Props({
                marketToken: GM_TOKEN_ETH_WETH_USDC,
                indexToken: WETH,
                longToken: WETH,
                shortToken: USDC
            }),
            indexTokenPrice: Price.Props({
                min: ethPrice * 1e30 / (1e8 * 1e18) * 99 / 100,
                max: ethPrice * 1e30 / (1e8 * 1e18) * 101 / 100
            }),
            longTokenPrice: Price.Props({
                min: ethPrice * 1e30 / (1e8 * 1e18) * 99 / 100,
                max: ethPrice * 1e30 / (1e8 * 1e18) * 101 / 100
            }),
            shortTokenPrice: Price.Props({
                min: 1 * 1e30 / 1e6 * 99 / 100,
                max: 1 * 1e30 / 1e6 * 101 / 100
            }),
            pnlFactorType: Keys.MAX_PNL_FACTOR_FOR_DEPOSITS,
            maximize: false
        });

    }

    // Task 2 - Create order to deposit USDC into GM_TOKEN_BTC_WBTC_USDC
    function createDeposit(uint256 usdcAmount)
        external
        payable
        returns (bytes32 key)
    {
        uint256 executionFee = 0.1 * 1e18;
        usdc.transferFrom(msg.sender, address(this), usdcAmount);

        // Send gas fee to deposit vault
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: DEPOSIT_VAULT,
            amount: executionFee
        });

        // Send USDC to deposit vault
        usdc.approve(ROUTER, usdcAmount);
        exchangeRouter.sendTokens({
            token: USDC,
            receiver: DEPOSIT_VAULT,
            amount: usdcAmount
        });

        // Create order to deposit USDC into GM_TOKEN_BTC_WBTC_USDC
        return exchangeRouter.createDeposit(
            DepositUtils.CreateDepositParams({
                receiver: address(this),
                callbackContract: address(0),
                uiFeeReceiver: address(0),
                market: GM_TOKEN_BTC_WBTC_USDC,
                initialLongToken: WBTC,
                initialShortToken: USDC,
                longTokenSwapPath: new address[](0),
                shortTokenSwapPath: new address[](0),
                // TODO: how to calculate?
                // minMarketTokens: 4158804842790729588,
                minMarketTokens: 1,
                shouldUnwrapNativeToken: false,
                executionFee: executionFee,
                callbackGasLimit: 0
            })
        );
    }

    function createWithdrawal() external payable returns (bytes32 key) {
        uint256 gmTokenAmount = gmToken.balanceOf(address(this));

        uint256 executionFee = 0.1 * 1e18;

        // Send gas fee
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: WITHDRAWAL_VAULT,
            amount: executionFee
        });

        // Send token
        gmToken.approve(ROUTER, gmTokenAmount);
        exchangeRouter.sendTokens({
            token: GM_TOKEN_BTC_WBTC_USDC,
            receiver: WITHDRAWAL_VAULT,
            amount: gmTokenAmount
        });

        // Create order
        address[] memory longTokenSwapPath = new address[](0);
        address[] memory shortTokenSwapPath = new address[](0);

        return exchangeRouter.createWithdrawal(
            WithdrawalUtils.CreateWithdrawalParams({
                receiver: address(this),
                callbackContract: address(0),
                uiFeeReceiver: address(0),
                market: GM_TOKEN_BTC_WBTC_USDC,
                longTokenSwapPath: longTokenSwapPath,
                shortTokenSwapPath: shortTokenSwapPath,
                // TODO: how to calculate this
                minLongTokenAmount: 1,
                // TODO: how to calculate this
                minShortTokenAmount: 1,
                shouldUnwrapNativeToken: false,
                executionFee: executionFee,
                callbackGasLimit: 0
            })
        );
    }
}
