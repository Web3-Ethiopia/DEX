// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructsForLPs {
    struct Range {
        uint256 lowerBound;
        uint256 upperBound;
    }

    struct LiquidityPosition {
        address provider;
        uint256 amount0;
        uint256 amount1;
        Range range;
        uint256 liquidity;
    }

    struct PoolState {
        uint256 reserve0;
        uint256 reserve1;
        uint256 totalLiquidity;
    }
}
