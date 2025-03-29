// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

interface IVault {
    struct WithdrawOrder {
        address account;
        uint256 shares;
        uint256 weth;
    }

    function withdrawOrders(bytes32 key)
        external
        view
        returns (WithdrawOrder memory);
    function removeWithdrawOrder(bytes32 key, bool ok) external;
}
