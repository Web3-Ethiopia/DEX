// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/LiqidityPool.sol";

contract LiquidityAllTest is Test {
    LiquidityPool pool;

    function setUp() public {
        pool = new LiquidityPool(
            "TestPool",
            address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266),
            address(0x70997970C51812dc3A010C7d01b50e0d17dc79C8),
            3000,
            100,
            200
        );
    }

    function testGetReserves() public view {
        (uint256 reserve0, uint256 reserve1) = pool.getReserves("TestPool");
        assertEq(reserve0, 0);
        assertEq(reserve1, 0);
    }

    function testAddLiquidity() public {
        uint256 liquidity = pool.addLiquidity("TestPool", 1000, 2000, 100, 200, address(this));
        (uint256 reserve0, uint256 reserve1) = pool.getReserves("TestPool");
        emit log_named_uint("Reserve0 after adding liquidity", reserve0);
        emit log_named_uint("Reserve1 after adding liquidity", reserve1);
        emit log_named_uint("Liquidity added", liquidity);
        assertEq(reserve0, 1000);
        assertEq(reserve1, 2000);
        assertGt(liquidity, 0);
    }

    function testSwap() public {
        pool.addLiquidity("TestPool", 1000, 2000, 100, 200, address(this));
        (uint256 amountOut, uint256 feeRewards) = pool.changeReserveThroughSwap("TestPool", 100, true, address(this));
        emit log_named_uint("Amount out after swap", amountOut);
        emit log_named_uint("Fee rewards after swap", feeRewards);
        (uint256 reserve0, uint256 reserve1) = pool.getReserves("TestPool");
        emit log_named_uint("Reserve0 after swap", reserve0);
        emit log_named_uint("Reserve1 after swap", reserve1);
        assertGt(amountOut, 0);
        assertGt(feeRewards, 0);
    }

    function testMultiHopSwap() public {
        // Implement a test to check multi-hop swap feasibility
    }

    function testFuzzSwaps(uint256 amountIn, bool isToken0In) public {
        require(amountIn > 0, "Amount in must be greater than 0");

        pool.addLiquidity("TestPool", 1000, 2000, 100, 200, address(this));
        vm.assume(amountIn < 1000);

        for (uint256 i = 0; i < 300; i++) {
            pool.changeReserveThroughSwap("TestPool", amountIn, isToken0In, address(this));
        }
    }

    function testFuzzPriceCalculationAndSwap(uint256 amountIn, bool isToken0In) public {
        require(amountIn > 0, "Amount in must be greater than 0");

        pool.addLiquidity("TestPool", 1000, 2000, 100, 200, address(this));
        uint256 minPrice = 100;
        uint256 maxPrice = 200;

        vm.assume(amountIn < 1000);

        for (uint256 i = 0; i < 300; i++) {
            (uint256 amountOut, uint256 feeRewards) = pool.changeReserveThroughSwap("TestPool", amountIn, isToken0In, address(this));
            (uint256 reserve0, uint256 reserve1) = pool.getReserves("TestPool");
            assertTrue(reserve0 >= 0 && reserve1 >= 0, "Reserves should be non-negative");
            assertTrue(amountOut >= 0, "Amount out should be non-negative");
            assertTrue(feeRewards >= 0, "Fee rewards should be non-negative");
            uint256 currentPrice = (reserve0 * 10**18) / reserve1;
            assertTrue(currentPrice >= minPrice && currentPrice <= maxPrice, "Price should be within the range");
        }
    }

    function testLiquidityRemovalRewards() public {
        uint256 initialLiquidity = pool.addLiquidity("TestPool", 1000, 2000, 100, 200, address(this));
        uint256 totalFeeRewards;

        for (uint256 i = 0; i < 100; i++) {
            (uint256 amountOut, uint256 feeRewards) = pool.changeReserveThroughSwap("TestPool", 100, true, address(this));
            totalFeeRewards += feeRewards;
        }

        emit log_named_uint("Total fee rewards after multiple swaps", totalFeeRewards);

        (uint256 reserve0Before, uint256 reserve1Before) = pool.getReserves("TestPool");
        pool.removeLiquidity("TestPool", initialLiquidity, address(this));
        (uint256 reserve0After, uint256 reserve1After) = pool.getReserves("TestPool");

        uint256 amount0Removed = reserve0Before - reserve0After;
        uint256 amount1Removed = reserve1Before - reserve1After;

        emit log_named_uint("Amount0 removed", amount0Removed);
        emit log_named_uint("Amount1 removed", amount1Removed);
        assertGt(amount0Removed, 0);
        assertGt(amount1Removed, 0);
    }
}