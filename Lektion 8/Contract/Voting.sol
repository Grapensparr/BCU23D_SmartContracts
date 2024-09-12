// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

contract Voting {
    enum VotingState { NotStarted, Ongoing, Finished }

    struct Candidate {
        string name;
        uint voteCount;
    }

    Candidate[] public candidates;
    VotingState public votingState;
    mapping(address => bool) public hasVoted;
    string public winner;
    address internal owner;

    event VotingStarted();
    event VoteCast(string candidate, address voter);
    event VotingFinished(string winner);

    constructor(string[] memory _votingOptions) {
        owner = msg.sender;
        for (uint i = 0; i < _votingOptions.length; i++) {
            candidates.push(Candidate({
                name: _votingOptions[i],
                voteCount: 0
            }));
        }
        votingState = VotingState.NotStarted;
        winner = "";
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can start the voting!");
        _;
    }

    modifier inState(VotingState _state) {
        require(votingState == _state, "Invalid state, you cannot perform this action");
        _;
    }

    function startVoting() public onlyOwner inState(VotingState.NotStarted) {
        votingState = VotingState.Ongoing;
        emit VotingStarted();
    }

    function vote(string memory _votingOption) public inState(VotingState.Ongoing) {
        require(!hasVoted[msg.sender], "You have already voted");

        bool _found = false;
        for (uint i = 0; i < candidates.length; i++) {
            if (keccak256(bytes(candidates[i].name)) == keccak256(bytes(_votingOption))) {
                candidates[i].voteCount += 1;
                _found = true;

                emit VoteCast(candidates[i].name, msg.sender);

                if (candidates[i].voteCount == 5) {
                    votingState = VotingState.Finished;
                    winner = candidates[i].name;

                    emit VotingFinished(winner);
                }
                break;
            }
        }

        require(_found, "Name not found");
        hasVoted[msg.sender] = true;
    }

    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }
}