// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ContractOwnerConstructor {
    // Vi återanvänder här vårt ContractOwner kontrakt från lektion 1
    // Vi skriver alltid våra state variabler först, därefter constructor
    address public owner;

    // I vår constructor kan vi antingen välja att skicka med input när kontraktet deployas, 
    // eller definiera vår variabel direkt i kontraktet, så som vi är vana vid (se kommenterad rad)
    constructor(address _owner) {
        owner = _owner;
        //owner = msg.sender;
    }

    function updateOwner(address _newOwner) public {
        require(msg.sender == owner, "Only the current owner can change the ownership!");
        owner = _newOwner;
    }
}
