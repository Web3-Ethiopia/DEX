// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "ds-test/test.sol";
import "../src/LiquidityPool.sol";
import "../src/StructsForLPs.sol";

contract LiquidityPoolTest is DSTest, StructsForLPs {
    LiquidityPool liquidityPool;

    function setUp() public {
        liquidityPool = new LiquidityPool(
            address(0), 
            address(0), 
            500, // Example fee
            1000, // Example reserve0
            2000, // Example reserve1
            3000 // Example liquidity
        );
    }

    function testGetPoolState() public {
        Pool memory pool = liquidityPool.getPoolState();
        assertEq(pool.token0, address(0));
        assertEq(pool.token1, address(0));
        assertEq(pool.reserve0, 1000);
        assertEq(pool.reserve1, 2000);
    }
}
