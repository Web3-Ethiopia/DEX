import { useState, useEffect } from 'react';
import { useContractWrite, useTransaction } from 'wagmi';


interface DeployContractVariables {
  abi: any;
  bytecode: `0x${string}`;
  args?: any[];
}

interface DeployContractResult {
  data?: {
    contractAddress: string;
    transactionHash: string;
  };
  error?: string;
  isLoading: boolean;
  isSuccess: boolean;
  deployContract: (variables: DeployContractVariables) => void;
}

export function useDeployContract(): DeployContractResult {
  const [deployVariables, setDeployVariables] = useState<DeployContractVariables | null>(null);

  const { write, data: writeData, isLoading: writeLoading, error: writeError } = useContractWrite({
    abi: deployVariables?.abi,
    functionName: 'deploy',
    args: deployVariables?.args,
    bytecode: deployVariables?.bytecode,
  });

  const { data: txData, isLoading: txLoading, error: txError, isSuccess: txSuccess } = useTransaction({
    hash: writeData?.hash,
  });

  useEffect(() => {
    if (write) {
      write();
    }
  }, [write]);

  const deployContract = (variables: DeployContractVariables) => {
    setDeployVariables(variables);
  };

  return {
    data: txData ? {
      contractAddress: txData.contractAddress,
      transactionHash: txData.transactionHash,
    } : undefined,
    error: writeError?.message || txError?.message,
    isLoading: writeLoading || txLoading,
    isSucces
