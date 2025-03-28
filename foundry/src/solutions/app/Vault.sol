// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {console} from "forge-std/Test.sol";
import {IERC20} from "../../interfaces/IERC20.sol";
import {Math} from "../../lib/Math.sol";
import "../../Constants.sol";
import {IStrategy} from "./IStrategy.sol";
import {Auth} from "./Auth.sol";

contract Vault is Auth {
    IERC20 public immutable weth;
    IStrategy public strategy;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _weth) {
        weth = IERC20(_weth);
    }

    function set(address _strategy) external auth {
        strategy = IStrategy(_strategy);
    }

    function totalValueInToken() public view returns (uint256) {
        return weth.balanceOf(address(this)) + strategy.totalValueInToken();
    }

    function deposit(uint256 wethAmount) external returns (uint256 shares) {
        strategy.claim();

        // TODO: vault inflation
        // mint shares
        if (totalSupply == 0) {
            shares = wethAmount;
        } else {
            uint256 totalVal = totalValueInToken();
            shares = totalSupply * wethAmount / totalVal;
        }

        weth.transferFrom(msg.sender, address(this), wethAmount);

        _mint(msg.sender, shares);
    }

    function withdraw(uint256 shares) external payable {
        strategy.claim();

        uint256 totalVal = totalValueInToken();

        // TODO: vault inflation
        // TODO: withdrawal delay?
        uint256 wethAmount = totalVal * shares / totalSupply;
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
            uint256 sharesRemaining = shares *  wethRemaining / wethAmount;
            _burn(msg.sender, shares - sharesRemaining);
            weth.transfer(msg.sender, wethAmount - wethRemaining);

            // TODO: handle order fails?
            // TOOD: deduct executionFee from wethRemaining ?
            bytes32 orderKey = strategy.decrease{value: msg.value}(wethRemaining);
            // store
            // - shares
            // - wethRemaining
            // - msg.sender
            // - msg.value
        }
    }

    struct WithdrawOrder {
        address account;
        uint256 shares;
        uint256 wethRemaining;
        uint256 executionFee;
    }

    mapping(bytes32 => WithdrawOrder) public withdrawOrders;

    function callback() external {
        // burn remaining shares
        // convert executionFee refund to WETH
        // send WETH
        // delete order
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
