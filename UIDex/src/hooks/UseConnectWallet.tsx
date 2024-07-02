import { useState, useEffect } from 'react';
import { ethers } from 'ethers';

const useConnectWallet = () => {
  const [provider, setProvider] = useState<ethers.providers.Web3Provider | null>(null);
  const [signer, setSigner] = useState<ethers.Signer | null>(null);
  const [address, setAddress] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const connectWallet = async () => {
    try {
      if (window.ethereum) {
        const ethProvider = new ethers.providers.Web3Provider(window.ethereum);
        await ethProvider.send("eth_requestAccounts", []);
        const signer = ethProvider.getSigner();
        const address = await signer.getAddress();

        setProvider(ethProvider);
        setSigner(signer);
        setAddress(address);
      } else {
        setError("No Ethereum provider found. Install MetaMask.");
      }
    } catch (err) {
      setError("Failed to connect wallet.");
    }
  };

  useEffect(() => {
    connectWallet();
  }, []);

  return { provider, signer, address, error, connectWallet };
};

export default useConnectWallet;
