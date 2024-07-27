

import { useState, useEffect } from 'react';
import { useContractRead } from 'wagmi';
import { calculateSwapPrice } from '../utils/calculateSwapPrice';
import { LIQUIDITY_POOL_ABI, ALL_POOL_MANAGER_ABI, ALL_POOL_MANAGER_ADDRESS } from '../constants';

export function useSwapPriceCalculator(poolName, provider) {
  const [price, setPrice] = useState({ amount0: 0, amount1: 0 });
  const [error, setError] = useState(null);

  const { data: poolAddress } = useContractRead({
    abi: ALL_POOL_MANAGER_ABI,
    address: ALL_POOL_MANAGER_ADDRESS,
    functionName: 'liquidityPoolMap',
    args: [poolName],
  });

  const { data: reserves } = useContractRead({
    abi: LIQUIDITY_POOL_ABI,
    address: poolAddress,
    functionName: 'getReserves',
    args: [poolAddress],
  });

  const { data: poolDetails } = useContractRead({
    abi: LIQUIDITY_POOL_ABI,
    address: poolAddress,
    functionName: 'getPoolDetails',
    args: [poolAddress],
  });

  useEffect(() => {
    if (reserves && poolDetails) {
      const { liquidity } = poolDetails;
      const { reserve0: sqrtPCurrent, reserve1: sqrtPHigh } = reserves;
      const sqrtPLow = 0; 

      try {
        const { amount0, amount1 } = calculateSwapPrice(liquidity, sqrtPHigh, sqrtPCurrent, sqrtPLow, Math.pow(2, 96));
        setPrice({ amount0, amount1 });
      } catch (e) {
        setError('Error calculating swap price');
      }
    }
  }, [reserves, poolDetails]);

  return { price, error };
}
