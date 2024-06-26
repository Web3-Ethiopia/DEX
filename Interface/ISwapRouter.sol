// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQuotationFetch {
    // Define the functions from IQuotationFetch contract here
    // ...
}

interface ISwapRouter {
    // Event emitted when a swap is executed
    event SwapExecuted(address indexed sender, uint256 amountIn, uint256 amountOut);

    // Event emitted when a swap fails
    event SwapFailed(address indexed sender, string reason);

    // Function to get the average cost of a swap given the available route
    function getAverageSwapCost(address[] memory route) external view returns (uint256);

    // Function to execute a swap
    function executeSwap(address[] memory route, uint256 amountIn) external returns (uint256);

    // Add other required functions here

    // ...
}