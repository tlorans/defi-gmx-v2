// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import "../../Constants.sol";
import {Auth} from "./Auth.sol";
import {Math} from "./Math.sol";
import {GmxHelper} from "./GmxHelper.sol";

contract Strategy is Auth, GmxHelper {
    event CreateIncreaseOrder(bytes32 orderKey);
    event CreateDecreaseOrder(bytes32 orderKey);
    event CreateCancelOrder(bytes32 orderKey);

    IERC20 public constant weth = IERC20(WETH);

    constructor(address oracle)
        GmxHelper(
            GM_TOKEN_ETH_WETH_USDC,
            WETH,
            USDC,
            18,
            6,
            CHAINLINK_ETH_USD,
            CHAINLINK_USDC_USD,
            oracle
        )
    {}

    receive() external payable {}

    function totalValue() external view returns (uint256) {
        // WETH balance + WETH managed by strategy + strategy profit and loss
        totalValueInTokens();
    }

    function increase(uint256 wethAmount)
        external
        payable
        auth
        returns (bytes32 orderKey)
    {
        // TODO: check funding fee is positive

        orderKey = createIncreaseShortPositionOrder({
            executionFee: msg.value,
            longTokenAmount: wethAmount
        });

        emit CreateIncreaseOrder(orderKey);
    }

    function decrease() external payable auth returns (bytes32 orderKey) {
        // decrease position
        emit CreateDecreaseOrder(orderKey);
    }

    function cancel(bytes32 orderKey) external payable auth {
        // cancel order
        cancelOrder(orderKey);
        emit CreateCancelOrder(orderKey);
    }

    function claim() external {
        claimFundingFees();
    }

    // TODO: function to withdraw to withdrawal vault

    // TODO: callback for withdrawal

    function push(address dst, uint256 amount) external auth {
        amount = Math.min(weth.balanceOf(address(this)), amount);
        weth.transfer(dst, amount);
    }

    function pull(address src, uint256 amount) external auth {
        amount = Math.min(weth.balanceOf(src), amount);
        weth.transferFrom(src, address(this), amount);
    }

    function withdraw(address token) external auth {
        if (token == address(0)) {
            (bool ok,) = msg.sender.call{value: address(this).balance}("");
            require(ok, "Send ETH failed");
        } else {
            IERC20(token).transfer(
                msg.sender, IERC20(token).balanceOf(address(this))
            );
        }
    }
}
