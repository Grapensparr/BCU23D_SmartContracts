// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract HelloWorld {
    // Message är en state variabel, vars värde vi kan ändra. Vi sätter det initialt till "Hello world".
    string public message = "Hello world";

    // Write funktion - Ändrar värdet av vår state variabel (message) till vår lokala variabel (_newMessage).
    function setMessage(string memory _newMessage) public {
        message = _newMessage;
    }

    // Detta behövs ej i detta kontrakt!
    // Read funktion - Läser av från blockkedjan - Behövs inte i detta kontrakt iom publik variabel, men lämnas kvar som exempel.
    function getMessage() public view returns(string memory) {
        return message;
    }
}
