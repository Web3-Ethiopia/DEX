// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./IQoutationFeatch.sol";
import "./LiquidityPool.sol";
import "./StructsForLPs.sol";

contract QoutationFeatch is IQoutationFeatch, StructsForLPs {
    uint256 private constant PRICE_SCALE = 1e18;
    uint256 private constant PRICE_TOLERANCE = 1e16;

    function getSwapOutput(LiquidityPool pool, address tokenIn, address tokenOut, uint256 amountIn) external view override returns (uint256) {
        require(tokenIn != address(0) && tokenOut != address(0) && tokenIn != tokenOut, "Invalid tokens");

        (uint256 reserveIn, uint256 reserveOut) = pool.getReserves();

        uint256 reserve0;
        uint256 reserve1;

        if (tokenIn == pool.getToken0()) {
            reserve0 = reserveIn;
            reserve1 = reserveOut;
        } else {
            reserve0 = reserveOut;
            reserve1 = reserveIn;
        }

        uint256 amountOut = amountIn * reserve1 / (reserve0 + amountIn);
        return amountOut;
    }

    function getPrice(LiquidityPool pool, string memory poolName) external view override returns (uint256) {
        uint256 currentPrice = pool.getPrice(poolName);
        return currentPrice;
    }

    function validateQuote(LiquidityPool pool, string memory poolName, uint256 quotedPrice) external view override returns (bool) {
        uint256 currentPrice = pool.getPrice(poolName);
        return quotedPrice >= currentPrice - PRICE_TOLERANCE && quotedPrice <= currentPrice + PRICE_TOLERANCE;
    }
}
