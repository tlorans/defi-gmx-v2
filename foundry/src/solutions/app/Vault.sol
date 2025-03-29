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

    bool private locked;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(bytes32 => IVault.WithdrawOrder) public withdrawOrders;

    modifier lock() {
        require(!locked, "locked");
        locked = true;
        _;
        locked = false;
    }

    constructor(address _weth) {
        weth = IERC20(_weth);
    }

    function setStrategy(address _strategy) external auth {
        strategy = IStrategy(_strategy);
    }

    function setWithdrawCallback(address _withdrawCallback) external auth {
        withdrawCallback = _withdrawCallback;
    }

    function totalValueInToken() public view returns (uint256) {
        return weth.balanceOf(address(this)) + strategy.totalValueInToken();
    }

    function deposit(uint256 wethAmount) external lock returns (uint256 shares) {
        if (address(strategy) != address(0)) {
            strategy.claim();
        }

        // TODO: vault inflation
        uint256 totalVal = totalValueInToken();
        shares = _convertToShares(totalSupply, totalVal, wethAmount);

        weth.transferFrom(msg.sender, address(this), wethAmount);

        _mint(msg.sender, shares);
    }

    // NOTE: withdrawal delay or gradual profit distribution should be implemented
    // to prevent users from depositing before profit is claimed by the strategy and then
    // immediately withdrawing after.
    function withdraw(uint256 shares)
        external
        payable
        lock
        returns (uint256 wethSent, bytes32 withdrawOrderKey)
    {
        if (address(strategy) != address(0)) {
            strategy.claim();
        }

        // TODO: vault inflation
        uint256 totalVal = totalValueInToken();
        uint256 wethAmount = _convertToWeth(totalSupply, totalVal, shares);
        require(wethAmount > 0, "weth amount = 0");

        uint256 wethRemaining = wethAmount;

        uint256 wethInVault = weth.balanceOf(address(this));
        wethRemaining -= Math.min(wethInVault, wethRemaining);

        if (wethRemaining > 0 && address(strategy) != address(0)) {
            uint256 wethInStrategy = weth.balanceOf(address(strategy));
            if (wethInStrategy > 0) {
                uint256 wethToTransfer = Math.min(wethInStrategy, wethRemaining);
                wethRemaining -= wethToTransfer;
                strategy.transfer(address(this), wethToTransfer);
            }
        }

        if (wethRemaining == 0) {
            _burn(msg.sender, shares);
            wethSent = wethAmount;
            weth.transfer(msg.sender, wethSent);

            if (msg.value > 0) {
                (bool ok,) = msg.sender.call{value: msg.value}("");
                require(ok, "Send ETH failed");
            }
        } else {
            uint256 sharesRemaining = shares * wethRemaining / wethAmount;
            _burn(msg.sender, shares - sharesRemaining);
            wethSent = wethAmount - wethRemaining;
            weth.transfer(msg.sender, wethSent);

            if (sharesRemaining > 0) {
                require(
                    withdrawCallback != address(0),
                    "withdraw callback is 0 address"
                );

                require(msg.value > 0, "execution fee = 0");
                withdrawOrderKey = strategy.decrease{value: msg.value}(
                    wethRemaining, withdrawCallback
                );

                require(
                    withdrawOrderKey != bytes32(uint256(0)), "invalid order key"
                );
                require(
                    withdrawOrders[withdrawOrderKey].account == address(0),
                    "order is not empty"
                );
                withdrawOrders[withdrawOrderKey] = IVault.WithdrawOrder({
                    account: msg.sender,
                    shares: sharesRemaining,
                    weth: wethRemaining
                });
            }
        }
    }

    function cancelWithdrawOrder(bytes32 orderKey) external lock {
        require(
            msg.sender == withdrawOrders[orderKey].account, "not owner of order"
        );
        require(
            withdrawCallback != address(0), "withdraw callback is 0 address"
        );
        strategy.cancel(orderKey);
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
}
