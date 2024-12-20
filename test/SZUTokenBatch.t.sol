// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeploySZUToken} from "../script/DeploySZUToken.s.sol";
import {SZUToken} from "../src/SZUToken.sol";

contract SZUTokenBatchTest is Test {
    SZUToken public token;
    DeploySZUToken public deployToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    address carol = makeAddr("carol");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000000 ether;

    /*
     * Sets up the contract test by deploying new instances of the SZUToken
     * and initializing it with a starting balance for Bob.
     */
    function setUp() public {
        deployToken = new DeploySZUToken();
        token = deployToken.run();

        vm.prank(msg.sender);
        token.transfer(bob, STARTING_BALANCE);
    }

    /*
     * Tests successful batch transfer to multiple recipients.
     * 1. Creates arrays of recipients and amounts
     * 2. Executes batch transfer from bob
     * 3. Verifies balances are correct after transfer
     */
    function testBatchTransferSuccess() public {
        address[] memory recipients = new address[](3);
        recipients[0] = alice;
        recipients[1] = carol;
        recipients[2] = makeAddr("dave");

        uint256[] memory amounts = new uint256[](3);
        amounts[0] = 10 ether;
        amounts[1] = 20 ether;
        amounts[2] = 30 ether;

        uint256 totalAmount = 60 ether; /* 10 + 20 + 30 ether */

        vm.prank(bob);
        bool success = token.batchTransfer(recipients, amounts);

        assertTrue(success);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - totalAmount);
        assertEq(token.balanceOf(alice), 10 ether);
        assertEq(token.balanceOf(carol), 20 ether);
        assertEq(token.balanceOf(recipients[2]), 30 ether);
    }

    /*
     * Tests batch transfer failure due to insufficient balance.
     * 1. Sets up recipients array with Alice and Carol
     * 2. Sets amounts that exceed Bob's balance
     * 3. Expects revert when attempting batch transfer
     * 4. Verifies insufficient balance error message
     */
    function testBatchTransferInsufficientBalance() public {
        address[] memory recipients = new address[](2);
        recipients[0] = alice;
        recipients[1] = carol;

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = STARTING_BALANCE;
        amounts[1] = 1 ether;

        vm.prank(bob);
        vm.expectRevert("Insufficient balance");
        token.batchTransfer(recipients, amounts);
    }

    /*
     * Tests batch transfer with mismatched array lengths.
     * Sets up recipients array with two addresses but amounts array with one value.
     * Expects revert with invalid array length message when arrays don't match.
     * Verifies error handling for array length validation.
     */
    function testBatchTransferMismatchArrays() public {
        address[] memory recipients = new address[](2);
        recipients[0] = alice;
        recipients[1] = carol;

        uint256[] memory amounts = new uint256[](1);
        amounts[0] = STARTING_BALANCE;

        vm.prank(bob);
        vm.expectRevert("Invalid array length");
        token.batchTransfer(recipients, amounts);
    }

    /*
     * Tests batch transfer with zero address recipient.
     * 1. Creates recipients array with Alice and zero address
     * 2. Sets up amounts for each recipient
     * 3. Expects revert when attempting transfer to zero address
     * 4. Verifies invalid recipient address error
     */
    function testBatchTransferZeroAddress() public {
        address[] memory recipients = new address[](2);
        recipients[0] = alice;
        recipients[1] = address(0); // Zero address

        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10 ether;
        amounts[1] = 20 ether;

        vm.prank(bob);
        vm.expectRevert("Invalid recipient address");
        token.batchTransfer(recipients, amounts);
    }

    /*
     * Tests batch transfer with empty arrays.
     * 1. Creates empty recipients and amounts arrays
     * 2. Expects revert when attempting transfer with empty arrays
     * 3. Verifies empty array error handling
     */
    function testBatchTransferEmptyArray() public {
        address[] memory recipients = new address[](0);
        uint256[] memory amounts = new uint256[](0);

        vm.prank(bob);
        vm.expectRevert("Empty array");
        token.batchTransfer(recipients, amounts);
    }
}
