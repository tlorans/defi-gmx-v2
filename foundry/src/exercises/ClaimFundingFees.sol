// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IExchangeRouter} from "../interfaces/IExchangeRouter.sol";
import "../Constants.sol";

contract ClaimFundingFees {
    IExchangeRouter constant exchangeRouter = IExchangeRouter(EXCHANGE_ROUTER);

    // TODO: how to get current claimable amount?

    function claimFundingFees() external {
        address[] memory markets = new address[](2);
        markets[0] = GM_TOKEN_ETH_WETH_USDC;
        markets[1] = GM_TOKEN_ETH_WETH_USDC;

        address[] memory tokens = new address[](2);
        tokens[0] = WETH;
        tokens[1] = USDC;

        exchangeRouter.claimFundingFees({
            markets: markets,
            tokens: tokens,
            receiver: address(this)
        });
    }
}
