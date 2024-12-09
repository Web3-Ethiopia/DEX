// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import "../src/AllPoolManager.sol";
import "../src/LiquidityPool.sol";

contract AllPoolManagerTest is Test {
    AllPoolManager allPoolManager;
    LiquidityPool liquidityPool;
    address owner;

    function setUp() public {
        // Select an account to act as the owner for deploying contracts
        owner = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); // Example owner account

        // Deploy a new AllPoolManager contract for each test
        allPoolManager = new AllPoolManager();

        // Optionally, deploy a LiquidityPool contract if needed for certain tests
        // liquidityPool = new LiquidityPool(/* constructor args */);
    }


    function testCreatePool() public {
    // Define test inputs
    string memory name = "TestPool";
    address token1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
    address token2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC;
    uint24 fee = 3000; // Example fee
    uint256 lowPrice = 100; // Example low price
    uint256 highPrice = 200; // Example high price

    // Call the createPool function
    address poolAddress = allPoolManager.createPool(name, token1, token2, fee, lowPrice, highPrice);

    // Verify the pool was created successfully
    assertTrue(poolAddress != address(0), "Pool address should not be zero");
    // Further verification can be added here, such as checking the pool's existence in the mapping
}





}
