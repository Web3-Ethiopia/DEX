import { useReadContract, useWriteContract } from 'wagmi';
import { LIQUIDITY_POOL_ABI, LIQUIDITY_POOL_ADDRESS } from '../constants';

interface UseConnectContractResult {
  read: (functionName: string, args?: any[]) => any;
  write: (functionName: string, args?: any[]) => any;
}

export function useConnectContract(): UseConnectContractResult {
  const read = (functionName: string, args: any[] = []) => {
    const result = useReadContract({
      abi: LIQUIDITY_POOL_ABI,
      address: LIQUIDITY_POOL_ADDRESS,
      functionName,
      args,
    });
    return result;
  };

  const write = (functionName: string, args: any[] = []) => {
    const result = useWriteContract({
      abi: LIQUIDITY_POOL_ABI,
      address: LIQUIDITY_POOL_ADDRESS,
      functionName,
      args,
    });
    return result;
  };

  return { read, write };
}
