// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {LiquidityPool} from "../src/liquidityPoolSwapFunction.sol";
import {MockERC20} from "../src/MockERC20.sol"; // Import the custom MockERC20

contract SwapFunctionTest is Test {
    LiquidityPool liquidityPool;
    MockERC20 token0;
    MockERC20 token1;
    MockERC20 lpRewardsToken; // Add this line
    address initialOwner = address(0x789);
    address user1 = address(0x123);
    address user2 = address(0x456);

    // Constants for test
    string constant POOL_NAME = "TestPool";
    uint24 constant FEE = 3000; // Example fee value
    uint160 constant INITIAL_SQRT_PRICE_X96 = 79228162514264337593543950336; // sqrt(2^96)
    uint128 constant INITIAL_LIQUIDITY = 1000;
    uint256 constant LOW_PRICE = 100;
    uint256 HIGH_PRICE = 200;
    uint256 constant TOKEN_AMOUNT = 1000 * 10**18;
    uint256 constant SWAP_AMOUNT_IN = 500 * 10**18;
    uint256 constant SWAP_AMOUNT_OUT_MIN = 1;

      // Constants for test
    string constant POOL_NAME = "TestPool";
    uint24 constant FEE = 3000; // Example fee value
    uint256 constant LOW_PRICE = 100;
    uint256 constant HIGH_PRICE = 200;
    uint256 constant TOKEN_AMOUNT = 1000 * 10**18;

    function setUp() external {
        // Deploy mock tokens
        token0 = new MockERC20("Token0", "TK0");
        token1 = new MockERC20("Token1", "TK1");
        lpRewardsToken = new MockERC20("LPReward", "LPR");

        // Deploy the LiquidityPool contract
        vm.prank(initialOwner);
        liquidityPool = new LiquidityPool(
            POOL_NAME,
            address(token0),
            address(token1),
            FEE,
            LOW_PRICE,
            HIGH_PRICE
        );

        // Mint tokens to users
        token0.mint(user1, TOKEN_AMOUNT);
        token1.mint(user2, TOKEN_AMOUNT);

        // Mint tokens to the liquidity pool
        token0.mint(address(liquidityPool), TOKEN_AMOUNT);
        token1.mint(address(liquidityPool), TOKEN_AMOUNT);

        // Approve the pool to spend tokens on behalf of users
        vm.prank(user1);
        token0.approve(address(liquidityPool), type(uint256).max);

        vm.prank(user2);
        token1.approve(address(liquidityPool), type(uint256).max);
    }

    function testCreatePool() public {
        // Verify the pool was created correctly
        liquidityPool.createPool(POOL_NAME, INITIAL_SQRT_PRICE_X96, INITIAL_LIQUIDITY, LOW_PRICE, HIGH_PRICE);
        LiquidityPool.Pool memory pool = liquidityPool.getPool(POOL_NAME);

        assertEq(pool.sqrtPriceX96, INITIAL_SQRT_PRICE_X96);
        assertEq(pool.liquidity, INITIAL_LIQUIDITY);
        assertEq(pool.lowPrice, LOW_PRICE);
        assertEq(pool.highPrice, HIGH_PRICE);
        assertEq(pool.creator, initialOwner);
        assertEq(pool.poolName, POOL_NAME);
    }

  


    function testMintFunction() public {
        // Prank as user1 to mint tokens to user2
        vm.prank(user1);
        token0.mint(user2, SWAP_AMOUNT_IN);
        // Check token balances after minting
        uint256 token0BalanceUser2 = token0.balanceOf(user2);

        assertEq(token0BalanceUser2, SWAP_AMOUNT_IN); // user2 should have 500 TK0
    }

    function testSwapFunction() public {
        // Ensure user1 has sufficient token0 balance for swap
        uint256 initialToken0BalanceUser1 = token0.balanceOf(user1);
        if (initialToken0BalanceUser1 < SWAP_AMOUNT_IN) {
            uint256 mintAmount = SWAP_AMOUNT_IN - initialToken0BalanceUser1;
            token0.mint(user1, mintAmount);
        }

        // Prank as user1 to perform a swap
        address to = user1;

        uint256 initialToken1BalanceUser1 = token1.balanceOf(user1);

        vm.prank(user1);
        liquidityPool.swap(POOL_NAME, address(token0), address(token1), SWAP_AMOUNT_IN, SWAP_AMOUNT_OUT_MIN, to);

        // Check token balances after swap
        uint256 finalToken0BalanceUser1 = token0.balanceOf(user1);
        uint256 finalToken1BalanceUser1 = token1.balanceOf(user1);

        assertEq(finalToken0BalanceUser1, initialToken0BalanceUser1 - SWAP_AMOUNT_IN); // Expect 500 TK0 to be swapped out
        assertTrue(finalToken1BalanceUser1 > initialToken1BalanceUser1); // Adjust based on the amountOut calculated
    }

    // Additional Tests

    function testMultiHopSwapPossible() public {
        bool isPossible = liquidityPool.isMultiHopSwapPossible(POOL_NAME);
        // Assuming the mock implementation always returns false
        assertTrue(!isPossible);
    }

    function testMintLPRewards() public {
        // Setup and perform a swap as in testSwapFunction

        uint256 initialToken0BalanceUser1 = token0.balanceOf(user1);
        if (initialToken0BalanceUser1 < SWAP_AMOUNT_IN) {
            uint256 mintAmount = SWAP_AMOUNT_IN - initialToken0BalanceUser1;
            token0.mint(user1, mintAmount);
        }

        address to = user1;
        vm.prank(user1);
        liquidityPool.swap(POOL_NAME, address(token0), address(token1), SWAP_AMOUNT_IN, SWAP_AMOUNT_OUT_MIN, to);

        // Verify LP rewards minted
        uint256 lpRewardsBalance = lpRewardsToken.balanceOf(user1);
        assertTrue(lpRewardsBalance > 0);
    }

    function testFuzzSwap(uint256 amountIn) public {
        vm.assume(amountIn > 0 && amountIn < TOKEN_AMOUNT);

        address to = user1;
        vm.prank(user1);
        liquidityPool.swap(POOL_NAME, address(token0), address(token1), amountIn, SWAP_AMOUNT_OUT_MIN, to);

        uint256 finalToken0BalanceUser1 = token0.balanceOf(user1);
        uint256 finalToken1BalanceUser1 = token1.balanceOf(user1);

        assertTrue(finalToken1BalanceUser1 > 0);
        assertTrue(finalToken0BalanceUser1 <= TOKEN_AMOUNT - amountIn);
    }

    function testSwapOutOfRange() public {
        vm.prank(initialOwner);
        liquidityPool.createPool(POOL_NAME, INITIAL_SQRT_PRICE_X96, INITIAL_LIQUIDITY, LOW_PRICE, HIGH_PRICE);

        vm.prank(user1);
        vm.expectRevert("Swap price out of range");
        liquidityPool.swap(POOL_NAME, address(token0), address(token1), TOKEN_AMOUNT, SWAP_AMOUNT_OUT_MIN, user1);
    }

    function testLiquidityRemovalRewards() public {
        vm.prank(user1);
        liquidityPool.addLiquidity(POOL_NAME, 500 * 10**18, 500 * 10**18, LOW_PRICE, HIGH_PRICE, user1);

        vm.prank(user1);
        liquidityPool.removeLiquidity(POOL_NAME, 500, user1);

        uint256 lpRewardsBalance = lpRewardsToken.balanceOf(user1);
        assertTrue(lpRewardsBalance > 0);
    }
}
