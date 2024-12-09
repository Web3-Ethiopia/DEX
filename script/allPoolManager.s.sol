// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Script.sol";
import "../src/AllPoolManager.sol";

contract AllPoolManagerScript is Script {
    AllPoolManager allPoolManager;

    function setUp() public {}

    function run() public {
        // Replace with your actual private key or use environment variables to securely manage it
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        // Deploy AllPoolManager contract
        allPoolManager = new AllPoolManager();

        // Optionally execute additional setup or tests
        // For example, we can call the testCreatePool function
        testCreatePool();

        vm.stopBroadcast();
    }

    function testCreatePool() internal {
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
        require(poolAddress != address(0), "Pool address should not be zero");
        // Further verification can be added here, such as checking the pool's existence in the mapping
    }
}