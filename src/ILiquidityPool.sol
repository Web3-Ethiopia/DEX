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
