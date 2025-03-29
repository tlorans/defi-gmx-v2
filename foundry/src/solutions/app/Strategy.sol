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
        orderKey = createIncreaseShortPositionOrder({
            executionFee: msg.value,
            longTokenAmount: wethAmount
        });

        emit CreateIncreaseOrder(orderKey);
    }

    function decrease(uint256 wethAmount, address callbackContract)
        external
        payable
        auth
        returns (bytes32 orderKey)
    {
        if (callbackContract == address(0)) {
            orderKey = createDecreaseShortPositionOrder({
                executionFee: msg.value,
                longTokenAmount: wethAmount,
                receiver: address(this),
                callbackContract: address(0),
                callbackGasLimit: 0
            });
        } else {
            require(
                callbackContract.code.length > 0, "callback is not a contract"
            );
            uint256 maxCallbackGasLimit = getMaxCallbackGasLimit();
            require(
                msg.value > maxCallbackGasLimit,
                "callback gas limit < execution fee"
            );

            orderKey = createDecreaseShortPositionOrder({
                executionFee: msg.value,
                longTokenAmount: wethAmount,
                receiver: callbackContract,
                callbackContract: callbackContract,
                callbackGasLimit: maxCallbackGasLimit
            });
        }
        emit CreateDecreaseOrder(orderKey);
    }

    function cancel(bytes32 orderKey) external payable auth {
        cancelOrder(orderKey);
        emit CreateCancelOrder(orderKey);
    }

    function claim() external {
        claimFundingFees();
    }

    function transfer(address dst, uint256 amount) external auth {
        weth.transfer(dst, amount);
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
