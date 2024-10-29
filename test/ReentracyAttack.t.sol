// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {SEC} from "../src/SEC.sol";
import {VendingMachine} from "../src/VendingMachine.sol";
import {Devil} from "../src/ReentracyAttack.sol";

contract DevilTest is Test {
    Devil atk;
    address alice = address(0xaaa);
    address bob = address(0xbbb);
    SEC token;
    VendingMachine vendingmachine;

    function setUp() public {
        vm.label(alice, "ALICE");
        vm.label(bob, "BOB");

        vm.deal(alice, 10000 ether);
        vm.deal(bob, 10 ether);

        vm.startPrank(alice);
        // deploy token
        token = new SEC();

        // deploy vending machine
        vendingmachine = new VendingMachine{value: 10 ether}(address(token), 1 ether);

        // depositar tokens na vending machine
        token.transfer(address(vendingmachine), 10 * 1e18);
        vm.stopPrank();

        atk = new Devil(address(vendingmachine), address(token));

        vm.deal(address(atk), 10 ether);
    }

    function testAttackVendingMachine() public {
        // Run the attack
        atk.attack();

        assertEq(token.balanceOf(address(atk)), 0, "Should sell all tokens");
        assertEq(address(atk).balance, 20 ether, "Should sell all tokens");
        assertEq(vendingmachine.getPrice(), 1.108 ether, "Should hold a price in 1");
        assertEq(address(vendingmachine).balance, 1, "Should dont have a balance");
    }
}