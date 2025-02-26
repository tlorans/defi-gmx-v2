// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IGlvRouter} from "../interfaces/IGlvRouter.sol";
import {GlvDepositUtils} from "../types/GlvDepositUtils.sol";
import "../Constants.sol";

contract GlvLiquidity {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    IERC20 constant gmToken = IERC20(GM_TOKEN_WBTC_USDC);
    IGlvRouter constant glvRouter = IGlvRouter(GLV_ROUTER);

    // Receive execution fee refund from GMX
    receive() external payable {}

    // TODO: get deposit and withdrawal order

    function createGlvDeposit(uint256 usdcAmount)
        external
        payable
        returns (bytes32 key)
    {
        uint256 executionFee = 0.1 * 1e18;

        usdc.transferFrom(msg.sender, address(this), usdcAmount);

        // Send gas fee
        glvRouter.sendWnt{value: executionFee}({
            receiver: GLV_VAULT,
            amount: executionFee
        });

        // TODO: pair liquidity?
        // Send token
        usdc.approve(ROUTER, usdcAmount);
        glvRouter.sendTokens({
            token: USDC,
            receiver: GLV_VAULT,
            amount: usdcAmount
        });

        // Create order
        address[] memory longTokenSwapPath = new address[](0);
        address[] memory shortTokenSwapPath = new address[](0);

        return glvRouter.createGlvDeposit(
            GlvDepositUtils.CreateGlvDepositParams({
                glv: GLV_TOKEN,
                market: GM_TOKEN_WBTC_USDC,
                receiver: address(this),
                callbackContract: address(0),
                uiFeeReceiver: address(0),
                initialLongToken: WBTC,
                initialShortToken: USDC,
                longTokenSwapPath: longTokenSwapPath,
                shortTokenSwapPath: shortTokenSwapPath,
                // TODO: how to calculate?
                // minGlvTokens: 6788938029399432758
                minGlvTokens: 1,
                executionFee: executionFee,
                callbackGasLimit: 0,
                shouldUnwrapNativeToken: false,
                isMarketTokenDeposit: false
            })
        );
    }

    function createWithdrawal() external payable returns (bytes32 key) {
        /*
        uint256 gmTokenAmount = gmToken.balanceOf(address(this));

        uint256 executionFee = 0.1 * 1e18;

        // Send gas fee
        glvRouter.sendWnt{value: executionFee}({
            receiver: WITHDRAWAL_VAULT,
            amount: executionFee
        });

        // Send token
        gmToken.approve(ROUTER, gmTokenAmount);
        glvRouter.sendTokens({
            token: GM_TOKEN_WBTC_USDC,
            receiver: WITHDRAWAL_VAULT,
            amount: gmTokenAmount
        });

        // Create order
        address[] memory longTokenSwapPath = new address[](0);
        address[] memory shortTokenSwapPath = new address[](0);

        return glvRouter.createWithdrawal(
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
        */
    }
}
