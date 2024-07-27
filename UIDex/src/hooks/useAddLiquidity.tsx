import { useWriteContract } from 'wagmi';
import { ALL_POOL_MANAGER_ABI, ALL_POOL_MANAGER_ADDRESS } from '../constants';

export function useAddLiquidity() {
  const { data, error, isSuccess, write } = useWriteContract({
    address: ALL_POOL_MANAGER_ADDRESS as `0x${string}`, 
    abi: ALL_POOL_MANAGER_ABI,
    functionName: 'addLiquidity',
  });

  const addLiquidity = async (
    name: string, 
    amount0: bigint, 
    amount1: bigint, 
    rangeLow: bigint, 
    rangeHigh: bigint
  ) => {
    try {
      await write?.({ args: [name, amount0, amount1, rangeLow, rangeHigh] });
    } catch (err: unknown) {
      console.error('Error writing to contract:', err);
    }
  };

  return { addLiquidity, data, error, isSuccess };
}
