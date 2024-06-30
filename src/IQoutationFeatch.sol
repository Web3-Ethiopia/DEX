// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./LiquidityPool.sol";

interface IQoutationFeatch {
    function getSwapOutput(LiquidityPool pool, address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256);
    function getPrice(LiquidityPool pool, string memory poolName) external view returns (uint256);
    function validateQuote(LiquidityPool pool, string memory poolName, uint256 quotedPrice) external view returns (bool);
}
