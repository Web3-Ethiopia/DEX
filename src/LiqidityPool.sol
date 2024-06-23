// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

contract LiquidityPool {

    struct Pool {
        address token0;
        address token1;
        uint24 fee;
        uint256 reserve0;
        uint256 reserve1;
        uint256 liquidity;
        uint256 priceRange;
    }
     struct SwapCache {
        // the protocol fee for the input token
        uint8 feeProtocol;
        // liquidity at the beginning of the swap
        uint128 liquidityStart;
        // the timestamp of the current block
        uint32 blockTimestamp;
        // the current value of the tick accumulator, computed only if we cross an initialized tick
        Bool isOutOfRange;
        // the current value of seconds per liquidity accumulator, computed only if we cross an initialized tick
        uint160 secondsPerLiquidityCumulativeX128;
        // whether we've computed and cached the above two accumulators
        bool computedLatestObservation;
    }

    // the top level state of the swap, the results of which are recorded in storage at the end
    struct SwapState {
        // the amount remaining to be swapped in/out of the input/output asset
        int256 amountSpecifiedRemaining;
        // the amount already swapped out/in of the output/input asset
        int256 amountCalculated;
        // current sqrt(price)
        uint160 sqrtPriceX96;
        // the tick associated with the current price
        int24 tickOfCurrentPrice;
        // the global fee growth of the input token

        uint128 protocolFee;
        // the current liquidity in range
        uint128 liquidity;
    }
    struct PoolPortion {
        address poolAdress;
        uint256 rangeLow;
        uint256 rangeHigh;
        uint256 liquidity;
    }

        mapping(string => Pool) public pools;
        mapping(address=>mapping(address=>PoolPortion)) public poolPortions;

        event LiquidityAdded(address indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
        event LiquidityRemoved(address indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
        event PoolStateUpdated(address indexed pool, uint256 reserve0, uint256 reserve1, uint256 liquidity);
       
  
  function addLiquidity(
        address poolAddress,
        uint256 amount0,
        uint256 amount1,
        uint256 rangeLow,
        uint256 rangeHigh,
        address provider
    ) external returns (uint256 liquidity) {
        Pool storage pool = pools[poolAddress];

        require(pool.token0 != address(0) && pool.token1 != address(0), "Pool does not exist");
        require(rangeLow < rangeHigh, "Invalid price range");
        require(pool.priceRange.minlowerBound <= rangeLow && pool.priceRange.maxUpperBound >= rangeHigh, "Out of bounds price range");

      
        pool.reserve0 += amount0;
        pool.reserve1 += amount1;

   
        liquidity = (amount0 + amount1) * (rangeHigh - rangeLow);

        pool.liquidity += liquidity;

        emit LiquidityAdded(poolAddress, provider, amount0, amount1, liquidity);

        return liquidity;
    }
 function removeLiquidity(
        address poolAddress,
        uint256 liquidity,
        address provider
    ) external {
        Pool storage pool = pools[poolAddress];

        require(pool.token0 != address(0) && pool.token1 != address(0), "Pool does not exist");
        require(liquidity <= pool.liquidity, "Insufficient liquidity");

        uint256 amount0 = (pool.reserve0 * liquidity) / pool.liquidity;
        uint256 amount1 = (pool.reserve1 * liquidity) / pool.liquidity;

        pool.reserve0 -= amount0;
        pool.reserve1 -= amount1;
        pool.liquidity -= liquidity;

        emit LiquidityRemoved(poolAddress, provider, amount0, amount1, liquidity);
    }



}