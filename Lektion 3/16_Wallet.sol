// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Wallet{
    uint public contractBalance;
    bool private locked = true;
    mapping(address => uint) internal balances;

    // Vi lägger till två events
    event DepositMade(address indexed accountAddress, uint amount);
    event WithdrawalMade(address indexed accountAddress, uint amount);

    // Vi skapar en modifier för att unvika reentrancy attacker (vi låser här funktionen, och den kommer inte att
    // kunna anropas igen innan pågående transaktion är klar
    modifier noReentrancy() {
        require(!locked, "Stop making reentrancy calls! Please hold.");
        locked = true;
        _;
        locked = false;
    }

    // Vi skapar en modifier för att kontrollera att användaren saldo är högre än (eller lika med) den summa som 
    // användaren försöker ta ut
    modifier hasSufficientBalance(uint _withdrawAmount) {
        require(_withdrawAmount <= balances[msg.sender], "Not enough balance");
        _;
    }

    // Funktion för att sätta in ETH
    function deposit() public payable {
        balances[msg.sender] += msg.value;
        contractBalance += msg.value;

        // Vi använder oss av assert för att säkerställa att funktionen har fungerat som tänkt
        assert(contractBalance == address(this).balance);

        // Vi skickar ut ett event varje gång en deposit har genomförts
        emit DepositMade(msg.sender, msg.value);
    }

    // Funktion för att ta ut ETH
    function withdraw(uint _withdrawAmount) public noReentrancy hasSufficientBalance(_withdrawAmount) {
        if (_withdrawAmount > 1 ether) {
            // Vi använder oss av revert, främst i demo-syfte, för att visa hur vi kan avbryta en transaktion och lämna
            // ett felmeddelande
            revert("You cannot withdraw more than 1 ETH per transaction");
        }

        balances[msg.sender] -= _withdrawAmount;
        contractBalance -= _withdrawAmount;

        payable(msg.sender).transfer(_withdrawAmount);

        // Vi använder oss av assert för att säkerställa att funktionen har fungerat som tänkt
        assert(contractBalance == address(this).balance);

        // Vi skickar ut ett event varje gång en withdrawl har genomförts
        emit WithdrawalMade(msg.sender, _withdrawAmount);
    }
}
