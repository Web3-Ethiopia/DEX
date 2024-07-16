// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IQuotationFetch.sol";

interface ISwapRouter {

     struct SwapState {
        int256 amountSpecifiedRemaining;
        int256 amountCalculated;
        uint160 sqrtPriceX96;
        int24 tickOfCurrentPrice;
        uint128 protocolFee;
        uint128 liquidity;
    }

    struct SingleHopSwap {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOutMin;
        address to;
        uint256 deadline;
    }

    struct MultiHopSwap {
        address[] path;
        uint256 amountIn;
        uint256 amountOutMin;
        address to;
        uint256 deadline;
    }

    // Events
    event SingleHopSwapExecuted(
        address indexed user,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    event MultiHopSwapExecuted(
        address indexed user,
        address[] path,
        uint256 amountIn,
        uint256 amountOut
    );

    event SwapStateUpdated(
        address indexed user,
        uint256 amountIn,
        uint256 amountOut,
        address[] path,
        uint256 deadline,
        bool completed
    );

}
