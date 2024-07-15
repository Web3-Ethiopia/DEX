// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructsForLPs {

    
    struct TokenDetails {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
    }

    
    struct PoolPriceRange {
        uint256 min;
        uint256 max;
        uint64 pricePercentLimit;
    }

    
    struct LiquidityPool {
        uint256 totalLiquidity;
        uint256 totalFeesCollected;
        PoolPriceRange priceRange;
        TokenDetails tokenA;
        TokenDetails tokenB;
    }

    
    struct LiquidityProvider {
        address providerAddress;
        uint256 providedLiquidity;
        uint256 variableFees; 
    }
    
    mapping(address => LiquidityProvider) public liquidityProviders;

    LiquidityPool public liquidityPool;

    event LiquidityAdded(address indexed provider, uint256 amount);

    event FeesCollected(address indexed provider, uint256 amount);

}
