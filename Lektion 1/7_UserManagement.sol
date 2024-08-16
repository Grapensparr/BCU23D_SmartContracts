// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract UserManagement {
    // Vi använder en struct för att kapsla in relaterade datafält i en sammanhängande enhet.
    struct User {
        string name;
        uint8 age;
    }

    // Vi skapar en mapping (user), där vår key är en adress, och värdet är det struct vi har definierat.
    // Tänk key-value pair!
    mapping(address => User) public user;

    // Write funktion där vi lägger till användarinformation till vår mapping, utifrån den input vi anger.
    function setUserProfile(string memory _name, uint8 _age) public {
        // Vi anger här att adressen som anropar vår funktion (msg.sender) är key i vår mapping.
        // Värdet i vår mapping, för denna key, blir det som användaren angett som input till funktionen.
        user[msg.sender] = User(_name, _age);
    }
}
