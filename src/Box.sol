//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract Box is Ownable {
    uint256 number;
    event NumberChanged(uint256 number);

    constructor() Ownable(msg.sender){}

    function store (uint256 newNumber) public onlyOwner {
        number = newNumber;
        emit NumberChanged(newNumber);
    }

    function getNumber() public view returns(uint256) {
        return number;
    }
}