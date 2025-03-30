// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import "../lib/TestHelper.sol";
import {EventUtils} from "../../src/types/EventUtils.sol";
import {Order} from "../../src/types/Order.sol";
import {IVault} from "@exercises/app/IVault.sol";
import {Vault} from "@exercises/app/Vault.sol";

contract MockStrategy {
    IERC20 constant weth = IERC20(WETH);
    uint256 private total;
    bytes32 public cancelKey;
    uint256 public wethAmount;
    uint256 public ethAmount;
    address public cb;
    bytes32 public returnKey = bytes32(uint256(1));

    function setTotal(uint256 _total) external {
        total = _total;
    }

    function totalValueInToken() external view returns (uint256) {
        return total;
    }

    function decrease(uint256 _wethAmount, address _cb)
        external
        payable
        returns (bytes32)
    {
        ethAmount = msg.value;
        wethAmount = _wethAmount;
        cb = _cb;
        return returnKey;
    }

    function cancel(bytes32 _key) external {
        cancelKey = _key;
    }

    function claim() external {}

    function transfer(address dst, uint256 amount) external {
        weth.transfer(dst, amount);
    }
}

contract MockCallback {}

contract User {
    receive() external payable {}
}

contract VaultTest is Test {
    IERC20 constant weth = IERC20(WETH);
    IERC20 constant usdc = IERC20(USDC);
    uint256 constant EXECUTION_FEE = 0.01 * 1e18;

    TestHelper testHelper;
    Vault vault;
    MockStrategy strategy;
    MockCallback cb;

    address[] users;

    receive() external payable {}

    function setUp() public virtual {
        testHelper = new TestHelper();
        vault = new Vault();
        strategy = new MockStrategy();
        cb = new MockCallback();

        deal(WETH, address(this), 1000 * 1e18);

        vault.setStrategy(address(strategy));
        vault.setWithdrawCallback(address(cb));

        users.push(address(new User()));
        users.push(address(new User()));

        deal(WETH, users[0], 100);
        deal(WETH, users[1], 100);

        deal(users[0], 1e18);
        deal(users[1], 1e18);
    }

    function deposit(address user, uint256 wethAmount)
        internal
        returns (uint256 shares)
    {
        vm.prank(user);
        weth.approve(address(vault), wethAmount);

        vm.prank(user);
        shares = vault.deposit(wethAmount);
    }

    function testTotalValueInToken() public {
        assertEq(vault.totalValueInToken(), strategy.totalValueInToken());

        weth.transfer(address(vault), 100);
        assertEq(vault.totalValueInToken(), 100 + strategy.totalValueInToken());
    }

    function testDeposit() public {
        address user = address(1);
        uint256 wethAmount = 100;
        deal(WETH, user, wethAmount);

        uint256 shares = deposit(user, wethAmount);

        assertEq(shares, vault.balanceOf(user), "shares");
        assertGt(shares, 0, "shares = 0");
        assertGt(vault.totalSupply(), 0, "total supply = 0");
        assertEq(weth.balanceOf(address(vault)), wethAmount);
    }

    function testWithdrawFromVault() public {
        deposit(users[0], 100);
        deposit(users[1], 100);

        testHelper.set("ETH before", users[0].balance);
        testHelper.set("WETH before", weth.balanceOf(users[0]));

        uint256 shares = vault.balanceOf(users[0]);
        vm.prank(users[0]);
        (uint256 wethSent, bytes32 withdrawOrderKey) =
            vault.withdraw{value: 1000}(shares);

        testHelper.set("ETH after", users[0].balance);
        testHelper.set("WETH after", weth.balanceOf(users[0]));

        uint256 ethDiff =
            testHelper.get("ETH after") - testHelper.get("ETH before");
        uint256 wethDiff =
            testHelper.get("WETH after") - testHelper.get("WETH before");

        assertEq(wethDiff, 100, "WETH diff");
        assertEq(ethDiff, 0, "ETH diff");
        assertEq(wethSent, wethDiff, "WETH sent");
        assertEq(withdrawOrderKey, bytes32(uint256(0)), "withdraw order key");

        assertEq(vault.balanceOf(users[0]), 0, "shares != 0");
    }

    function testWithdrawFromStrategy() public {
        deposit(users[0], 100);
        deposit(users[1], 100);

        vault.transfer(address(strategy), 150);
        strategy.setTotal(150);

        testHelper.set("ETH before", users[0].balance);
        testHelper.set("WETH before", weth.balanceOf(users[0]));

        uint256 shares = vault.balanceOf(users[0]);
        vm.prank(users[0]);
        (uint256 wethSent, bytes32 withdrawOrderKey) =
            vault.withdraw{value: 1000}(shares);

        testHelper.set("ETH after", users[0].balance);
        testHelper.set("WETH after", weth.balanceOf(users[0]));

        uint256 ethDiff =
            testHelper.get("ETH after") - testHelper.get("ETH before");
        uint256 wethDiff =
            testHelper.get("WETH after") - testHelper.get("WETH before");

        assertEq(wethDiff, 100, "WETH diff");
        assertEq(ethDiff, 0, "ETH diff");
        assertEq(weth.balanceOf(address(vault)), 0, "WETH vault");
        assertEq(weth.balanceOf(address(strategy)), 100, "WETH strategy");
        assertEq(wethSent, wethDiff, "WETH sent");
        assertEq(withdrawOrderKey, bytes32(uint256(0)), "withdraw order key");

        assertEq(vault.balanceOf(users[0]), 0, "shares != 0");
    }

    function testWithdrawOrder() public {
        deposit(users[0], 100);
        deposit(users[1], 100);

        vault.transfer(address(strategy), 200);
        strategy.setTotal(500);

        uint256 shares = vault.balanceOf(users[0]);
        vm.prank(users[0]);
        (uint256 wethSent, bytes32 withdrawOrderKey) =
            vault.withdraw{value: 0.1 * 1e18}(shares);

        assertEq(wethSent, 200, "WETH sent");
        assertEq(vault.balanceOf(users[0]), 0, "user shares");
        assertEq(
            vault.balanceOf(address(vault)), 100 * 50 / 250, "locked shares"
        );

        IVault.WithdrawOrder memory w = vault.getWithdrawOrder(withdrawOrderKey);
        assertEq(w.account, users[0], "withdraw order account");
        assertEq(w.shares, 20, "withdraw order shares");
        assertEq(w.weth, 50, "withdraw order weth");

        assertEq(strategy.ethAmount(), 0.1 * 1e18, "strategy ETH");
        assertEq(strategy.wethAmount(), 50, "strategy WETH");
        assertEq(strategy.cb(), address(cb), "strategy callback");

        // Test cancel //

        // Test authorizaion
        vm.expectRevert();
        vault.cancelWithdrawOrder(withdrawOrderKey);

        // Test withdraw callback is a contract
        vault.setWithdrawCallback(address(0));
        vm.expectRevert();
        vm.prank(users[0]);
        vault.cancelWithdrawOrder(withdrawOrderKey);

        // Test success
        vault.setWithdrawCallback(address(cb));
        vm.prank(users[0]);
        vault.cancelWithdrawOrder(withdrawOrderKey);

        assertEq(strategy.cancelKey(), withdrawOrderKey, "cancel key");
    }
}
