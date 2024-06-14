// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.5.11;
import './ISwapRouter.sol';
interface ISwapRouter {
    function exactInput(
        ISwapRouter.ExactInputParams calldata ,params
    ) external returns (uint256 amountOut);

    function exactOutput(
        ISwapRouter.ExactOutputParams calldata ,params
    ) external returns (uint256 amountInRequired);

    function exactInputSingle(
        ISwapRouter.ExactInputSingleParams calldata ,params
    ) external returns (uint256 amountOut);

    function exactOutputSingle(
        ISwapRouter.ExactOutputSingleParams calldata ,params
    ) external returns (uint256 amountInRequired);
}
contract SimpleSwap {
    ISwapRouter public immutable swapRouter;

    constructor(ISwapRouter _swapRouter) {
        swapRouter = _swapRouter;
    }

    function swapTokens(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) public {
        ISwapRouter.ExactInputParams memory params = ISwapRouter.ExactInputParams(
            tokenIn,
            tokenOut,
            amountIn,
            3000
        );

        uint256 amountOut = swapRouter.exactInput(params);
    }
}
