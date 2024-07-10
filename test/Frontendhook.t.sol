solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./FrontendHook.sol";
contract FrontendHookTest {
    FrontendHook public frontendHook;

    constructor(address _frontendHook) {
        frontendHook = FrontendHook(_frontendHook);
    }

    function testSetMood(string memory _mood) public {
        frontendHook.setMood(_mood);
        assert(frontendHook.userMoods[msg.sender] == _mood);
    }

    function testGetMood() public view returns (string memory) {
        return frontendHook.getMood();
    }

    function testMoodUpdatedEvent() public {
        frontendHook.setMood("Happy");
        assert(frontendHook.MoodUpdatedEvent());
    }
}