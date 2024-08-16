// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract ContractOwner {
    // owner är en state variabel, vars värde vi kan ändra. Vi sätter det initialt till den adress som först deployar kontraktet.
    address public owner = msg.sender;

    // Write funktion - Ändrar värdet av vår state variabel (owner) till vår lokala variabel (_newOwner)
    // Funktion för att byta ägare till kontraktet
    function updateOwner(address _newOwner) public {
        // Require används här för att begränsa möjligheten till att använda funktionen.
        // Vi kräver här att den som anropar kontraktet ska ha samma adress som nuvarande owner, för att ägarskapet ska gå igenom.
        require(msg.sender == owner, "Only the current owner can change the ownership!");
        owner = _newOwner;
    }
}
