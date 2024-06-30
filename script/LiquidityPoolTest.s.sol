// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/LiquidityPool.sol";

contract LiquidityPoolDeploymentScript is Script {

    function run() external {
        // Fetch the deployer's private key from environment variables
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        // Start broadcasting transactions using the deployer's private key
        vm.startBroadcast(deployerPrivateKey);

        // Define the parameters for the LiquidityPool constructor
        string memory poolName = "TestPool";
        address token0 = address(0x1);
        address token1 = address(0x2);
        uint24 fee = 3000;
        uint256 lowPrice = 1000;
        uint256 highPrice = 2000;

        // Deploy the LiquidityPool contract
        LiquidityPool liquidityPool = new LiquidityPool(
            poolName,
            token0,
            token1,
            fee,
            lowPrice,
            highPrice
        );

        // Log the address of the deployed contract
        console.log("LiquidityPool deployed at:", address(liquidityPool));

        // Stop broadcasting transactions
        vm.stopBroadcast();
    }
}