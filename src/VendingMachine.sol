// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {SEC} from "./SEC.sol";
import {UD60x18, ud} from "prb-math/UD60x18.sol";

contract VendingMachine {
    SEC token;
    uint256 public constant FACTOR = 943;
    UD60x18 private price;
    address owner;

    function getPrice() public view returns (uint256) {
        return price.unwrap();
    }

    constructor(address _token, uint256 _price) payable {
        token = SEC(_token);
        price = ud(_price);
        owner = msg.sender;
    }

    function calculateNewPrice() internal view returns (UD60x18) {
        return price.mul(ud(FACTOR)).div(ud(1000));
    }

    function getTokensAvailable() internal view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function buyTokens() external payable {
        UD60x18 msgValue = ud(msg.value);
        UD60x18 tokensToBuy = msgValue.div(price);
        if (tokensToBuy.unwrap() <= 0) {
            revert("You Send Wrong Value ETH");
        }
        if (getTokensAvailable() < tokensToBuy.unwrap()) {
            revert("Vendor Machine Not Have Tokens");
        }

        UD60x18 tokensToTransfer = tokensToBuy.mul(ud(1e18));
        token.transfer(msg.sender, tokensToTransfer.unwrap());

        price = price.add(ud(1 ether));
    }

    function sellTokens() external {
        if (token.balanceOf(msg.sender) < 1) {
            revert("You Not Have Enough Tokens");
        } else if (address(this).balance < price.unwrap()) {
            revert("Vendor Machine Not Have ETH");
        } else {
            //
            // 1. PAY SELLER
            //
            (bool ok, bytes memory data_error) = msg.sender.call{value: price.unwrap()}("");
            if (!ok) {
                assembly {
                    revert(add(data_error, 32), mload(data_error))
                }
            }
            //
            // 2. VENDOR MACHINE GET TOKEN
            //
            try token.transferFrom(msg.sender, address(this), 1e18) {
            //
            // 3. CHANGE PRICE
            //
            // loss 5.7% of value
            price = calculateNewPrice();
            } catch (bytes memory transfer_error) {
                assembly {
                    revert(add(transfer_error, 32), mload(transfer_error))
                }
            }
        }
    }

    function withdraw() external {
        onlyOwnerFunc(msg.sender);
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    }

    function onlyOwnerFunc(address user) internal view {
        if (user != owner) {
            revert("Only the owner can withdraw");
        }
    }
}
