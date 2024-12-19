// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeploySZUToken} from "../script/DeploySZUToken.s.sol";
import {SZUToken} from "../src/SZUToken.sol";

contract OurTokenTest is Test {
    SZUToken public token;
    DeploySZUToken public deployToken;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

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
     * Tests if the initial balance of bob's account matches
     * the STARTING_BALANCE constant that we set when we
     * transferred tokens in setUp().
     */
    function testInitialBalance() public view {
        assertEq(token.balanceOf(bob), STARTING_BALANCE);
    }

    function testTransferFrom() public {
        uint256 initialAllowance = 1000;
        vm.prank(bob);
        token.approve(alice, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(alice);
        token.transferFrom(bob, alice, transferAmount);

        assertEq(token.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
    }
}
