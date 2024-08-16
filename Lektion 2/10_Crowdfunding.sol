// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Crowdfunding {
    // Owner är i detta fall den som startar insamlingen, och som får pengarna om målet uppfylls
    address public owner;
    uint public goal;
    uint public deadline;
    bool public goalReached;
    uint public currentBalance;

    // Vi skapar en mapping över de som bidragit, och deras totalsumma, för att kunna betala tillbaka pengarna om målet inte uppfylls
    mapping(address => uint) public contributors;

    // Denna lektion gick vi igenom constructor, och använder det här för att sätta våra variablers initiala värden
    constructor(uint _goal, uint _duration) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
        goalReached = false;
    }

    // Funktion för att lämna bidrag till insamlingen
    // Notera att vi här använder oss av payable, vilket möjliggör att vi kan skicka ETH till funktionen
    function contribute() public payable {
        require(block.timestamp < deadline, "Deadline passed");

        // Vi uppdaterar vår mapping, för att hålla koll på hur mycket denna användare har bidragit med
        // msg.sender = Den som anropar kontraktet. msg.value = Hur mycket användaren skickade med (när funktionen kallades)
        contributors[msg.sender] += msg.value;

        // Uppdatering av vårt totalt insamlade värde
        currentBalance += msg.value;

        // Om målet uppnåddes vid denna transaktion vill vi uppdatera goalReached till true
        if (currentBalance >= goal) {
            goalReached = true;
        }
    }

    function withdrawFund() public {
        // Vi kontrollerar att deadline har passerat innan vi låter ägaren eller givarna hämta sina pengar
        // Raden för require är kommenterad för att underlätta vid demonstrationen 
        // require(block.timestamp >= deadline, "Deadline not reached");

        // Om målet uppnåddes vill vi betala ut pengarna till den som startade insamlingen
        if (goalReached) {
            require(msg.sender == owner, "Only the owner can withdraw the funds");

            // Vi för över currentBalance till en lokal variabel och sätter currentBalance till 0 innan vi för över pengarna
            // Vi vill undvika reentrancy attacker
            uint _amountToTransfer = currentBalance;
            currentBalance = 0;

            // Överföring av pengarna
            payable(owner).transfer(_amountToTransfer);
        
        // Om målet inte uppnåddes vill vi betala tillbaka pengarna till de som bidragit
        // Vi lägger återigen in ett skydd mot reentancy attacker
        } else {
            uint _amount = contributors[msg.sender];
            contributors[msg.sender] = 0;
            currentBalance -= _amount;
            payable(msg.sender).transfer(_amount);
        }
    }
}
