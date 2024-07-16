import { useEffect, useState } from "react";

export function useContractABI(contractName: string) {
  const [abi, setAbi] = useState<any | null>(null);

  useEffect(() => {
    // Function to fetch ABI based on contract name
    const fetchABI = async () => {
      try {
        const response = await import(`../abis/${contractName}.json`);
        setAbi(response.abi);
      } catch (error) {
        console.error("Error fetching ABI:", error);
      }
    };

    fetchABI();
  }, [contractName]);

  return abi;
}
