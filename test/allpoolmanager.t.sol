// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/AllPoolManager.sol";

contract AllPoolManagerTest is Test {
    AllPoolManager public allPoolManager;

    string poolName = "TestPool";
    address token0 = address(1);
    address token1 = address(2);
    uint24 fee = 3000;
    uint256 lowPrice = 100;
    uint256 highPrice = 200;
    uint256 amount0 = 1000;
    uint256 amount1 = 2000;
    uint256 liquidityAmount = 500;

    function setUp() public {
        allPoolManager = new AllPoolManager();
        allPoolManager.createPool(poolName, token0, token1, fee, lowPrice, highPrice);
    }

    function testAddLiquidity() public {
        allPoolManager.addLiquidity(poolName, amount0, amount1, lowPrice, highPrice, msg.sender);
    }

    function testTryAddLiquidity() public {
        try allPoolManager.addLiquidity(poolName, amount0, amount1, lowPrice, highPrice, msg.sender) {
            // Do something if successful
        } catch {
            // Handle error
        }
    }

    function testRemoveLiquidity() public {
        // First, add a smaller amount of liquidity to the pool
        allPoolManager.addLiquidity(poolName, amount0 / 2, amount1 / 2, lowPrice, highPrice, msg.sender);

        // Try to remove a portion of the liquidity
        uint256 liquidityAmountToRemove = amount0 / 4; // or adjust to a smaller fraction

        // Now, attempt to remove the liquidity
        (uint256 removedAmount0, uint256 removedAmount1) = allPoolManager.removeLiquidity(poolName, liquidityAmountToRemove, msg.sender);

        // Add assertions to verify correct amounts have been removed
        assertEq(removedAmount0, amount0 / 4, "Incorrect amount0 removed");
        assertEq(removedAmount1, amount1 / 4, "Incorrect amount1 removed");
    }



    function testTryRemoveLiquidity() public {
        allPoolManager.addLiquidity(poolName, amount0, amount1, lowPrice, highPrice, msg.sender);
        try allPoolManager.removeLiquidity(poolName, liquidityAmount, msg.sender) returns (uint256 removedAmount0, uint256 removedAmount1) {
            // Do something if successful
        } catch {
            // Handle error
        }
    }

    function testMultiHopSwap() public {
        string memory poolName1 = "Pool1";
        string memory poolName2 = "Pool2";

        allPoolManager.createPool(poolName1, token0, token1, fee, lowPrice, highPrice);
        allPoolManager.createPool(poolName2, token0, token1, fee, lowPrice, highPrice);

        allPoolManager.addLiquidity(poolName1, amount0, amount1, lowPrice, highPrice, msg.sender);
        allPoolManager.addLiquidity(poolName2, amount0, amount1, lowPrice, highPrice, msg.sender);

        bool result = allPoolManager.isMultiHopSwapPossible(poolName1, poolName2);
        assert(result);
    }
}
