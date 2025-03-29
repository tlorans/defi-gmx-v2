// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "./StrategyBase.sol";
import {DecreaseCallback} from "./DecreaseCallback.sol";

contract StrategyTest is StrategyBase {
    DecreaseCallback cb;

    function setUp() public override {
        super.setUp();
        cb = new DecreaseCallback();
    }

    function testOpenCloseShort() public {
        uint256 totalValue = 0;

        totalValue = strategy.totalValueInToken();
        assertEq(totalValue, 0, "total value != 0");

        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        totalValue = strategy.totalValueInToken();
        assertEq(totalValue, wethAmount, "total value != WETH amount");

        // Open short position
        inc(wethAmount);

        // Increase short position
        skip(1);
        weth.transfer(address(strategy), wethAmount);
        inc(wethAmount);

        uint256 total = strategy.totalValueInToken();
        assertGe(total, wethAmount * 995 / 1000, "total value");

        // Claim funding fees
        testHelper.set("WETH before", weth.balanceOf(address(strategy)));
        strategy.claim();
        testHelper.set("WETH after", weth.balanceOf(address(strategy)));

        assertGe(testHelper.get("WETH after"), testHelper.get("WETH before"));

        // Decrease short position
        skip(1);
        dec(wethAmount, address(0));

        // Close short position
        skip(1);
        dec(wethAmount, address(0));
    }

    function testCancel() public {
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        bytes32 orderKey = strategy.increase{value: EXECUTION_FEE}(wethAmount);

        Order.Props memory order;

        order = reader.getOrder(DATA_STORE, orderKey);
        assertEq(
            order.addresses.receiver,
            address(strategy),
            "cancel: order receiver"
        );

        skip(24 * 3600);
        strategy.cancel(orderKey);

        order = reader.getOrder(DATA_STORE, orderKey);
        assertEq(
            order.addresses.receiver,
            address(0),
            "cancel: order receiver != address(0)"
        );
    }

    function testDecreaseCallback() public {
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        inc(wethAmount);

        skip(1);
        bytes32 decOrderKey = dec(wethAmount, address(cb));

        assertGt(address(cb).balance, 0, "ETH = 0");
        assertEq(cb.orderKey(), decOrderKey, "callback: order key");
        assertEq(cb.refundOrderKey(), decOrderKey, "callback: refund order key");
        assertTrue(
            cb.status() == DecreaseCallback.Status.Executed, "callback: status"
        );
        assertGt(cb.refundAmount(), 0, "callback: refund amount");
    }

    function testCancelDecreaseCallback() public {
        uint256 wethAmount = 1e18;
        weth.transfer(address(strategy), wethAmount);

        inc(wethAmount);

        skip(1);
        bytes32 decOrderKey =
            strategy.decrease{value: EXECUTION_FEE}(wethAmount, address(cb));

        skip(24 * 3600);
        strategy.cancel(decOrderKey);

        assertGt(address(cb).balance, 0, "ETH = 0");
        assertEq(cb.orderKey(), decOrderKey, "callback: order key");
        assertEq(cb.refundOrderKey(), decOrderKey, "callback: refund order key");
        assertTrue(
            cb.status() == DecreaseCallback.Status.Canceled, "callback: status"
        );
        assertGt(cb.refundAmount(), 0, "callback: refund amount");
    }
}
