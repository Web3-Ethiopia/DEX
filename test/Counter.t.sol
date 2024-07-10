// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.3;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function setUp() public {
        counter = new Counter();
        counter.setNumber(0);
    }

    function test_Increment() public {
        counter.increment();
        assertEq(counter.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.number(), x);
    }
}
function testSwapRequest() public {
        (uint256 amountOut, uint256 updatedLiquidity)=ETHPool1.calculateLiquidity(uint256 amountIn);
        uint256 currentPrice=ETHUSDTPool1.tickPrice();
        amountIn-ETHUSDTPool1.swapState.amountCompleted==ETHUSDTPool1.swapCache.amountRemaining;

        (address[] poolsInvolved)=Poolmanager.swapRouter(address tokenIn,address tokenOut)
        (uint256 amountOut, uint256 updatedLiquidity)=poolsInvolved[0].calculateLiquidity(tokenAmountIn);
        (uint256 amountOut, uint256 updatedLiquidity)=poolsInvolved[1].calculateLiquidity(tokenAmountIn);
        (uint256 amountOut, uint256 updatedLiquidity)=poolsInvolved[2].calculateLiquidity(tokenAmountIn);




    }