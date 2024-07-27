
export function calculateSwapPrice(liquidity, sqrtPHigh, sqrtPCurrent, sqrtPLow, Q96) {
    const amount0 = (liquidity * (sqrtPHigh - sqrtPCurrent) * Q96) / (sqrtPHigh * sqrtPCurrent);
    const amount1 = (liquidity * (sqrtPCurrent - sqrtPLow)) / Q96;
  
    return { amount0, amount1 };
  }
  