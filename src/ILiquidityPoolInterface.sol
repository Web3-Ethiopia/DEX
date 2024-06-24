// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./structsforLPs.sol";
import "./iquotationfetch.sol";

interface ILiquidityPool {

    struct Pool {
        address token0;
        address token1;
        uint24 fee;
        uint256 reserve0;
        uint256 reserve1;
        uint256 liquidity;
        PoolPriceRange priceRange;
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

    function createPool(
        address token0,
        address token1,
        uint24 fee,
        PoolPriceRange memory priceRange
    ) external returns (address poolAddress);

    function addLiquidity(
        address pool,
        uint256 amount0,
        uint256 amount1,
        uint256 rangeLow,
        uint256 rangeHigh,
        address provider
    ) external returns (uint256 liquidity);

    function removeLiquidity(
        address pool,
        uint256 liquidity,
        address provider
    ) external returns (uint256 amount0, uint256 amount1);

    function getPoolState(address pool) external view returns (Pool memory);

    function getReserves(address pool) external view returns (uint256 reserve0, uint256 reserve1);

    function getPrice(address pool) external view returns (uint256 price);

    function getPoolDetails(address pool) external view returns (Pool memory);

    function getLiquidityProviders(address pool) external view returns (address[] memory);

    function liquidityScan(address[] memory pools) external view returns (uint256[] memory);

    event PoolCreated(address indexed pool, address indexed token0, address indexed token1, uint24 fee);
    event LiquidityAdded(address indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event LiquidityRemoved(address indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event PoolStateUpdated(address indexed pool, uint256 reserve0, uint256 reserve1, uint256 liquidity);
}
