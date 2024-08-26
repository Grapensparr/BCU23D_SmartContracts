// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract AuctionExercise {
    // Vi skapar en struct med den information som vi vill lagra om varje vara
    struct Item {
        uint id;
        string title;
        address owner;
        bool isForSale;
    }

    // Vi skapar en till struct, denna gång med den information som vill lagra om varje auktion
    struct Auction {
        uint auctionId;
        uint minimumPrice;
        uint deadline;
        address highestBidder;
        uint highestBid;
        bool active;
    }

    // Vi använder oss itemCount för att generera ett ID för varje vara
    uint public itemCount;

    // Vi skapar tre mappings (en för våra varor, en för auktioner och en för de som förlorat en budgivning 
    // (refund, där vi lagrar information om hur mycket varje address ska kunna "ta tillbaka"))
    mapping(uint => Item) public items;
    mapping(uint => Auction) public auctions;
    mapping(address => uint) internal refund;

    // Funktion för att lägga till en vara, som vi därefter kan lägga ut till auktion
    function addItem(string memory _title) public {
        for (uint i = 1; i <= itemCount; i++) {
            // Om båda nedan är false kommer funktionen avbrytas, eftersom msg.sender då redan har en vara med den angivna titeln
            // Det räcker med att ett av påståendena är true för att funktionen ska fortsätta
            require(items[i].owner != msg.sender || keccak256(bytes(items[i].title)) != keccak256(bytes(_title)), "You already have this item");
        }

        // Vi ökar itemCount med 1, för att få ett unikt ID för den vara som nu läggs till
        itemCount++;
        // Vi lägger till vår vara till vår items mapping
        items[itemCount] = Item(itemCount, _title, msg.sender, false);
    }

    // Funktion för att starta en auktion för en vara
    function startAuction(uint _itemId, uint _minPrice, uint _duration) public {
        Item storage item = items[_itemId];

        // Vi säkerställer att det endast är ägaren av varan som kan starta auktionen, samt att varan ännu inte är till salu
        require(item.owner == msg.sender, "Only the owner can start this auction");
        require(!item.isForSale, "This items is already for sale");

        item.isForSale = true;

        // Vi lägger till den aktuella varan till vår auctions mapping, med den angivna informationen i funktionens input-fält
        auctions[_itemId] = Auction({
            auctionId: _itemId,
            minimumPrice: _minPrice,
            deadline: block.timestamp + _duration,
            highestBidder: address(0),
            highestBid: 0,
            active: true
        });
    }

    // Funktion för att lämna bud
    function placeBid(uint _auctionId) public payable {
        Auction storage auction = auctions[_auctionId];
        Item storage item = items[_auctionId];

        // Vi kontrollerar att auktionen är pågående, att det inte är ägaren som försöker lägga ett bud, samt att det
        // angivna värdet (msg.value) är högre än både accept-priset och det högsta budet
        require(auction.active, "The auction has ended");
        require(msg.sender != item.owner, "You cannot place a bid on your own item!");
        require(msg.value >= auction.minimumPrice, "The minimum price is higher.");
        require(msg.value > auction.highestBid, "The is already a higher bid. Bid more!");

        // Om ledande budgivare INTE är address(0) kommer den ledande budgivaren och dess bud läggas till i vår refund-mapping
        // Användare som förlorat en budgivning kan få tillbaka sina pengar genom att anropa "withdraw" funktionen nedan
        if (auction.highestBidder != address(0)) {
            refund[auction.highestBidder] += auction.highestBid;
        }

        // Uppdatering om auktionens ledande budgivare och värdet på det högsta budet
        auction.highestBidder = msg.sender;
        auction.highestBid = msg.value;
    }

    // Funktion för att avsluta auktion. Används här främst i demo-syfte, kan annars kallas på av admin för sidan
    function endAuction(uint _auctionId) public {
        Auction storage auction = auctions[_auctionId];
        Item storage item = items[_auctionId];

        require(item.owner == msg.sender, "Only the owner can end the auction");
        // Vi kommenterar bort require för deadline, för att underlätta i demo-syfte
        //require(block.timestamp > auction.deadline, "The auction deadline is not met");

        // Vi lägger in nedan require som skydd för reentrancy attacker
        require(auction.active, "The auction is not active");

        auction.active = false;
        item.isForSale = false;

        
        if(auction.highestBidder != address(0)) {
            // Utbetalning av högsta budet till varans ägare
            payable(item.owner).transfer(auction.highestBid);

            // Uppdatering av ägarskap för varan. Den nya ägaren kan nu, på nytt, lägga ut vara till försäljning
            item.owner = auction.highestBidder;
        }
    }

    // Funktion som möjliggör återbetalning av förlorade bud
    function withdraw() public {
        uint _amount = refund[msg.sender];
        require(_amount > 0, "You have no money!");

        refund[msg.sender] = 0;

        payable(msg.sender).transfer(_amount);
    }

    // Funktion för att få fram ledange budgivare och högsta bud för varje auktion
    function getHighestBid(uint _auctionId) public view returns(uint, address) {
        Auction storage _auction = auctions[_auctionId];
        return(_auction.highestBid, _auction.highestBidder);
    }
}
