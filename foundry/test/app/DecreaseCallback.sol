// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {Order} from "../../src/types/Order.sol";
import {EventUtils} from "../../src/types/EventUtils.sol";

contract DecreaseCallback {
    enum Status {
        None,
        Executed,
        Canceled,
        Frozen
    }

    Status public status;
    bytes32 public orderKey;

    receive() external payable {}

    function reset() external {
        status = Status.None;
    }

    function afterOrderExecution(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) external {
        orderKey = key;
        status = Status.Executed;
    }

    function afterOrderCancellation(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) external {
        orderKey = key;
        status = Status.Canceled;
    }

    function afterOrderFrozen(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) external {
        orderKey = key;
        status = Status.Frozen;
    }
}
