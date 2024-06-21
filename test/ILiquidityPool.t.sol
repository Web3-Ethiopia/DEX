// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ILiquidityPool.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ILiquidityPoolTest is Test {
    ILiquidityPool public pool;
    MockERC20 public token0;
    MockERC20 public token1;
    address public owner;
    address public user;

    function setUp() public {
        owner = address(this);
        user = address(0x123);

        token0 = new MockERC20("Token 0", "T0");
        token1 = new MockERC20("Token 1", "T1");

        pool = new ILiquidityPool(address(token0), address(token1));
        pool.transferOwnership(owner);

        token0.mint(user, 1000 * 10**18);
        token1.mint(user, 1000 * 10**18);

        token0.approve(address(pool), 1000 * 10**18);
        token1.approve(address(pool), 1000 * 10**18);
    }

    function testInitializePool() public {
        pool.initializePool(
            79228162514264337593543950336, // Example sqrtPriceX96 value
            1000, // Example liquidity value
            1, // Example tick value
            0, // Example lowerTick value
            10 // Example upperTick value
        );

        (uint256 sqrtPriceX96, uint128 liquidity, uint256 tick, uint256 lowerTick, uint256 upperTick) = pool.pool();
        
        assertEq(sqrtPriceX96, 79228162514264337593543950336);
        assertEq(liquidity, 1000);
        assertEq(tick, 1);
        assertEq(lowerTick, 0);
        assertEq(upperTick, 10);
    }

    function testProvideLiquidity() public {
        pool.initializePool(
            79228162514264337593543950336, // Example sqrtPriceX96 value
            1000, // Example liquidity value
            1, // Example tick value
            0, // Example lowerTick value
            10 // Example upperTick value
        );

        pool.provideLiquidity(
            100 * 10**18, // Example amount0 value
            100 * 10**18, // Example amount1 value
            79228162514264337593543950336, // Example sqrtPriceX96 value
            500, // Example liquidity value
            0, // Example lowerTick value
            10 // Example upperTick value
        );
        
        (uint256 sqrtPriceX96, uint128 liquidity, uint256 tick, uint256 lowerTick, uint256 upperTick) = pool.pool();
        
        assertEq(sqrtPriceX96, 79228162514264337593543950336);
        assertEq(liquidity, 1500); // Initial 1000 + added 500
        // Assuming tick should remain as initialized or changed
        assertEq(lowerTick, 0);
        assertEq(upperTick, 10);
    }

    function testGetAmountsForLiquidity() public {
        uint256 amount0;
        uint256 amount1;

        (amount0, amount1) = pool.getAmountsForLiquidity(
            500, // Example liquidity value
            79228162514264337593543950336, // Example sqrtPriceX96 value
            0, // Example lowerTick value
            10 // Example upperTick value
        );
        
        uint256 expectedAmount0 = pool.calculateAmount0(500, 0, 10);
        uint256 expectedAmount1 = pool.calculateAmount1(500, 79228162514264337593543950336, 0);

        assertEq(amount0, expectedAmount0);
        assertEq(amount1, expectedAmount1);
    }
}
