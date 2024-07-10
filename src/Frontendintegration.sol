solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FrontendIntegration {
    using SafeMath for uint256;

    IERC20 public token;
    address public owner;

    event TokenTransferred(address indexed from, address indexed to, uint256 amount);

    constructor(address _token) {
        token = IERC20(_token);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    function transferTokens(address _to, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        require(token.balanceOf(address(this)) >= _amount, "Insufficient token balance");
        token.transfer(_to, _amount);
        emit TokenTransferred(address(this), _to, _amount);
    }

    function approveTokens(address _spender, uint256 _amount) public onlyOwner {
        require(_amount > 0, "Amount must be greater than 0");
        token.approve(_spender, _amount);
    }

    function getTokenBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
}