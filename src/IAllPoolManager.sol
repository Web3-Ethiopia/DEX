// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiquidityPool.sol";

interface IAllPoolManager {
    event PoolCreated(string indexed name, address indexed token1, address indexed token2, uint24 fee, uint256 lowPrice, uint256 highPrice);
    event LiquidityAdded(address indexed provider, string indexed poolName, uint256 amount1, uint256 amount2, uint256 lowPrice, uint256 highPrice);
    event SwapExecuted(address indexed pair1, address indexed pair2, address[] route);

    function createPool(
        string memory name,
        address token1,
        address token2,
        uint24 fee,
        uint256 lowPrice,
        uint256 highPrice
    ) external returns (LiquidityPool);

    function addLiquidity(
        string memory name,
        address token1,
        address token2,
        uint256 token1Amount,
        uint256 token2Amount,
        uint256 lowPrice,
        uint256 highPrice
    ) external returns (LiquidityPool);

    function getAvgPrice(uint256 lowPrice, uint256 highPrice) external view returns (uint256);
}