// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IExchangeRouter} from "../interfaces/IExchangeRouter.sol";
import {IOrderHandler} from "../interfaces/IOrderHandler.sol";
import {IReader} from "../interfaces/IReader.sol";
import {Order} from "../types/Order.sol";
import {Position} from "../types/Position.sol";
import {DepositUtils} from "../types/DepositUtils.sol";
import {WithdrawalUtils} from "../types/WithdrawalUtils.sol";
import {Oracle} from "../lib/Oracle.sol";
import "../Constants.sol";

contract MarketLiquidity {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IERC20 constant gmToken = IERC20(GM_TOKEN_WBTC_USDC);
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);
    IReader constant reader = IReader(READER);

    // Receive execution fee refund from GMX
    receive() external payable {}

    // Create order to short WETH with USDC collateral
    function createDeposit(uint256 usdcAmount)
        external
        payable
        returns (bytes32 key)
    {
        uint256 executionFee = 0.1 * 1e18;

        usdc.transferFrom(msg.sender, address(this), usdcAmount);

        // Send gas fee
        exchangeRouter.sendWnt{value: executionFee}({
            receiver: DEPOSIT_VAULT,
            amount: executionFee
        });

        // TODO: double sided liquidity?
        // Send token
        usdc.approve(ROUTER, usdcAmount);
        exchangeRouter.sendTokens({
            token: USDC,
            receiver: DEPOSIT_VAULT,
            amount: usdcAmount
        });

        // Create order
        address[] memory longTokenSwapPath = new address[](0);
        address[] memory shortTokenSwapPath = new address[](0);

        return exchangeRouter.createDeposit(
            DepositUtils.CreateDepositParams({
                receiver: address(this),
                callbackContract: address(0),
                uiFeeReceiver: address(0),
                market: GM_TOKEN_WBTC_USDC,
                initialLongToken: WBTC,
                initialShortToken: USDC,
                longTokenSwapPath: longTokenSwapPath,
                shortTokenSwapPath: shortTokenSwapPath,
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
            token: GM_TOKEN_WBTC_USDC,
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
                market: GM_TOKEN_WBTC_USDC,
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
