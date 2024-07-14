// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {LiquidityPool} from "../src/liquidityPoolSwapFunction.sol"; 
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ILiquidityPool} from "../src/LiquidityPool (1).sol";

// Mock ERC20 Token for testing
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }
}

interface IAllPoolManager {
    function fetchTokenReserves(string memory poolName) external view returns (uint256, uint256);
    function isMultiHopSwapPossible(string memory poolName) external view returns (bool);
}

contract SwapFunctionTest is Test {
    LiquidityPool liquidityPool;
    MockERC20 token0;
    MockERC20 token1;
    ILiquidityPool iliquidityPool;
    address initialOwner = address(0x789);
    address user1 = address(0x123);
    address user2 = address(0x456);

    // Constants for test
    string constant POOL_NAME = "TestPool";
    uint160 constant INITIAL_SQRT_PRICE_X96 = 79228162514264337593543950336; // sqrt(2^96)
    uint128 constant INITIAL_LIQUIDITY = 1000;
    uint256 constant LOW_PRICE = 100;
    uint256 constant HIGH_PRICE = 200;
    uint256 constant TOKEN_AMOUNT = 1000 * 10**18;
    uint256 constant SWAP_AMOUNT_IN = 500 * 10**18;
    uint256 constant SWAP_AMOUNT_OUT_MIN = 1;

    constructor() {}

    function setUp() external {
        // Deploy mock tokens
        token0 = new MockERC20("Token0", "TK0");
        token1 = new MockERC20("Token1", "TK1");

        liquidityPool = new LiquidityPool();

        // Deploy the LiquidityPool contract
        vm.prank(initialOwner);
        liquidityPool = new LiquidityPool(address(token0), address(token1), initialOwner);

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
        // Prank as the owner to create a pool
        vm.prank(initialOwner);
        liquidityPool.createPool(POOL_NAME, INITIAL_SQRT_PRICE_X96, INITIAL_LIQUIDITY, LOW_PRICE, HIGH_PRICE);

        // Verify the pool was created correctly
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
        // Prank as the owner to create a pool
        vm.prank(initialOwner);
        liquidityPool.createPool(POOL_NAME, INITIAL_SQRT_PRICE_X96, INITIAL_LIQUIDITY, LOW_PRICE, HIGH_PRICE);

        // Ensure user1 has sufficient token0 balance for swap
        uint256 initialToken0BalanceUser1 = token0.balanceOf(user1);
        // console.log("Initial token0 balance of user1:", initialToken0BalanceUser1);
        if (initialToken0BalanceUser1 < SWAP_AMOUNT_IN) {
            uint256 mintAmount = SWAP_AMOUNT_IN - initialToken0BalanceUser1;
            token0.mint(user1, mintAmount);
            console.log("Minted additional token0 to user1:", mintAmount);
        }

        // Check token balances after minting
        uint256 updatedToken0BalanceUser1 = token0.balanceOf(user1);
        // console.log("Updated token0 balance of user1:", updatedToken0BalanceUser1);

        // Prank as user1 to perform a swap
        address to = user1;

        uint256 initialToken1BalanceUser1 = token1.balanceOf(user1);

        vm.prank(user1);
        liquidityPool.swap(POOL_NAME, address(token0), address(token1), SWAP_AMOUNT_IN, SWAP_AMOUNT_OUT_MIN, to);

        // Check token balances after swap
        uint256 finalToken0BalanceUser1 = token0.balanceOf(user1);
        uint256 finalToken1BalanceUser1 = token1.balanceOf(user1);

        // Debugging statements to check values
        // console.log("Initial token0BalanceUser1:", initialToken0BalanceUser1);
        // console.log("Initial token1BalanceUser1:", initialToken1BalanceUser1);
        // console.log("Final token0BalanceUser1:", finalToken0BalanceUser1);
        // console.log("Final token1BalanceUser1:", finalToken1BalanceUser1);

        // Adjust these assertions based on the expected outcome of the swap
        assertEq(finalToken0BalanceUser1, initialToken0BalanceUser1 - SWAP_AMOUNT_IN); // Expect 500 TK0 to be swapped out
        assertTrue(finalToken1BalanceUser1 > initialToken1BalanceUser1); // Adjust based on the amountOut calculated
    }
}
