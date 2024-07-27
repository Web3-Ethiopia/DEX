import { useWriteContract } from 'wagmi';
import { ALL_POOL_MANAGER_ABI, ALL_POOL_MANAGER_ADDRESS } from '../constants';

export function useCreatePool() {
  const { data, error, isSuccess, write } = useWriteContract({
    address: ALL_POOL_MANAGER_ADDRESS as `0x${string}`,
    abi: ALL_POOL_MANAGER_ABI,
    functionName: 'createPool',
  });

  const createPool = async (
    name: string,
    token0: string,
    token1: string,
    fee: bigint,
    lowPrice: bigint,
    highPrice: bigint
  ) => {
    try {
      await write?.({ args: [name, token0, token1, fee, lowPrice, highPrice] });
    } catch (err: unknown) {
      console.error('Error writing to contract:', err);
    }
  };

  return { createPool, data, error, isSuccess };
}
