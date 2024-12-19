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
    address carol = makeAddr("carol");

    uint256 public constant STARTING_BALANCE = 100 ether;
    uint256 public constant INITIAL_SUPPLY = 1000000 ether;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

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

    //function testTotalSupply() public view {
    //     assertEq(token.totalSupply(), INITIAL_SUPPLY);
    //}

    /*
     * Tests successful token transfer from bob to alice.
     * 1. Set transfer amount to 50 ether
     * 2. Have bob initiate the transfer
     * 3. Verify Transfer event is emitted correctly
     * 4. Execute transfer and verify success
     * 5. Check final balances are correct
     */
    function testTransferSuccess() public {
        uint256 transferAmount = 50 ether;
        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Transfer(bob, alice, transferAmount);

        bool success = token.transfer(alice, transferAmount);

        assertTrue(success);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - transferAmount);
        assertEq(token.balanceOf(alice), transferAmount);
    }

    /*
     * Tests token transfer with insufficient funds.
     * Sets transfer amount higher than bob's balance,
     * expects the transfer to revert due to
     * insufficient funds in bob's account.
     */
    function testTransferInsufficientFunds() public {
        uint256 transferAmount = STARTING_BALANCE + 1 ether;
        vm.prank(bob);
        vm.expectRevert();
        token.transfer(alice, transferAmount);
    }

    /*
     * Tests transfer to zero address.
     * Expects the transfer to revert when bob
     * attempts to transfer tokens to the zero address
     * since this is not allowed in ERC20 tokens.
     */
    function testTransferToZeroAddress() public {
        vm.prank(bob);
        vm.expectRevert();
        token.transfer(address(0), 50 ether);
    }

    /*
     * Tests successful token approval.
     * 1. Sets allowance amount to 1000
     * 2. Bob approves Alice to spend tokens
     * 3. Verifies Approval event is emitted correctly
     * 4. Executes approval and verifies success
     * 5. Checks final allowance is set correctly
     */
    function testApproveSuccess() public {
        uint256 allowanceAmount = 1000;
        vm.prank(bob);

        vm.expectEmit(true, true, false, true);
        emit Approval(bob, alice, allowanceAmount);

        bool success = token.approve(alice, allowanceAmount);

        assertTrue(success);
        assertEq(token.allowance(bob, alice), allowanceAmount);
    }

    /*
     * Tests transfer with insufficient allowance.
     * 1. Sets initial allowance to 500
     * 2. Sets transfer amount to 1000 (higher than allowance)
     * 3. Bob approves Alice for initial allowance
     * 4. Alice attempts to transfer more than allowed
     * 5. Verifies transfer reverts due to insufficient allowance
     */
    function testTransferFromInsufficientAllowance() public {
        uint256 initialAllowance = 500;
        uint256 transferAmount = 1000;

        vm.prank(bob);
        token.approve(alice, initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        token.transferFrom(bob, carol, transferAmount);
    }

    /*
     * Tests transfer with insufficient balance.
     * 1. Sets initial allowance higher than bob's balance
     * 2. Bob approves Alice to spend the allowance amount
     * 3. Alice attempts to transfer more than Bob's balance
     * 4. Verifies transfer reverts due to insufficient funds
     */
    function testTransferFromInsufficientBalance() public {
        uint256 initialAllowance = STARTING_BALANCE + 1 ether;

        vm.prank(bob);
        token.approve(alice, initialAllowance);

        vm.prank(alice);
        vm.expectRevert();
        token.transferFrom(bob, carol, initialAllowance);
    }

    /*
     * Tests increase allowance functionality.
     * 1. Sets initial allowance to 1000
     * 2. Bob approves Alice for initial allowance amount
     * 3. Verifies initial allowance is set correctly
     * 4. Bob increases Alice's allowance by 500
     * 5. Verifies final allowance equals initial + increase amount
     */
    function testIncreaseAllowance() public {
        uint256 allowanceAmount = 1000;
        uint256 increaseAmount = 500;

        vm.prank(bob);
        token.approve(alice, allowanceAmount);
        assertEq(token.allowance(bob, alice), allowanceAmount);

        vm.prank(bob);
        token.increaseAllowance(alice, increaseAmount);

        assertEq(token.allowance(bob, alice), allowanceAmount + increaseAmount);
    }

    /*
     * Tests decrease allowance functionality.
     * 1. Sets initial allowance to 1000
     * 2. Bob approves Alice for initial allowance amount
     * 3. Verifies initial allowance is set correctly
     * 4. Bob decreases Alice's allowance by 500
     * 5. Verifies final allowance equals initial - decrease amount
     */
    function testDecreaseAllowance() public {
        uint256 allowanceAmount = 1000;
        uint256 decreaseAmount = 500;

        vm.prank(bob);
        token.approve(alice, allowanceAmount);
        assertEq(token.allowance(bob, alice), allowanceAmount);

        vm.prank(bob);
        token.decreaseAllowance(alice, decreaseAmount);

        assertEq(token.allowance(bob, alice), allowanceAmount - decreaseAmount);
    }

    /*
     * Tests decrease allowance below zero.
     * 1. Sets initial allowance to 1000
     * 2. Bob approves Alice for initial allowance amount
     * 3. Verifies initial allowance is set correctly
     * 4. Bob attempts to decrease Alice's allowance by 1100
     * 5. Verifies transaction reverts since decrease would put allowance below zero
     */
    function testDecreaseAllowanceBelowZero() public {
        uint256 allowanceAmount = 1000;
        uint256 decreaseAmount = 1100;

        vm.prank(bob);
        token.approve(alice, allowanceAmount);
        assertEq(token.allowance(bob, alice), allowanceAmount);

        vm.prank(bob);
        vm.expectRevert();
        token.decreaseAllowance(alice, decreaseAmount);
    }

    /*
     * Tests token burning functionality by sending to a dead address.
     * 1. Sets burn amount to 50 ether
     * 2. Records initial total supply
     * 3. Bob transfers tokens to dead address (0xdead)
     * 4. Verifies total supply remains unchanged
     * 5. Verifies Bob's balance decreased by burn amount
     * 6. Verifies dead address received the burned tokens
     */
    function testBurnTokens() public {
        uint256 burnAmount = 50 ether;
        uint256 initialSupply = token.totalSupply();

        vm.prank(bob);
        token.transfer(address(0xdead), burnAmount);

        assertEq(token.totalSupply(), initialSupply);
        assertEq(token.balanceOf(bob), STARTING_BALANCE - burnAmount);
        assertEq(token.balanceOf(address(0xdead)), burnAmount);
    }
}
