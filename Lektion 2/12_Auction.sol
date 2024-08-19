// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Auction {
    // Vi skriver en struct för att definiera den information vi vill lagra om varje bud
    struct Bid {
        address bidder;
        uint amount;
    }

    // Vi skapar en array av bud
    Bid[] public bids;
    uint public minimumBid;

    // Vi använder oss av en contructor för att definiera vårt minimum bud
    constructor (uint _minimumBid) {
        minimumBid = _minimumBid;
    }

    // Funktion för att lägga ett nytt bud
    function placeBid() public payable {
        require(msg.value > 0, "Bid amount must be greater than 0");
        
        // Ett annat sätt att skriva än vad vi gått igenom hittills, i demonstrationssyfte 
        bids.push(Bid({
            bidder: msg.sender,
            amount: msg.value
        }));
    }

    // Funktion för att räkna ut och returnera genomsnittet av de bud som är över accepterat pris (minimumBid)
    function calculateAverageBidAboveMin() public view returns (uint _average) {
        uint i = 0;
        uint _total = 0;
        uint _count = 0;

        if(bids.length == 0) {
            return 0;
        }

        // Do-while loop
        do {
            if (bids[i].amount >= minimumBid) {
                _total += bids[i].amount;
                _count++;
            }
            i++;
        } while (i < bids.length);

        _average = _total / _count;

        return _average;
    }
}
