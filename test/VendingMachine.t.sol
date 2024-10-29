// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {SEC} from "../src/SEC.sol";
import {VendingMachine} from "../src/VendingMachine.sol";

// TDD: test drive development
contract VendingMachineTest is Test {
    address alice = address(0xaaa);
    address bob = address(0xbbb);
    SEC token;
    VendingMachine vendingmachine;

    function setUp() public {
        vm.label(alice, "ALICE");
        vm.label(bob, "BOB");

        vm.deal(bob, 10 ether);

        vm.startPrank(alice);
        // deploy token
        token = new SEC();

        // deploy vending machine
        vendingmachine = new VendingMachine(address(token), 1 ether);

        // depositar tokens na vending machine
        token.transfer(address(vendingmachine), 100 * 1e18);
        vm.stopPrank();
    }

    function testBuyTokens() public {
        uint256 userBalanceBefore = token.balanceOf(bob);
        uint256 contractBalanceBefore = token.balanceOf(address(vendingmachine));

        assertEq(userBalanceBefore, 0);
        assertEq(contractBalanceBefore, 100 * 1e18);

        vm.prank(bob);
        vendingmachine.buyTokens{value: 2 ether}();

        uint256 userBalanceAfter = token.balanceOf(bob);
        uint256 contractBalanceAfter = token.balanceOf(address(vendingmachine));

        assertEq(userBalanceAfter, 2 * 1e18);
        assertEq(contractBalanceAfter, 98 * 1e18);
    }

    function testWithdraw() public {
        // Bob buys tokens in the contract
        vm.prank(bob);
        vendingmachine.buyTokens{value: 1 ether}();

        // Alice withdraws ether
        vm.prank(alice);
        vendingmachine.withdraw();

        // Validate that Alice has ethers
        assertEq(alice.balance, 1 ether);

        // Validate that the contract does not have ethers
        assertEq(address(vendingmachine).balance, 0);
    }
}
