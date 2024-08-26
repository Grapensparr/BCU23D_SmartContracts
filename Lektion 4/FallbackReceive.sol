// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract FallbackReceive{
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
