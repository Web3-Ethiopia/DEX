
import { useState, useEffect } from 'react';
import { useAccount, useConnect, Connector, useDisconnect } from 'wagmi';

interface WalletInfo {
  isConnected: boolean;
  address: `0x${string}` | null | undefined;
  ensName?: string | null;
  ensAvatar?: string | null;
}


export function useConnectWallet() {
  const { connect, connectors } = useConnect();
  const { address, isConnected } = useAccount();
  const { disconnect } = useDisconnect();
  const [walletInfo, setWalletInfo] = useState<WalletInfo>({ isConnected: false, address: null });

  useEffect(() => {
    if (isConnected) {
      
      setWalletInfo({ isConnected, address });
    } else {
      setWalletInfo({ isConnected: false, address: null });
    }
  }, [isConnected, address]);

  const connectWallet = async (connector: Connector) => {
    console.log('Connecting with:', connector.name);
    try {
      await connect({ connector });
    } catch (error) {
      console.error("Failed to connect wallet", error);
    }
  };

  const disconnectWallet = () => {
    console.log('Disconnecting wallet');
    disconnect();
  };

  return { walletInfo, connectWallet, disconnectWallet, connectors };
}
