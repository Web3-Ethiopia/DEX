// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
contract FrontendHook {
    mapping(address => string) public userMoods;
    event MoodUpdated(address indexed user, string mood);
    function setMood(string memory _mood) public {
        userMoods[msg.sender] = _mood;
        emit MoodUpdated(msg.sender, _mood);
    }
    function getMood() public view returns (string memory) {
        return userMoods[msg.sender];
    }
}