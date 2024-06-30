// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiquidityPool.sol";

contract AllPoolManager {
    function createLiquidityPool(address tokenA, address tokenB) public {
        LiquidityPool pool = new LiquidityPool(
            tokenA, 
            tokenB, 
            500, // Example fee
            1000, // Example reserve0
            2000, // Example reserve1
            3000 // Example liquidity
        );

        // If reserves are not used, remove the following line
        // (uint256 reserve0, uint256 reserve1) = pool.getReserves();

        // Add your logic here if needed
    }
}
