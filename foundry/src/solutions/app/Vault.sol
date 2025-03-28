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

    constructor(address _weth) {
        weth = IERC20(_weth);
    }

    function set(address _strategy) external auth {
        strategy = IStrategy(_strategy);
    }

    function totalValueInToken() public view returns (uint256) {}
    function totalValueInUsd() external view returns (uint256) {}

    function deposit() external {
        // TODO: vault inflation

        // claim funding fees
        // get pnl
        // mint shares
    }

    function withdraw() external {
        // claim funding fees
        // get pnl
        // create withdraw order
    }

    function push(address dst, uint256 amount) external auth {
        amount = Math.min(weth.balanceOf(address(this)), amount);
        weth.transfer(dst, amount);
    }

    function pull(address src, uint256 amount) external auth {
        amount = Math.min(weth.balanceOf(src), amount);
        weth.transferFrom(src, address(this), amount);
    }
}
