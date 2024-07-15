// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Interfaces/ISwapRouter.sol";
import "./Interfaces/IQuotationFetch.sol";

contract SwapRouter is ISwapRouter {
    IQuotationFetch public quotationFetch;

    mapping(address => SwapState) public swapStates;

    constructor(address _quotationFetch) {
        quotationFetch = IQuotationFetch(_quotationFetch);
    }

    function executeSingleHopSwap(SingleHopSwap calldata swap) external override returns (uint256 amountOut) {
        require(block.timestamp <= swap.deadline, "Swap: Deadline passed");

        uint256 price = quotationFetch.getValidatedPriceQuote(swap.tokenIn, swap.tokenOut);
        require(price > 0, "Swap: Invalid price");

        // Calculate amount out
        amountOut = swap.amountIn * price / 1e6; 
        require(amountOut >= swap.amountOutMin, "Swap: Insufficient output amount");

        // Transfer tokens (Assume transferFrom and transfer functions are implemented for simplicity)
        require(IERC20(swap.tokenIn).transferFrom(msg.sender, address(this), swap.amountIn), "Swap: Transfer failed");
        require(IERC20(swap.tokenOut).transfer(swap.to, amountOut), "Swap: Transfer failed");

        // Create path array
        address[] memory path = new address[](2);
        path[0] = swap.tokenIn;
        path[1] = swap.tokenOut;

        // Emit event
        emit SingleHopSwapExecuted(msg.sender, swap.tokenIn, swap.tokenOut, swap.amountIn, amountOut);

        // Update swap state
        swapStates[msg.sender] = SwapState(msg.sender, swap.amountIn, amountOut, path, swap.deadline, true);

        emit SwapStateUpdated(msg.sender, swap.amountIn, amountOut, path, swap.deadline, true);
    }

    // Function to execute multi hop swap
    function executeMultiHopSwap(MultiHopSwap calldata swap) external override returns (uint256 amountOut) {
        // Ensure the deadline has not passed
        require(block.timestamp <= swap.deadline, "Swap: Deadline passed");

        uint256 amountIn = swap.amountIn;
        for (uint256 i = 0; i < swap.path.length - 1; i++) {
            uint256 price = quotationFetch.getValidatedPriceQuote(swap.path[i], swap.path[i + 1]);
            require(price > 0, "Swap: Invalid price");

            // Calculate amount out for each hop
            amountOut = amountIn * price / 1e6; // Assuming USDC has 6 decimal

            // Transfer tokens for each hop (Assume transferFrom and transfer functions are implemented for simplicity)
            require(IERC20(swap.path[i]).transferFrom(msg.sender, address(this), amountIn), "Swap: Transfer failed");
            require(IERC20(swap.path[i + 1]).transfer(swap.to, amountOut), "Swap: Transfer failed");

            amountIn = amountOut;
        }

        require(amountOut >= swap.amountOutMin, "Swap: Insufficient output amount");

        // Emit event
        emit MultiHopSwapExecuted(msg.sender, swap.path, swap.amountIn, amountOut);

        // Update swap state
        swapStates[msg.sender] = SwapState(msg.sender, swap.amountIn, amountOut, swap.path, swap.deadline, true);

        emit SwapStateUpdated(msg.sender, swap.amountIn, amountOut, swap.path, swap.deadline, true);
    }

    // Function to get average cost of a swap given the available route
    function getAvgCostOfSwap(address[] calldata path, uint256 amountIn) external view override returns (uint256 avgCost) {
        uint256 totalCost = 0;

        for (uint256 i = 0; i < path.length - 1; i++) {
            uint256 price = quotationFetch.getValidatedPriceQuote(path[i], path[i + 1]);
            require(price > 0, "Swap: Invalid price");

            totalCost += amountIn * price / 1e6;
        }

        avgCost = totalCost / (path.length - 1);
    }

    // Function to start a swap and update the state
    function startSwap(
        address user,
        uint256 amountIn,
        uint256 amountOut,
        address[] calldata path,
        uint256 deadline
    ) external override {
        // Update swap state
        swapStates[user] = SwapState(user, amountIn, amountOut, path, deadline, false);

        emit SwapStateUpdated(user, amountIn, amountOut, path, deadline, false);
    }

    // Function to compare swap state
    function swapState(address user) external view override returns (SwapState memory) {
        return swapStates[user];
    }

    // Function to get the correct price of all pairs involved in swap using IQuotationFetch
    function getPriceOfPairs(address[] calldata path) external view override returns (uint256[] memory prices) {
        prices = new uint256[](path.length - 1);

        for (uint256 i = 0; i < path.length - 1; i++) {
            prices[i] = quotationFetch.getValidatedPriceQuote(path[i], path[i + 1]);
            require(prices[i] > 0, "Swap: Invalid price");
        }
    }

    // Function to get multi-hop quote considering a multi-dimensional array for trades
    function getMultiHopQuote(address[] memory transactionOrder, uint256 gasLimit) external view override returns (uint256 quote) {
        quote = quotationFetch.getMultiHopQuote(transactionOrder, gasLimit);
    }

    // Function to get swap route between two pairs
    function getSwapRoute(address pair1, address pair2) external view override returns (address[] memory route) {
        route = quotationFetch.getSwapRoute(pair1, pair2);
    }
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
