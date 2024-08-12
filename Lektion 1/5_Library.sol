// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Library {
    // Vi använder en struct för att kapsla in relaterade datafält i en sammanhängande enhet
    struct Book{
        string title;
        string author;
        uint16 year;
    }

    // Vi skapar en dynamisk (obegränsad) array av vår struct, och vi kallar vår array för books 
    Book[] public books;

    // Write funktion där vi lägger till en bok i vår array, utifrån den input vi anger.
    function addBook(string memory _title, string memory _author, uint16 _year) public {
        books.push(Book(_title, _author, _year));
    }

    // View funktion där returnerar antalet böcker i vår array.
    function bookCount() public view returns(uint) {
        return books.length;
    }

    // Write funktion där vi tar bort information om en bok i vår array. Index för denna bok ligger kvar, men är tom.
    function removeBookInformation(uint _index) public {
        require(_index < books.length, "The index does not exist!");
        delete books[_index];
    }

    // Write funktion där vi tar bort en bok i vår array. Index för denna bok försvinner.
    function removeBookIndex(uint16 _index) public {
        require(_index < books.length, "The index does not exist!");
        // Vi flyttar boken längst bak genom att ge den ett nytt index
        books[_index] = books[books.length - 1];
        // Vi tar bort det sista värdet i vår array
        books.pop();
    }
}
