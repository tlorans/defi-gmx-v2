// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../interfaces/IERC20.sol";
import "../../Constants.sol";
import {Auth} from "./Auth.sol";
import {Math} from "./Math.sol";

contract GasLessOrders {
    receive() external payable {}

    function createOrder() external payable {}
}
