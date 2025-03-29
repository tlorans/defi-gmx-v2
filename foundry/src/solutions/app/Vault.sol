// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {Math} from "../../lib/Math.sol";
import "../../Constants.sol";
import {IStrategy} from "./IStrategy.sol";
import {IVault} from "./IVault.sol";
import {Auth} from "./Auth.sol";

contract Vault is Auth {
    IERC20 public immutable weth;
    IStrategy public strategy;
    address public withdrawCallback;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(bytes32 => IVault.WithdrawOrder) public withdrawOrders;

    constructor(address _weth) {
        weth = IERC20(_weth);
    }

    function setStrategy(address _strategy) external auth {
        strategy = IStrategy(_strategy);
    }

    function setWithdrawCallback(address _withdrawCallback) external auth {
        if (_withdrawCallback != address(0)) {
            require(_withdrawCallback.code.length > 0, "callback is not a contract");
        }
        withdrawCallback = _withdrawCallback;
    }

    function totalValueInToken() public view returns (uint256) {
        return weth.balanceOf(address(this)) + strategy.totalValueInToken();
    }

    function deposit(uint256 wethAmount) external returns (uint256 shares) {
        strategy.claim();

        // TODO: vault inflation
        // mint shares
        uint256 totalVal = totalValueInToken();
        shares = _convertToShares(totalSupply, totalVal, wethAmount);

        weth.transferFrom(msg.sender, address(this), wethAmount);

        _mint(msg.sender, shares);
    }

    function withdraw(uint256 shares) external payable {
        strategy.claim();

        // TODO: vault inflation
        // TODO: withdrawal delay?
        uint256 totalVal = totalValueInToken();
        uint256 wethAmount = _convertToWeth(totalSupply, totalVal, shares);
        require(wethAmount > 0, "weth amount = 0");

        uint256 wethRemaining = wethAmount;

        // TODO: burn shares

        uint256 wethInVault = weth.balanceOf(address(this));
        if (wethInVault >= wethRemaining) {
            wethRemaining = 0;
        } else {
            wethRemaining -= wethInVault;
        }

        if (wethRemaining > 0 && address(strategy) != address(0)) {
            uint256 wethInStrategy = weth.balanceOf(address(strategy));
            if (wethInStrategy >= wethRemaining) {
                wethRemaining = 0;
                strategy.transfer(address(this), wethRemaining);
            } else {
                wethRemaining -= wethInStrategy;
                strategy.transfer(address(this), wethInStrategy);
            }
        }

        if (wethRemaining == 0) {
            _burn(msg.sender, shares);
            weth.transfer(msg.sender, wethAmount);
            return;
        } else {
            uint256 sharesRemaining = shares * wethRemaining / wethAmount;
            _burn(msg.sender, shares - sharesRemaining);
            weth.transfer(msg.sender, wethAmount - wethRemaining);

            if (sharesRemaining > 0) {
                require(withdrawCallback != address(0), "withdraw callback is 0 address");

                // TODO: handle order fails?
                // TOOD: deduct executionFee from wethRemaining ?
                bytes32 orderKey =
                    strategy.decrease{value: msg.value}(wethRemaining, withdrawCallback);

                require(orderKey != bytes32(uint256(0)), "invalid order key");
                require(withdrawOrders[orderKey].account == address(0), "order is not empty");
                withdrawOrders[orderKey] = IVault.WithdrawOrder({
                    account: msg.sender,
                    shares: sharesRemaining,
                    weth: wethRemaining
                });
            }
        }
    }

    function removeWithdrawOrder(bytes32 key, bool ok) external auth {
        IVault.WithdrawOrder memory withdrawOrder = withdrawOrders[key];

        if (ok) {
            _burn(withdrawOrder.account, withdrawOrder.shares);
        }

        delete withdrawOrders[key];
    }

    function _convertToShares(
        uint256 totalShares,
        uint256 totalWethInPool,
        uint256 wethAmount
    ) internal pure returns (uint256) {
        if (totalShares == 0 || totalWethInPool == 0) {
            return wethAmount;
        }
        return totalShares * wethAmount / totalWethInPool;
    }

    function _convertToWeth(
        uint256 totalShares,
        uint256 totalWethInPool,
        uint256 shares
    ) internal pure returns (uint256) {
        return totalWethInPool * shares / totalShares;
    }

    function _mint(address dst, uint256 shares) internal {
        totalSupply += shares;
        balanceOf[dst] += shares;
    }

    function _burn(address src, uint256 shares) internal {
        totalSupply -= shares;
        balanceOf[src] -= shares;
    }

    function transfer(address dst, uint256 amount) external auth {
        weth.transfer(dst, amount);
    }

    function transferFrom(address src, uint256 amount) external auth {
        weth.transferFrom(src, address(this), amount);
    }
}
