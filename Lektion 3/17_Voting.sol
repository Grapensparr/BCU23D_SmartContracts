// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract Voting {
    // Vi definierar vårt enum, som i detta fall kan anta tre värden (0-2)
    enum VotingState { NotStarted, Ongoing, Finished }

    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] public candidates;
    VotingState public votingState;
    mapping(address => bool) public hasVoted;
    string public winner;

    // Vi skickar in en array med namn när vi deployar kontraktet, till exempel ["Anna", "Pelle"]. Det är dessa namn som vi sedan kan rösta på
    constructor(string[] memory _votingOptions) {
        for (uint i = 0; i < _votingOptions.length; i++) {
            candidates.push(Candidate({
                name: _votingOptions[i],
                voteCount: 0
            }));
        }
        votingState = VotingState.NotStarted;
        winner = "";
    }

    // Vi använder vårt enum för att kontrollera vilka funktioner som kan anropas i kontraktet
    modifier inState(VotingState _state) {
        require(votingState == _state, "Invalid state, you cannot perform this action");
        _;
    }

    // Funktionen kontrollerar att vårt enom har värdet "NotStarted", om detta stämmer kommer vi uppdatera vårt enum
    // till Ongoing, vilket gör att vi därefter kan anropa funktionen "vote"
    function startVoting() public inState(VotingState.NotStarted){
        votingState = VotingState.Ongoing;
    }

    function vote(string memory _votingOption) public inState(VotingState.Ongoing) {
        require(!hasVoted[msg.sender], "You have already voted");

        bool _found = false;
        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(bytes(candidates[i].name)) == keccak256(bytes(_votingOption))) {
                candidates[i].voteCount += 1;
                _found = true;

                // Om en kandidat har fått 5 röster kommer röstningen att avslutas och vårt enum får värdet "Finished"
                // Vi kommer inte längre kunna kalla på funktionen "vote", då vi nu har en vinnare
                if (candidates[i].voteCount == 5) {
                    votingState = VotingState.Finished;
                    winner = candidates[i].name;
                }
                break;
            }
        }

        // Om användaren har försökt rösta på ett namn som inte finns med bland våra kandidater kommer transaktionen 
        // avbrytas i detta skede, och användaren får möjlighet att lägga en ny röst
        require(_found, "Name not found");

        // Vi uppdaterar hasVoted, för att säkerställa att varje användare bara kan lägga en röst
        hasVoted[msg.sender] = true;
    }
}
