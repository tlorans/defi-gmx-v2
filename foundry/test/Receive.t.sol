// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";

contract NoReceive {
    // no receive(), no payable fallback
}

contract HasReceive {
    event EthReceived(address from, uint256 amount);

    receive() external payable {
        emit EthReceived(msg.sender, msg.value);
    }
}

contract ReceiveTest is Test {
    NoReceive noReceive;
    HasReceive hasReceive;

    function setUp() public {
        noReceive = new NoReceive();
        hasReceive = new HasReceive();
    }

    function test_Revert_SendEthToNoReceive() public {
        // Expect the transfer to fail
        vm.expectRevert();
        (bool ok, ) = address(noReceive).call{value: 1 ether}("");
        require(ok, "transfer failed");
    }

    function test_SendEthToHasReceive() public {
        // Send ETH successfully
        (bool ok, ) = address(hasReceive).call{value: 1 ether}("");
        require(ok, "transfer failed");

        // Verify ETH actually landed in the contract
        assertEq(address(hasReceive).balance, 1 ether);
    }
}
