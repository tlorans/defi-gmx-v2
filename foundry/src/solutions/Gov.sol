// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IGovToken} from "../interfaces/IGovToken.sol";
import {IRewardRouterV2} from "../interfaces/IRewardRouterV2.sol";
import "../Constants.sol";

contract Gov {
    IGovToken constant gmxDao = IGovToken(GMX_DAO);

    function delegate(address delegatee) external {
        gmxDao.delegate(delegatee);
    }
}
