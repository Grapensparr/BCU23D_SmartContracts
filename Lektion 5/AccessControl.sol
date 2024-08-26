// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract AccessControl {
    mapping(address => bool) public admins;
    mapping(address => bool) public supporters;
    mapping(address => bool) public members;

    event RoleAssigned(address indexed account, string role);

    constructor() {
        admins[msg.sender] = true;
        emit RoleAssigned(msg.sender, "Admin");
    }

    modifier onlyAdmin() {
        require(admins[msg.sender], "You are not an admin and cannot call this function");
        _;
    }

    function assignAdminRole(address _account) public onlyAdmin {
        admins[_account] = true;
        emit RoleAssigned(_account, "Admin");
    }

    function assignSpecificRole(address _account, string memory _role) public onlyAdmin {
        if (keccak256(bytes(_role)) == keccak256(bytes("Supporter"))) {
            supporters[_account] = true;
        } else if (keccak256(bytes(_role)) == keccak256(bytes("Member"))) {
            members[_account] = true;
        } else {
            revert("Invalid role. Try again!");
        }

        emit RoleAssigned(_account, _role);
    }
}
