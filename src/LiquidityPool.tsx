import React, { useEffect, useState, useRef } from 'react';
import Dropdown from './Dropdown';
import FeeTier from './FeeTier';
import PriceRange from './PriceRange';
import CurrentPriceDisplay from './CurrentPriceDisplay';
import LiquidityChart from './LiquidityChart';
import DepositAmount from './DepositAmount';
import ConnectWalletButton from './ConnectWalletButton';
import './styles/LiquidityPool.css';
import gsap from 'gsap';
import { ethers } from 'ethers';
import './abi.json'; // Update with your contract ABI

const LiquidityPool: React.FC = () => {
  const divRef = useRef<HTMLDivElement>(null);
  const [provider, setProvider] = useState<ethers.providers.JsonRpcProvider | null>(null);
  const [contract, setContract] = useState<ethers.Contract | null>(null);
  const [account, setAccount] = useState<string | null>(null);
  const [currentPrice, setCurrentPrice] = useState<number>(0);
  const [ethAmount, setEthAmount] = useState<number>(0);
  const [daiAmount, setDaiAmount] = useState<number>(0);

  const contractAddress = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

  const handleTokenChange = (newToken: string) => {
    // Handle token change
  };

  const handleEditFeeTier = () => {
    // Handle fee tier edit
  };

  const handleLowPriceChange = (newLowPrice: number) => {
    // Handle low price change
  };

  const handleHighPriceChange = (newHighPrice: number) => {
    // Handle high price change
  };

  const handleEthAmountChange = (newAmount: number) => {
    setEthAmount(newAmount);
  };

  const handleDaiAmountChange = (newAmount: number) => {
    setDaiAmount(newAmount);
  };

  const handleConnectWallet = async () => {
    if (window.ethereum) {
      try {
        const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
        setAccount(accounts[0]);
        const _provider = new ethers.providers.Web3Provider(window.ethereum);
        setProvider(_provider);
        const _contract = new ethers.Contract(contractAddress, abi, _provider.getSigner());
        setContract(_contract);
      } catch (error) {
        console.error('User denied account access');
      }
    } else {
      console.error('No web3 provider found');
    }
  };

  const fetchCurrentPrice = async (_contract: ethers.Contract) => {
    try {
      const price = await _contract.getAvgPrice(); // Replace with your contract method
      setCurrentPrice(Number(ethers.utils.formatUnits(price, 18)));
    } catch (error) {
      console.error("Error fetching current price:", error);
    }
  };

  const supplyLiquidity = async () => {
    if (!contract) return;
    try {
      const tx = await contract.supplyLiquidity({ value: ethers.utils.parseEther(ethAmount.toString()) });
      await tx.wait();
      console.log("Liquidity supplied");
    } catch (error) {
      console.error("Error supplying liquidity:", error);
    }
  };

  const chartData = {
    // Chart data goes here
  };

  useEffect(() => {
    if (divRef.current) {
      gsap.to(divRef.current, {
        duration: 30,
        backgroundPosition: "200% 0%",
        ease: "none",
        repeat: -1,
      });
    }
  }, []);

  useEffect(() => {
    if (contract) {
      fetchCurrentPrice(contract);
    }
  }, [contract]);

  return (
    <div className="w-[100%] h-[100%] py-[4vh] flex justify-center bg-gradient-to-r from-yellow-950 via-amber-600 to-yellow-950 bg-[length:300%_200%] bg-left" ref={divRef}>
      <div className="p-10 flex items-center justify-center flex-col bg-background-dark bg-opacity-90 shadow-orange-300 shadow-inner rounded-md">
        <div className="flex gap-2">
          <Dropdown options={["ETH", "DAI"]} selectedOption="ETH" onChange={handleTokenChange} />
          <Dropdown options={["ETH", "DAI"]} selectedOption="DAI" onChange={handleTokenChange} />
        </div>
        <FeeTier selectedFeeTier="0.30%" onEdit={handleEditFeeTier} />
        <PriceRange
          lowPrice={1722.6644}
          highPrice={5684.8938}
          onLowPriceChange={handleLowPriceChange}
          onHighPriceChange={handleHighPriceChange}
        />
        <CurrentPriceDisplay currentPrice={currentPrice} pair1='ETH' pair2='DAI' />
        <LiquidityChart data={chartData} />
        <div className="flex gap-2 p-4">
          <DepositAmount token="ETH" amount={ethAmount} onAmountChange={handleEthAmountChange} />
          <DepositAmount token="DAI" amount={daiAmount} onAmountChange={handleDaiAmountChange} />
        </div>
        <ConnectWalletButton onClick={handleConnectWallet} />
        {contract && (
          <button onClick={supplyLiquidity} className="mt-5 px-4 py-2 bg-yellow-600 text-white rounded cursor-pointer hover:bg-yellow-900">
            Supply Liquidity
          </button>
        )}
      </div>
    </div>
  );
};

export default LiquidityPool;
