// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract MappingLibraryModifier {
    // Vi återanvänder vårt "MappingLibrary" kontrakt, och lägger in två modifiers. Se kommentarer nedan för förändringar
    struct Book {
        string title;
        uint year;
        bool exist;
    }

    mapping(string => mapping(string => Book)) internal authorBooks;
    mapping(string => string[]) internal authorBookTitles;

    // Vi lägger till två modifiers, som sedan används på tre platser i koden
    modifier bookDoesNotExist(string memory _author, string memory _title) {
        require(!authorBooks[_author][_title].exist, "Book already exist");
        _;
    }

    modifier bookExists(string memory _author, string memory _title) {
        require(authorBooks[_author][_title].exist, "Book does not exist");
        _;
    }

    // Vi lägger till en modifier i slutet av rad 27
    function addBook(string memory _title, string memory _author, uint _year) public bookDoesNotExist(_author, _title){
        // I och med vår modifier "bookDoesNotExist" behöver vi inte länge vår require nedan
        //require(!authorBooks[_author][_title].exist, "Book already exist");

        authorBooks[_author][_title] = Book(_title, _year, true);
        authorBookTitles[_author].push(_title);
    }

    function getBookCountByAuthor(string memory _author) public view returns(uint) {
        return authorBookTitles[_author].length;
    }

    // Vi lägger till en modifier i slutet av rad 40
    function updateBook(string memory _author, string memory _oldTitle, string memory _newTitle, uint _newYear) public bookExists(_author, _oldTitle) {
        // I och med vår modifier "bookExists" behöver vi inte länge vår require nedan
        //require(authorBooks[_author][_oldTitle].exist, "Book does not exist");

        if (keccak256(bytes(_oldTitle)) != keccak256(bytes(_newTitle))) {
            require(!authorBooks[_author][_newTitle].exist, "New title already exists");

            authorBooks[_author][_newTitle] = Book(_newTitle, _newYear, true);

            delete authorBooks[_author][_oldTitle];

            for (uint i = 0; i < authorBookTitles[_author].length; i++) {
                if (keccak256(bytes(authorBookTitles[_author][i])) == keccak256(bytes(_oldTitle))) {
                    authorBookTitles[_author][i] = _newTitle;
                    break;
                }
            }
        } else {
            authorBooks[_author][_oldTitle].year = _newYear;
        }
    }

    // Vi lägger till en modifier i slutet av rad 63
    function deleteBook(string memory _author, string memory _title) public bookExists(_author, _title) {
        // I och med vår modifier "bookExists" behöver vi inte länge vår require nedan
        require(authorBooks[_author][_title].exist, "Book does not exist");

        delete authorBooks[_author][_title];

        for (uint i = 0; i < authorBookTitles[_author].length; i++) {
            if (keccak256(bytes(authorBookTitles[_author][i])) == keccak256(bytes(_title))) {
                authorBookTitles[_author][i] = authorBookTitles[_author][authorBookTitles[_author].length -1];
                authorBookTitles[_author].pop();
                break;
            }
        }
    }

    function getBooksByAuthor(string memory _author) public view returns(string[] memory _titles, uint[] memory _years) {
        uint count = authorBookTitles[_author].length;

        _titles = new string[](count);
        _years = new uint[](count);

        for (uint i = 0; i < count; i++) {
            string memory _title = authorBookTitles[_author][i];
            Book storage book = authorBooks[_author][_title];
            _titles[i] = book.title;
            _years[i] = book.year;
        }

        return(_titles, _years);
    }
}
