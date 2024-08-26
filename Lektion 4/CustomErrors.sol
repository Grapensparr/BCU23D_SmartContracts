// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract CustomErrors {
    address public owner;
    uint public number;

    error NotOwner(address caller);
    error TooLow(uint sent, uint required);

    constructor() {
        owner = msg.sender;
    }

    function setNumber(uint _value) external {
        if (msg.sender != owner) {
            revert NotOwner(msg.sender);
        }

        if (_value < 10) {
            revert TooLow(_value, 10);
        }

        number = _value;
    }
}
