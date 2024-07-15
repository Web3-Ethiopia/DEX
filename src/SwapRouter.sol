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

    
}

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
