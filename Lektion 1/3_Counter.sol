// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Counter {
    // count är en state variabel, vars värde vi kan ändra. Vi sätter det initialt till 0.
    // Variabeln är av datatypen uint, vilket bara accepterar positiva heltal.
    //Ändra till int om ni vill använda er av både negativa och positiva heltal.
    uint public count = 0;

    // Write funktion - Ökar värdet av vår state variabel (count) med 1.
    function incrementCount() public {
        // Två olika exempel på samma sak, båda ökar värdet med 1.
        // count = count + 1;
        count++;
    }

    // Write funktion - Ökar värdet av vår state variabel (count) med den siffra vi skickar in.
    function incrementByNumber(uint _number) public {
        count = count + _number;
    }

    // Write funktion - Minskar värdet av vår state variabel (count) med 1.
    function decrementCount() public {
        // Två olika exempel på samma sak, båda minskar värdet med 1.
        // count = count - 1;
        count--;
    }

    // Write funktion - Minskar värdet av vår state variabel (count) med den siffra vi skickar in.
    function decrementByNumber(uint _number) public {
        count = count - _number;
    }
}
