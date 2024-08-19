// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Visibility {
    // Publika funktioner kan anropas både inifrån och utifrån kontraktet
    function publicFunction() public pure returns(string memory) {
        return "This is a public function!";
    }

    // Interna funktion kan endast anropas inifrån kontraktet
    function internalFunction() internal pure returns(string memory) {
        return "This is an internal function!";
    }

    // Privata funktioner kan endast anropas inifrån kontraktet och kan inte ärvas till barnkontrakt
    function privateFunction() private pure returns(string memory) {
        return "This is a private function!";
    }

    // Publika funktioner kan endast anropas utifrån kontraktet (det finns dock en work-around, se rad 33-36)
    function externalFunction() external pure returns(string memory) {
        return "This is an external function";
    }

    function callInternalFunction() public pure returns(string memory) {
        return internalFunction();
    }

    function callPrivateFunction() public pure returns(string memory) {
        return privateFunction();
    }

    // Work-around för att anropa en extern funktion inifrån ett kontrakt. Notera att vi använder this. och view i stället för pure
    function callExternalFunction() public view returns(string memory) {
        return this.externalFunction();
    }
}

// Vi låter kontraktet "VisibilityChild" ärva från kontraktet "Visibility" genom att använda oss av ordet "is"
contract VisibilityChild is Visibility {
    function callParentInternalFunction() public pure returns(string memory) {
        return internalFunction();
    }

    // Vi kommer inte åt den privata funktionen i vårt barnkontrakt, varav funktionen nedan göra att kontraktet inte kompileras
    // Koden finns kvar, men kommenterad, i demo-syfte
    /* function callParentPrivatFunction() public pure returns(string memory) {
        return privateFunction();
    } */
}
