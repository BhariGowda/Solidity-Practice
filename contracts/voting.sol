// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Voting {
    address public owner;
    mapping(address => bool) public hasVoted;
    mapping(string => uint256) public votes;
    string[] public candidates;

    event Voted(address voter, string candidate);

    constructor(string[] memory _candidates) {
        owner = msg.sender;
        candidates = _candidates;
    }

    function vote(string memory candidate) external {
        require(!hasVoted[msg.sender], "Already voted");
        hasVoted[msg.sender] = true;
        votes[candidate]++;
        emit Voted(msg.sender, candidate);
    }

    function getVotes(string memory candidate)
        external view returns (uint256) {
        return votes[candidate];
    }
}