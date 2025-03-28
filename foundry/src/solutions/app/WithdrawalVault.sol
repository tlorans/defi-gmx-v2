// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IERC20} from "../../interfaces/IERC20.sol";
import {Math} from "../../lib/Math.sol";
import "../../Constants.sol";
import {Auth} from "./Auth.sol";

contract WithdrawalVault is Auth {}
