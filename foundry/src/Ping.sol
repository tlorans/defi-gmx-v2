// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Ping {
    event Pong(address sender, uint256 value);

    function ping() external payable {
        emit Pong(msg.sender, msg.value);
    }
}