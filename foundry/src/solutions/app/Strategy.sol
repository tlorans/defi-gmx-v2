// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../interfaces/IERC20.sol";
import "../../Constants.sol";
import {Auth} from "./Auth.sol";
import {Math} from "./Math.sol";

contract GmxHelper {
// function increase() internal {}
// function decrease() internal {}
// function cancel() internal {}
}

contract Strategy is Auth, GmxHelper {
    IERC20 public immutable weth;

    constructor(address _weth) {
        weth = IERC20(_weth);
    }

    receive() external payable {}

    function totalValueInToken() external view returns (uint256) {
        //
    }

    function increase() external payable auth {
        // pull from vault
        // check funding rate is posittive (long pays short)
        // increase position
    }

    function decrease() external payable auth {
        // decrease position
        // TODO: split profit ?
    }

    function cancel(bytes32 key) external payable auth {
        // cancel order
    }

    function claim() external {
        // claim funding fees
        // split profit
    }

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
