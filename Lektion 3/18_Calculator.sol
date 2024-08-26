// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

// Vi skapar ett bibliotek
library MathLibrary {
    function add(uint a, uint b) internal pure returns(uint) {
        return a + b;
    }

    function subtract(uint a, uint b) internal pure returns(uint) {
        return a - b;
    }

    function multiply(uint a, uint b) internal pure returns(uint) {
        return a * b;
    }
}

// Vi skapar ett kontrakt som kan kalla på funktionerna i biblioteket
contract Calculator {
    using MathLibrary for uint;

    function add(uint a, uint b) public pure returns(uint) {
        // Nedan är två olika exempel på hur man kan kalla på funktionerna i biblioteket. Båda anges i demo-syfte,
        // välj det skrivsätt som ni tycker känns bäst
        //return MathLibrary.add(a, b);
        return a.add(b);
    }

    function subtract(uint a, uint b) public pure returns(uint) {
        return a.subtract(b);
    }

    function multiply(uint a, uint b) public pure returns(uint) {
        return a.multiply(b);
    }
}
