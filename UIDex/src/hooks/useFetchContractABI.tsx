import { useEffect, useState } from 'react';

export function useFetchContractABI(contractName: string) {
  const [abi, setAbi] = useState<any | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);

  useEffect(() => {
    const fetchABI = async () => {
      setIsLoading(true);
      setError(null);
      try {
        const response = await import(`../abis/${contractName}.json`); 
        setAbi(response.abi);
      } catch (err) {
        setError('Failed to fetch ABI');
        console.error('Error fetching ABI:', err);
      } finally {
        setIsLoading(false);
      }
    };

    fetchABI();
  }, [contractName]);

  return { abi, error, isLoading };
}
