// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "./lib/TestHelper.sol";
import {IERC20} from "../src/interfaces/IERC20.sol";
import "../src/Constants.sol";
import {ClaimFundingFees} from "@exercises/ClaimFundingFees.sol";

contract ClaimFundingFeesTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);

    TestHelper testHelper;
    ClaimFundingFees claimFundingFees;

    function setUp() public {
        testHelper = new TestHelper();
        claimFundingFees = new ClaimFundingFees();
    }

    function testClaimFundingFees() public {
        claimFundingFees.claimFundingFees();

        testHelper.set("USDC", usdc.balanceOf(address(claimFundingFees)));
        testHelper.set("WETH", weth.balanceOf(address(claimFundingFees)));

        console.log("USDC %e", testHelper.get("USDC"));
        console.log("WETH %e", testHelper.get("WETH"));

        assertGe(testHelper.get("USDC"), 0, "USDC");
        assertGe(testHelper.get("WETH"), 0, "WETH");
    }
}
