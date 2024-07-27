import { useContractWrite } from 'wagmi';
import { ALL_POOL_MANAGER_ABI, ALL_POOL_MANAGER_ADDRESS } from '../constants';

export function useAddLiquidity() {
  const { write, data, error, isLoading, isSuccess } = useContractWrite({
    address: ALL_POOL_MANAGER_ADDRESS,
    abi: ALL_POOL_MANAGER_ABI,
    functionName: 'addLiquidity',
  });

  const addLiquidity = (name, amount0, amount1, rangeLow, rangeHigh) => {
    write({ args: [name, amount0, amount1, rangeLow, rangeHigh] });
  };

  return { addLiquidity, data, error, isLoading, isSuccess };
}
