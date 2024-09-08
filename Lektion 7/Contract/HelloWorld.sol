// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract HelloWorld {
    string public message;

    event MessageUpdate(string oldMsg, string newMsg);

    constructor(string memory _newMessage) {
        message = _newMessage;
    }
 
    function setMessage(string memory _newMessage) public {
        string memory _oldMessage = message;
        message = _newMessage;
        emit MessageUpdate(_oldMessage, _newMessage);
    }
}