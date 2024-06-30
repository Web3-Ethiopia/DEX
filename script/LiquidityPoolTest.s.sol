// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../src/LiquidityPool.sol";
import "../src/StructsForLPs.sol";
import "forge-std/Script.sol";

contract LiquidityPoolTestScript is Script, StructsForLPs {
    function run() external {
        vm.startBroadcast();

        LiquidityPool liquidityPool = new LiquidityPool(
            address(0x123), // Example token0 address
            address(0x456), // Example token1 address
            500,            // Example fee
            1000,           // Example reserve0
            2000,           // Example reserve1
            3000            // Example liquidity
        );

        // Example usage of liquidityPool
        (uint256 reserve0, uint256 reserve1) = liquidityPool.getReserves();
        console.log("Reserve0:", reserve0);
        console.log("Reserve1:", reserve1);

        vm.stopBroadcast();
    }
}
