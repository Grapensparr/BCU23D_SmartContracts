// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract LibraryLimit {
    // Vi använder en struct för att kapsla in relaterade datafält i en sammanhängande enhet
    struct Book{
        string title;
        string author;
        uint16 year;
    }

    // Vi skapar en fast (begränsad (max 5)) array av vår struct, och vi kallar vår array för books 
    Book[5] public books;

    // bookcount är en state variabel, vars värde ändras när vi lägger till en bok. Vi sätter det initialt till 0.
    uint public bookcount = 0;

    // Write funktion där vi lägger till en bok i vår array, utifrån den input vi anger.
    function addBook(string memory _title, string memory _author, uint16 _year) public {
        // Vi lägger till en bok i vår array, på samma index som vår nuvarande bookcount är.
        books[bookcount] = Book(_title, _author, _year);
        // Vi ökar vår bookcount med 1, vilket säkerställer att nästa bok läggs till på nästa tillgängliga index.
        bookcount++;
    }
}
