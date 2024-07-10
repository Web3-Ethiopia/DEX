//SPDX-LICENSE-IDENTIFIER:UNLICENSED;
pragma solidity ^0.8.0;
import "@openzeppelin/interfaces/IERC20.sol";
import {IERC20} from "../token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract MyTokenContract is Ownable {
    IERC20 public token;
    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
    }
    function transfer(address recipient, uint256 amount) external onlyOwner {
        require(token.transfer(recipient, amount), "Transfer failed");
    }
    function balanceOf(address account) external view returns (uint256) {
        return token.balanceOf(account);
    }
}
