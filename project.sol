// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CompetitiveCoding {
    struct Challenge {
        string name;
        uint256 entryFee;
        uint256 prizePool;
        address winner;
        bool isActive;
    }

    address public owner;
    uint256 public challengeCount;
    mapping(uint256 => Challenge) public challenges;
    mapping(uint256 => address[]) public participants;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    event ChallengeCreated(uint256 challengeId, string name, uint256 entryFee);
    event Participated(uint256 challengeId, address participant);
    event WinnerDeclared(uint256 challengeId, address winner);

    constructor() {
        owner = msg.sender;
    }

    function createChallenge(string memory _name, uint256 _entryFee) public onlyOwner {
        require(_entryFee > 0, "Entry fee must be greater than zero");

        challenges[challengeCount] = Challenge({
            name: _name,
            entryFee: _entryFee,
            prizePool: 0,
            winner: address(0),
            isActive: true
        });

        emit ChallengeCreated(challengeCount, _name, _entryFee);
        challengeCount++;
    }

    function participate(uint256 _challengeId) public payable {
        Challenge storage challenge = challenges[_challengeId];
        require(challenge.isActive, "Challenge is not active");
        require(msg.value == challenge.entryFee, "Incorrect entry fee");

        challenge.prizePool += msg.value;
        participants[_challengeId].push(msg.sender);

        emit Participated(_challengeId, msg.sender);
    }

    function declareWinner(uint256 _challengeId, address _winner) public onlyOwner {
        Challenge storage challenge = challenges[_challengeId];
        require(challenge.isActive, "Challenge is not active");
        require(challenge.winner == address(0), "Winner already declared");

        challenge.winner = _winner;
        challenge.isActive = false;
        payable(_winner).transfer(challenge.prizePool);

        emit WinnerDeclared(_challengeId, _winner);
    }

    function getParticipants(uint256 _challengeId) public view returns (address[] memory) {
        return participants[_challengeId];
    }
}
///0xBD594615A37eB43a6331CC0ECA7ad52E5A77596B