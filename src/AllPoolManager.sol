// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

import "./IAllPoolManager.sol";
import "./LiquidityPool.sol";
import "./StructsForLP.sol";

contract AllPoolManager {
    
    mapping(string => LiquidityPool) public liquidityPoolMap;
    mapping(address => mapping(address=>LiquidityPool.Pool)) public miniPools;

    mapping(string => address) private poolAddresses; // Mapping to store pool addresses

    // Declare the PoolCreated event
    event PoolCreated(address indexed pool, address indexed token0, address indexed token1, uint24 fee);

    function createPool(
        string memory name,
        address token1,
        address token2,
        uint24 fee,
        uint256 lowPrice,
        uint256 highPrice
    ) external returns (address poolAddress) {
        require(highPrice > lowPrice, "high range must exceed low range");
        LiquidityPool liquidityPool = new LiquidityPool(name, token1, token2, fee, lowPrice, highPrice);
        poolAddresses[name] = address(liquidityPool); // Store the pool address
        emit PoolCreated(address(liquidityPool), token1, token2, fee); // Emit the PoolCreated event
        return address(liquidityPool);
    }

    function AddLiquidity(
        string memory name,
        uint256 token1Amount,
        uint256 token2Amount,
        uint256 lowPrice,
        uint256 highPrice
    ) external {
        require(highPrice > lowPrice, "high range must exceed low range");
        address poolAddress = poolAddresses[name]; // Retrieve the pool address
        ILiquidityPool(poolAddress).addLiquidity(poolAddress, token1Amount, token2Amount, lowPrice, highPrice, msg.sender);
    }

    function getAvgPrice(uint256 lowPrice, uint256 highPrice) public returns (uint256) {
        return (highPrice - lowPrice) / 2;
    }
}
