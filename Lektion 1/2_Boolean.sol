// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Boolean {
    // isActive är en state variabel, vars värde vi kan ändra. Vi sätter det initialt till false.
    bool public isActive = false;

    // Write funktion - Ändrar värdet av vår state variabel (isActive) till vår lokala variabel (_state)
    function setState(bool _state) public {
        isActive = _state;
    }
}
