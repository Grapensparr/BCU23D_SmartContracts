// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract MappingLibrary {
    // Vi skapar ett struct för att definiera vilken information vi vill ha om varje bok
    struct Book {
        string title;
        uint year;
        bool exist;
    }

    // Vi skapar en mapping i en mapping. I första mappingen använder vi författarens namn som key, och där värdet är vår andra mapping.
    // I den andra mappingen använder vi bokens titel som key, där vårt Book struct för denna titel är vårt värde.
    mapping(string => mapping(string => Book)) internal authorBooks;

    // Vi skapar en mapping, där författarens namn är vår key, och värdet är en array (där vi kommer lagra böckernas titlar).
    mapping(string => string[]) internal authorBookTitles;

    // Funktion för att lägga till en ny bok
    function addBook(string memory _title, string memory _author, uint _year) public {
        // Vi kontrollerar att det ännu inte finns någon bok för denna författare med den angivna titeln, detta för att undvika duplikat.
        require(!authorBooks[_author][_title].exist, "Book already exist");

        // Vi lägger till en bok enligt vårt Book struct till vår authorBooks mapping
        authorBooks[_author][_title] = Book(_title, _year, true);

        // Vi lägger till titeln till vår array för just denna författare
        authorBookTitles[_author].push(_title);
    }

    // Funktion för att hämta hem antal böcker som finns registrerade för en viss författare
    function getBookCountByAuthor(string memory _author) public view returns(uint) {
        return authorBookTitles[_author].length;
    }

    // Funktion för att uppdatera en boks information
    function updateBook(string memory _author, string memory _oldTitle, string memory _newTitle, uint _newYear) public {
        // Vi kontrollerar att den angivna författaren har en bok registrerad med "_oldTitle" titeln, för att säkerställa att det finns en bok att uppdatera
        require(authorBooks[_author][_oldTitle].exist, "Book does not exist");

        // Vi använder oss av keccak256 för hashning av titlar (omvandlade till bytes), som sedan jämförs
        if (keccak256(bytes(_oldTitle)) != keccak256(bytes(_newTitle))) {
            // Vi kontrollerar att den nya titeln inte redan finns registrerad för författaren, för att undvika duplikat
            require(!authorBooks[_author][_newTitle].exist, "New title already exists");

            // Jämför med addBook funktionen. Vi lägger till en bok i vår mapping
            authorBooks[_author][_newTitle] = Book(_newTitle, _newYear, true);

            // Vi tar bort boken med den gamla titeln
            delete authorBooks[_author][_oldTitle];

            // Vi uppdaterar vår array med den nya titeln
            for (uint i = 0; i < authorBookTitles[_author].length; i++) {
                if (keccak256(bytes(authorBookTitles[_author][i])) == keccak256(bytes(_oldTitle))) {
                    authorBookTitles[_author][i] = _newTitle;
                    break;
                }
            }
        } else {
            // Om titlarna är identiska, men årtalet behöver uppdateras, körs nedan kod för att uppdatera vår mapping
            authorBooks[_author][_oldTitle].year = _newYear;
        }
    }

    // Funktion för att ta bort en bok
    function deleteBook(string memory _author, string memory _title) public {
        // Vi kontrollerar att det finns en bok som stämmer överens med input-parametrarna
        require(authorBooks[_author][_title].exist, "Book does not exist");

        // Vi tar bort boken från vår mapping
        delete authorBooks[_author][_title];

        // Vi tar bort boken från vår array
        for (uint i = 0; i < authorBookTitles[_author].length; i++) {
            if (keccak256(bytes(authorBookTitles[_author][i])) == keccak256(bytes(_title))) {
                // Aktuell bok hamnar sist i arrayen, och vi tar sedan bort den
                authorBookTitles[_author][i] = authorBookTitles[_author][authorBookTitles[_author].length -1];
                authorBookTitles[_author].pop();
                break;
            }
        }
    }

    // Funktion för att hämta hem alla böcker av en viss författare
    function getBooksByAuthor(string memory _author) public view returns(string[] memory _titles, uint[] memory _years) {
        uint count = authorBookTitles[_author].length;

        // Vi skapar nya (temporära) arrayer, där vi kommer förvara de titlar och år som finns för författaren
        _titles = new string[](count);
        _years = new uint[](count);

        // Vi lägger till varje titel och årtal till våra temporära arrayer
        for (uint i = 0; i < count; i++) {
            string memory _title = authorBookTitles[_author][i];
            Book storage book = authorBooks[_author][_title];
            _titles[i] = book.title;
            _years[i] = book.year;
        }

        return(_titles, _years);
    }
}
