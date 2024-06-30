// SPDX-License-Identifier: MIT
// IQoutationFeatch.sol

pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";


interface IQoutationFeatch {

    /// @notice Fetches the estimated output amount for a swap on a specific pool.
    /// @param pool The liquidity pool struct or storage containing relevant data.
    /// @param tokenIn Address of the token being provided for the swap.
    /// @param tokenOut Address of the token desired as output.
    /// @param amountIn The amount of `tokenIn` to be provided for the swap.
    /// @return The estimated amount of `tokenOut` that would be received.
    function getSwapOutput(LiquidityPool pool, address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256);

    /// @notice Retrieves the current price for a token pair considering pool state.
    /// @param pool The liquidity pool struct or storage containing relevant data.
    /// @return The current price of the token pair in USDC decimals (scaled by 1e18).
    function getPrice(LiquidityPool pool) external view returns (uint256);

    /// @notice Verifies a fetched quotation against the current pool state.
    /// @param pool The liquidity pool struct or storage containing relevant data.
    /// @param quotedPrice The price obtained from external sources (optional).
    /// @return True if the quoted price is valid within a certain tolerance, false otherwise.
    ///         (Note: This might not be necessary if relying solely on pool state)
    function validateQuote(LiquidityPool pool, uint256 quotedPrice) external view returns (bool);
}
