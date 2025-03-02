// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./lib/TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import "../src/Constants.sol";
import {IRewardRouterV2} from "../src/interfaces/IRewardRouterV2.sol";
// TODO: import from exercises
import {Gov} from "../src/solutions/Gov.sol";

contract GovTest is Test {
    IERC20 constant gmx = IERC20(GMX);
    IERC20 constant gmxDao = IERC20(GMX_DAO);

    TestHelper testHelper;
    Gov gov;

    function setUp() public {
        testHelper = new TestHelper();

        gov = new Gov();
        deal(GMX, address(this), 10 * 1e18);
        gmx.approve(address(gov), 10 * 1e18);
    }

    function testDelegate() public {
        //
    }
}
