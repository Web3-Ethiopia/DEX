// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../interfaces/IAllPoolManager.sol";
import "./LiquidityPool.sol";

contract AllPoolManager is IAllPoolManager {
    mapping(string => LiquidityPool) liquidityPoolMap;

    function createPool(
        string name,
        address token1,
        address token2,
        uint256 token1Amount,
        uint256 token2Amount,
        uint256 lowPrice,
        uint256 highPrice
    ) external returns (LiquidityPool liquidityPool) {
        require(highPrice > lowPrice, "high range must exceed low range");
        require(
            requiredLiquidity(token1Amount, getAvgPrice(lowPrice, highPrice), lowPrice, highPrice) <= token2Amount,
            "Invalid Liquidity"
        );
        LiquidityPool liquidityPool =
            LiquidityPool(name, token1, token2, token1Amount, token2Amount, lowPrice, highPrice);
    }

    function getAvgPrice(uint256 lowPrice, uint256 highPrice) public returns (uint256) {
        return (highPrice - lowPrice) / 2;
    }

    function requiredLiquidity(uint256 token1Amount, uint256 price, uint256 lowPrice, uint256 highPrice)
        public
        view
        returns (uint256)
    {
        liquidity_x =
            (token1Amount * (price ** (1 / 2)) * (highPrice ** (1 / 2))) / ((highPrice ** (1 / 2)) - (price ** (1 / 2)));
        liquidity_y = liquidity_x * ((price ** (1 / 2)) - (lowPrice ** (1 / 2)));
        return liquidity_y;
    }
}
