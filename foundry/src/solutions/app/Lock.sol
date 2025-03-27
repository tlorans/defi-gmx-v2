// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../interfaces/IERC20.sol";
import {Auth} from "./Auth.sol";

contract Lock is Auth {
    IERC20 public immutable token;
    uint256 public locked;
    uint256 public lastLockedTimestamp;
    uint256 public constant MAX_LOCK_DURATION = 3 * 24 * 3600;

    constructor(address _token) {
        token = IERC20(_token);
        lastLockedTimestamp = block.timestamp;
    }

    function free() public view returns (uint256) {
        uint256 deltaTime = block.timestamp - lastLockedTimestamp;
        return deltaTime >= MAX_LOCK_DURATION
            ? locked
            : locked * deltaTime / MAX_LOCK_DURATION;
    }

    function lock(uint256 amount) external {
        token.transferFrom(msg.sender, address(this), amount);
        locked = (locked - free()) + amount;
        lastLockedTimestamp = block.timestamp;
    }

    function unlock() external auth returns (uint256) {
        locked -= free();
        uint256 bal = token.balanceOf(address(this));
        // TODO: how to make sure bal >= locked?
        uint256 diff = bal - locked;
        token.transfer(msg.sender, bal - locked);
        return diff;
    }
}
