// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {Math} from "../../lib/Math.sol";
import "../../Constants.sol";
import {Auth} from "./Auth.sol";
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

    function totalValueInToken() external view returns (uint256) {
        uint256 val = weth.balanceOf(address(this));
        int256 remainingCollateral = getPositionPnlInToken();

        if (remainingCollateral >= 0) {
            val += uint256(remainingCollateral);
        } else {
            val -= Math.min(val, uint256(-remainingCollateral));
        }

        return val;
    }

    function increase(uint256 wethAmount)
        external
        payable
        auth
        returns (bytes32 orderKey)
    {
        // TODO: check funding fee is positive?

        orderKey = createIncreaseShortPositionOrder({
            executionFee: msg.value,
            longTokenAmount: wethAmount
        });

        emit CreateIncreaseOrder(orderKey);
    }

    function decrease(uint256 wethAmount)
        external
        payable
        auth
        returns (bytes32 orderKey)
    {
        orderKey = createDecreaseShortPositionOrder({
            executionFee: msg.value,
            longTokenAmount: wethAmount
        });
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

    function transfer(address dst, uint256 amount) external auth {
        weth.transfer(dst, amount);
    }

    function transferFrom(address src, uint256 amount) external auth {
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
