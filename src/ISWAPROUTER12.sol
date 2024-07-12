// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ISWAPROUTER12.sol";
import "truffle/console.sol";
contract ISwapRouter12Test {
    ISwapRouter12 public router;
    event SwapExactTokensForTokens(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] path,
        address indexed to,
        uint256 deadline
    );
    event SwapTokensForExactTokens(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountOut,
        uint256 amountInMax,
        address[] path,
        address indexed to,
        uint256 deadline
    );

    constructor(address _router) {
        router = ISwapRouter12(_router);
    }

    function testSwapExactTokensForTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address[] memory path,
        address to,
        uint256 deadline
    ) public {
        console.log("Starting testSwapExactTokensForTokens");
        router.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
        console.log("Completed testSwapExactTokensForTokens");

        emit SwapExactTokensForTokens(
            tokenIn,
            tokenOut,
            amountIn,
            amountOutMin,
            path,
            to,
            deadline
        );
    }

    function testSwapTokensForExactTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountOut,
        uint256 amountInMax,
        address[] memory path,
        address to,
        uint256 deadline
    ) public {
        console.log("Starting testSwapTokensForExactTokens");
        router.swapTokensForExactTokens(
            amountOut,
            amountInMax,
            path,
            to,
            deadline
        );
        console.log("Completed testSwapTokensForExactTokens");

        emit SwapTokensForExactTokens(
            tokenIn,
            tokenOut,
            amountOut,
            amountInMax,
            path,
            to,
            deadline
        );
    }
}