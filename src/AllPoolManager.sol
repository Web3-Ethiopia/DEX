// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiqidityPool.sol";

contract AllPoolManager {
    mapping(string => address) public liquidityPoolMap;

    function createPool(string memory poolName, address token0, address token1, uint24 fee, uint256 lowPrice, uint256 highPrice) public returns (address) {
        require(liquidityPoolMap[poolName] == address(0), "Pool already exists");
        
        LiquidityPool pool = new LiquidityPool(poolName, token0, token1, fee, lowPrice, highPrice);
        liquidityPoolMap[poolName] = address(pool);
        
        return address(pool);
    }

    function addLiquidity(string memory poolName, uint256 amount0, uint256 amount1, uint256 lowPrice, uint256 highPrice, address provider) public {
        address poolAddress = liquidityPoolMap[poolName];
        require(poolAddress != address(0), "Pool does not exist");
        
        LiquidityPool(poolAddress).addLiquidity(poolName, amount0, amount1, lowPrice, highPrice, provider);
    }

    function removeLiquidity(string memory poolName, uint256 liquidityAmount, address provider) public returns (uint256, uint256) {
        address poolAddress = liquidityPoolMap[poolName];
        require(poolAddress != address(0), "Pool does not exist");

        return LiquidityPool(poolAddress).removeLiquidity(poolName, liquidityAmount, provider);
    }

    function getAvgPrice(uint256 lowPrice, uint256 highPrice) public pure returns (uint256) {
        return (lowPrice + highPrice) / 2;
    }

    function isMultiHopSwapPossible(string memory poolName1, string memory poolName2) public view returns (bool) {
        address poolAddress1 = liquidityPoolMap[poolName1];
        address poolAddress2 = liquidityPoolMap[poolName2];

        require(poolAddress1 != address(0), "Pool1 does not exist");
        require(poolAddress2 != address(0), "Pool2 does not exist");

        // Simplified check for multi-hop swap possibility
        return poolAddress1 != poolAddress2;
    }
}
