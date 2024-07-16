pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "forge-std/interfaces/IERC20.sol";
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
        
        // Retrieve the pool address and contract
        address poolAddress = allPoolManager.liquidityPoolMap(poolName);
        LiquidityPool pool = LiquidityPool(poolAddress);

        // Assert values for respective pool contract balances
        (uint256 poolBalance0, uint256 poolBalance1) = pool.getReserves(poolName);
        assertEq(poolBalance0, amount0, "Incorrect pool balance0");
        assertEq(poolBalance1, amount1, "Incorrect pool balance1");
    }

    function testTryAddLiquidity() public {
        try allPoolManager.addLiquidity(poolName, amount0, amount1, lowPrice, highPrice, msg.sender) {
            // Do something if successful
        } catch {
            // Handle error
        }
    }

    function testRemoveLiquidity() public {
        // Add sufficient liquidity to the pool
        allPoolManager.addLiquidity(poolName, amount0, amount1, lowPrice, highPrice, msg.sender);

        // Retrieve the pool address and contract
        address poolAddress = allPoolManager.liquidityPoolMap(poolName);
        LiquidityPool pool = LiquidityPool(poolAddress);

        // Retrieve pool reserves before removal
        (uint256 poolBalance0Before, uint256 poolBalance1Before) = pool.getReserves(poolName);

        // Attempt to remove a portion of the liquidity
        uint256 liquidityAmountToRemove = liquidityAmount / 2;

        // Now, attempt to remove the liquidity
        (uint256 removedAmount0, uint256 removedAmount1) = allPoolManager.removeLiquidity(poolName, liquidityAmountToRemove, msg.sender);

        // Retrieve pool reserves after removal
        (uint256 poolBalance0After, uint256 poolBalance1After) = pool.getReserves(poolName);

        // Assert equals amount of balance of the user for both pairs post removal of liquidity
        assertEq(removedAmount0, amount0 / 2, "Incorrect amount0 removed");
        assertEq(removedAmount1, amount1 / 2, "Incorrect amount1 removed");

        // Check user balance
        IERC20 token0Contract = IERC20(token0);
        IERC20 token1Contract = IERC20(token1);
        uint256 userBalance0 = token0Contract.balanceOf(msg.sender);
        uint256 userBalance1 = token1Contract.balanceOf(msg.sender);
        assertEq(userBalance0, amount0 / 2, "Incorrect user balance0");
        assertEq(userBalance1, amount1 / 2, "Incorrect user balance1");

        // Assert values for respective pool contract balances after removal
        assertEq(poolBalance0After, poolBalance0Before - removedAmount0, "Incorrect pool balance0 after removal");
        assertEq(poolBalance1After, poolBalance1Before - removedAmount1, "Incorrect pool balance1 after removal");
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
