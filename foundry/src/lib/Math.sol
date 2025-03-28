// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

library Math {
    function add(uint256 x, int256 y) internal pure returns (uint256) {
        return y >= 0 ? x + uint256(y) : x - uint256(-y);
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        return x <= y ? x : y;
    }

    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }
}
