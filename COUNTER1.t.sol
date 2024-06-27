// SPDX-License-Identifier: GPL3.0
pragma solidity 0.7.3;
  function testSwapRequest() public {
        (uint256 amountOut, uint256 updatedLiquidity)=ETHPool1.calculateLiquidity(uint256 amountIn);
        uint256 currentPrice=ETHUSDTPool1.tickPrice();
        amountIn-ETHUSDTPool1.swapState.amountCompleted==ETHUSDTPool1.swapCache.amountRemaining;

        (address[] poolsInvolved)=Poolmanager.swapRouter(address tokenIn,address tokenOut)
        (uint256 amountOut, uint256 updatedLiquidity)=poolsInvolved[0].calculateLiquidity(tokenAmountIn);
        (uint256 amountOut, uint256 updatedLiquidity)=poolsInvolved[1].calculateLiquidity(tokenAmountIn);
        (uint256 amountOut, uint256 updatedLiquidity)=poolsInvolved[2].calculateLiquidity(tokenAmountIn);
    }