// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IWeth} from "../../interfaces/IWeth.sol";
import {Order} from "../../types/Order.sol";
import {EventUtils} from "../../types/EventUtils.sol";
import "../../Constants.sol";
import {Math} from "../../lib/Math.sol";
import {IStrategy} from "./IStrategy.sol";
import {IVault} from "./IVault.sol";

contract WithdrawCallback {
    IWeth public immutable weth;
    IVault public immutable vault;

    constructor(address _weth, address _vault) {
        weth = IWeth(_weth);
        vault = IVault(_vault);
    }

    modifier auth() {
        require(msg.sender == ORDER_HANDLER, "not authorized");
        _;
    }

    receive() external payable {}

    function afterOrderExecution(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) external auth {
        IVault.WithdrawOrder memory withdrawOrder = vault.withdrawOrders(key);
        require(withdrawOrder.account != address(0), "invalid order key");
        require(order.numbers.orderType == Order.OrderType.MarketDecrease, "invalid order type");

        uint256 wethToSend = Math.min(withdrawOrder.weth, weth.balanceOf(address(this)));

        if (address(this).balance > 0) {
            wethToSend += address(this).balance;
            weth.deposit{value: address(this).balance}();
        }

        vault.removeWithdrawOrder(key, true);
        weth.transfer(withdrawOrder.account, wethToSend);

        uint256 bal = weth.balanceOf(address(this));
        if (bal > 0) {
            weth.transfer(address(vault), bal);
        }
    }

    function afterOrderCancellation(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) external auth {
        IVault.WithdrawOrder memory withdrawOrder = vault.withdrawOrders(key);
        require(withdrawOrder.account != address(0), "invalid order key");
        require(order.numbers.orderType == Order.OrderType.MarketDecrease, "invalid order type");

        // TODO:
        vault.removeWithdrawOrder(key, false);
    }

    function afterOrderFrozen(
        bytes32 key,
        Order.Props memory order,
        EventUtils.EventLogData memory eventData
    ) external auth {
        IVault.WithdrawOrder memory withdrawOrder = vault.withdrawOrders(key);
        require(withdrawOrder.account != address(0), "invalid order key");
        require(order.numbers.orderType == Order.OrderType.MarketDecrease, "invalid order type");

        // TODO: frozen
        vault.removeWithdrawOrder(key, false);
    }
}
