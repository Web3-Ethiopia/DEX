// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructsForLPs {
     struct PoolPriceRange {
        uint256 minLowerBound;
        uint256 maxUpperBound;
    }
    struct Pool {
        address token0;
        address token1;
        uint24 fee;
        uint256 reserve0;
        uint256 reserve1;
        uint256 liquidity;
        PoolPriceRange priceRange;
    }

   

    struct PoolPortion {
        address poolAddress;
        uint256 rangeLow;
        uint256 rangeHigh;
        uint256 liquidity;
    }
}