// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./LiquidityPool (1).sol";

contract AllPoolManager {
    
    mapping(string => LiquidityPool) liquidityPoolMap;
    mapping(address => mapping(address => LiquidityPool.Pool)) public miniPools;

    function AddLiquidity(
        string memory name,
        address token1,
        address token2,
        uint256 token1Amount,
        uint256 token2Amount,
        uint256 lowPrice,
        uint256 highPrice
    ) external returns (LiquidityPool) {
        require(highPrice > lowPrice, "high range must exceed low range");
        
        // Ensure the liquidity pool exists
        require(address(liquidityPoolMap[name]) != address(0), "Liquidity pool does not exist");

        // Call addLiquidity function on the liquidity pool instance
        ILiquidityPool(address(liquidityPoolMap[name])).addLiquidity(token1, token2, token1Amount, token2Amount, lowPrice, highPrice);
        
        // Assuming poolPortions is a public mapping in LiquidityPool
        miniPools[address(liquidityPoolMap[name])][msg.sender] = ILiquidityPool(address(liquidityPoolMap[name])).poolPortions[msg.sender];
        
        return liquidityPoolMap[name];
    }

    function createPool(
        string memory name,
        address token1,
        address token2,
        uint24 fee,
        uint256 lowPrice,
        uint256 highPrice
    ) external returns (LiquidityPool) {
        require(highPrice > lowPrice, "high range must exceed low range");
        
        // Create a new liquidity pool instance
        LiquidityPool liquidityPool = new LiquidityPool(name, token1, token2, fee, lowPrice, highPrice);
        
        // Store the liquidity pool instance in the map
        liquidityPoolMap[name] = liquidityPool;
        
        return liquidityPool;
    }

    function getAvgPrice(uint256 lowPrice, uint256 highPrice) public pure returns (uint256) {
        return (highPrice + lowPrice) / 2;
    }
}
