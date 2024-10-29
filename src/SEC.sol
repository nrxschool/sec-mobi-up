// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "solady/tokens/ERC20.sol";

contract SEC is ERC20 {
    function name() public pure override returns (string memory) {
        return "Security Token";
    }

    function symbol() public pure override returns (string memory) {
        return "SEC";
    }

    constructor() {
        _mint(msg.sender, 1000 * 1e18);
    }
}
