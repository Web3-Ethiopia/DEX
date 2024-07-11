import React, { useEffect, useRef, useState } from "react";
import Dropdown from "./Dropdown";
import FeeTier from "./FeeTier";
import PriceRange from "./PriceRange";
import CurrentPriceDisplay from "./CurrentPriceDisplay";
import LiquidityChart from "./LiquidityChart";
import DepositAmount from "./DepositAmount";
import ConnectWalletButton from "./ConnectWalletButton";
import "./styles/LiquidityPool.css";
import gsap from "gsap";
import { useConnectWallet } from "../hooks/UseConnectWallet";

const LiquidityPool: React.FC = () => {
  const divRef = useRef<HTMLDivElement>(null);
  const { walletInfo, connectWallet, disconnectWallet, connectors } =
    useConnectWallet();

  const [selectedToken1, setSelectedToken1] = useState("ETH");
  const [selectedToken2, setSelectedToken2] = useState("DAI");
  const [feeTier, setFeeTier] = useState("0.30%");
  const [lowPrice, setLowPrice] = useState(1722.6644);
  const [highPrice, setHighPrice] = useState(5684.8938);
  const [ethAmount, setEthAmount] = useState(0);
  const [daiAmount, setDaiAmount] = useState(0);

  const handleTokenChange1 = (newToken: string) => {
    setSelectedToken1(newToken);
  };

  const handleTokenChange2 = (newToken: string) => {
    setSelectedToken2(newToken);
  };

  const handleEditFeeTier = () => {
    // Handle fee tier edit logic here
    console.log("Edit fee tier");
  };

  const handleLowPriceChange = (newLowPrice: number) => {
    setLowPrice(newLowPrice);
  };

  const handleHighPriceChange = (newHighPrice: number) => {
    setHighPrice(newHighPrice);
  };

  const handleEthAmountChange = (newAmount: number) => {
    setEthAmount(newAmount);
  };

  const handleDaiAmountChange = (newAmount: number) => {
    setDaiAmount(newAmount);
  };

  const handleConnectWallet = () => {
    console.log("button clicked");
    // Handle wallet connection
    if (connectors.length > 0) {
      connectWallet(connectors[0]);
    }
  };

  const handleDisconnectWallet = () => {
    disconnectWallet();
  };

  const chartData = {
    // Chart data goes here
  };

  useEffect(() => {
    if (divRef.current) {
      const colors = ["black", "yellow", "red", "green"];
      // const duration = 100;

      gsap.to(divRef.current, {
        duration: 30,
        backgroundPosition: "200% 0%",
        ease: "none",
        repeat: -1,
      });
    }
  }, []);

  return (
    <div
      className="w-[100%] h-[100%] py-[4vh] flex justify-center bg-gradient-to-r from-yellow-950 via-amber-600 to-yellow-950 bg-[length:300%_200%] bg-left"
      ref={divRef}
    >
      <div className="p-10 flex items-center justify-center flex-col bg-background-dark bg-opacity-90 shadow-orange-300 shadow-inner rounded-md">
        <div className="flex gap-2">
          <Dropdown
            options={["ETH", "DAI"]}
            selectedOption={selectedToken1}
            onChange={handleTokenChange1}
          />
          <Dropdown
            options={["ETH", "DAI"]}
            selectedOption={selectedToken2}
            onChange={handleTokenChange2}
          />
        </div>
        <FeeTier selectedFeeTier={feeTier} onEdit={handleEditFeeTier} />
        <PriceRange
          lowPrice={lowPrice}
          highPrice={highPrice}
          onLowPriceChange={handleLowPriceChange}
          onHighPriceChange={handleHighPriceChange}
        />
        <CurrentPriceDisplay currentPrice={3446.41} pair1="ETH" pair2="DAI" />
        <LiquidityChart data={chartData} />
        <div className="flex gap-2 p-4">
          <DepositAmount
            token="ETH"
            amount={ethAmount}
            onAmountChange={handleEthAmountChange}
          />
          <DepositAmount
            token="DAI"
            amount={daiAmount}
            onAmountChange={handleDaiAmountChange}
          />
        </div>
        <div className="flex gap-2">
          {!walletInfo.isConnected ? (
            <ConnectWalletButton onClick={handleConnectWallet} />
          ) : (
            <>
              <button
                onClick={handleDisconnectWallet}
                className="mt-5 px-4 py-2 bg-yellow-600 text-white rounded cursor-pointer hover:bg-yellow-900"
              >
                Disconnect Wallet
              </button>
              <div className="text-white text-center w-full mt-10">
                {walletInfo.address}
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
};

export default LiquidityPool;
