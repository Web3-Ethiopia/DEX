// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LiquidityPool.sol";

contract LiquidityPoolTest is Test {
    LiquidityPool public liquidityPool;
    address public token0 = address(0x1);
    address public token1 = address(0x2);
    uint24 public fee = 3000;
    uint256 public lowPrice = 1000;
    uint256 public highPrice = 2000;
    uint256 public constant Q96 = 2**96; // Define Q96 here

    function setUp() public {
        liquidityPool = new LiquidityPool(
            "TestPool",
            token0,
            token1,
            fee,
            lowPrice,
            highPrice
        );
    }

    function testInitialPoolState() public {
        LiquidityPool.Pool memory pool = liquidityPool.getPoolState("TestPool");
        assertEq(pool.token0, token0);
        assertEq(pool.token1, token1);
        assertEq(pool.fee, fee);
        assertEq(pool.reserve0, 0);
        assertEq(pool.reserve1, 0);
        assertEq(pool.liquidity, 0);
        assertEq(pool.priceRange.minLowerBound, lowPrice);
        assertEq(pool.priceRange.maxUpperBound, highPrice);
    }

    function testAddLiquidity() public {
        uint256 amount0 = 1000;
        uint256 amount1 = 2000;
        address provider = address(this);

        liquidityPool.addLiquidity("TestPool", amount0, amount1, provider);

        LiquidityPool.Pool memory pool = liquidityPool.getPoolState("TestPool");
        assertEq(pool.reserve0, amount0);
        assertEq(pool.reserve1, amount1);
        assertEq(pool.liquidity, amount0 + amount1); // Simplified liquidity calculation
    }

    function testRemoveLiquidity() public {
        uint256 amount0 = 1000;
        uint256 amount1 = 2000;
        address provider = address(this);

        uint256 liquidityAdded = liquidityPool.addLiquidity("TestPool", amount0, amount1, provider);

        (uint256 removeAmount0, uint256 removeAmount1) = liquidityPool.removeLiquidity("TestPool", liquidityAdded, provider);

        assertEq(removeAmount0, amount0);
        assertEq(removeAmount1, amount1);

        LiquidityPool.Pool memory pool = liquidityPool.getPoolState("TestPool");
        assertEq(pool.reserve0, 0);
        assertEq(pool.reserve1, 0);
        assertEq(pool.liquidity, 0);
    }

    function testGetReserves() public {
        uint256 amount0 = 1000;
        uint256 amount1 = 2000;
        address provider = address(this);

        liquidityPool.addLiquidity("TestPool", amount0, amount1, provider);

        (uint256 reserve0, uint256 reserve1) = liquidityPool.getReserves("TestPool");
        assertEq(reserve0, amount0);
        assertEq(reserve1, amount1);
    }

    function testGetPrice() public {
        uint256 amount0 = 1000;
        uint256 amount1 = 2000;
        address provider = address(this);

        liquidityPool.addLiquidity("TestPool", amount0, amount1, provider);

        uint256 price = liquidityPool.getPrice("TestPool");
        uint256 expectedPrice = (amount1 * Q96) / amount0; // Simplified price calculation

        assertEq(price, expectedPrice);
    }
}