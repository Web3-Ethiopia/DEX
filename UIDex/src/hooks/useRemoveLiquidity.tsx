import { useWriteContract } from 'wagmi';
import { ALL_POOL_MANAGER_ABI, ALL_POOL_MANAGER_ADDRESS } from '../constants';

export function useRemoveLiquidity() {
  const { data, error, isSuccess, write } = useWriteContract({
    address: ALL_POOL_MANAGER_ADDRESS as `0x${string}`,
    abi: ALL_POOL_MANAGER_ABI,
    functionName: 'removeLiquidity',
  });

  const removeLiquidity = async (
    name: string,
    liquidityAmount: bigint
  ) => {
    try {
      await write?.({ args: [name, liquidityAmount] });
    } catch (err: unknown) {
      console.error('Error writing to contract:', err);
    }
  };

  return { removeLiquidity, data, error, isSuccess };
}
