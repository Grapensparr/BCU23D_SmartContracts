// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract WhileLoop {
    // Vi skapar en array av nummer
    uint[] internal numbers;

    // Funktion för att lägga till ett nummer till vår array
    function addNumber(uint _number) public {
        numbers.push(_number);
    }

    // Funktion för att summera samtliga nummer i vår array
    function sumNumber() public view returns(uint) {
        uint _sum = 0;
        uint i = 0;

        while (i < numbers.length) {
            _sum += numbers[i];
            i++;
        }

        return _sum;
    }
}
