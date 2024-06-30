// SPDX-License-Identifier: MIT
// QoutationFeatch.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./IQoutationFeatch.sol"; // Import the interface

contract QoutationFeatch is IQoutationFeatch {
    using SafeMath for uint256;

    // Constant for scaling price calculations (1 USDC = 1e18 wei)
    uint256 private constant PRICE_SCALE = 1e18;

    // Tolerance for price validation (e.g., 1% = 1e16)
    uint256 private constant PRICE_TOLERANCE = 1e16;

    function getSwapOutput(LiquidityPool pool, address tokenIn, address tokenOut, uint256 amountIn) external view override returns (uint256) {
        // Ensure tokens are valid and not the same
        require(tokenIn != address(0) && tokenOut != address(0) && tokenIn != tokenOut, "Invalid tokens");

        // Get reserves for the token pair
        (uint256 reserveIn, uint256 reserveOut) = pool.getReserves(pool.getToken0(), pool.getToken1());
        uint256 reserve0;
        uint256 reserve1;

        // Identify which token is being provided (token0 or token1)
        if (tokenIn == pool.getToken0()) {
            reserve0 = reserveIn;
            reserve1 = reserveOut;
        } else {
            reserve0 = reserveOut;
            reserve1 = reserveIn;
        }

        // Simplified constant product formula for estimated output (assuming no fees)
        uint256 amountOut = amountIn.mul(reserve1) / (reserve0 + amountIn);

        return amountOut;
    }

    function getPrice(LiquidityPool pool) external view override returns (uint256) {
        // Get reserves for the token pair
        (uint256 reserve0, uint256 reserve1) = pool.getReserves(pool.getToken0(), pool.getToken1());

        // Avoid division by zero
        if (reserve0 == 0 || reserve1 == 0) {
            return 0;
        }

        // Price calculation based on constant product formula (scaled by PRICE_SCALE)
        uint256 price = reserve1.mul(PRICE_SCALE) / reserve0;

        return price;
    }

    function validateQuote(LiquidityPool pool, uint256 quotedPrice) external view override returns (bool) {
        // Get current pool price
        uint256 currentPrice = getPrice(pool);

        // Check if quoted price is within a certain tolerance of the current price
        return quotedPrice >= currentPrice.sub(PRICE_TOLERANCE) && quotedPrice <= currentPrice.add(PRICE_TOLERANCE);
    }
}