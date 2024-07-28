// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;
import "DEX/src/Frontendintegration.sol";
contract FrontendIntegrationTest is ERC20 {
    FrontendIntegration public frontendIntegration;

    constructor(string memory name, string memory symbol, uint256 initialSupply)
        ERC20(name, symbol)
    {
        _mint(msg.sender, initialSupply);
    }

    function deployFrontendIntegration() public {
        frontendIntegration = new FrontendIntegration(address(this));
    }

    function testTransferTokens(address _to, uint256 _amount) public {
        approve(address(frontendIntegration), _amount);
        frontendIntegration.transferTokens(_to, _amount);
    }

    function testApproveTokens(address _spender, uint256 _amount) public {
        frontendIntegration.approveTokens(_spender, _amount);
    }

    function testGetTokenBalance() public view returns (uint256) {
        return frontendIntegration.getTokenBalance();
    }
}