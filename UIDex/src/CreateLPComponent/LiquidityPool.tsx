import React, { useEffect, useRef } from "react";
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
    // Handle ETH amount change
  };

  const handleDaiAmountChange = (newAmount: number) => {
    // Handle DAI amount change
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
      className="w-[100%] h-[100%]  py-[4vh] flex justify-center bg-gradient-to-r from-yellow-950 via-amber-600 to-yellow-950  bg-[length:300%_200%] bg-left"
      ref={divRef}
    >
      <div className="p-10 flex items-center justify-center flex-col bg-background-dark bg-opacity-90 shadow-orange-300 shadow-inner rounded-md">
        <div className="flex gap-2">
          <Dropdown
            options={["ETH", "DAI"]}
            selectedOption="ETH"
            onChange={handleTokenChange}
          />
          <Dropdown
            options={["ETH", "DAI"]}
            selectedOption="DAI"
            onChange={handleTokenChange}
          />
        </div>
        <FeeTier selectedFeeTier="0.30%" onEdit={handleEditFeeTier} />
        <PriceRange
          lowPrice={1722.6644}
          highPrice={5684.8938}
          onLowPriceChange={handleLowPriceChange}
          onHighPriceChange={handleHighPriceChange}
        />
        <CurrentPriceDisplay currentPrice={3446.41} pair1="ETH" pair2="DAI" />
        <LiquidityChart data={chartData} />
        <div className="flex gap-2 p-4">
          <DepositAmount
            token="ETH"
            amount={0}
            onAmountChange={handleEthAmountChange}
          />
          <DepositAmount
            token="DAI"
            amount={0}
            onAmountChange={handleDaiAmountChange}
          />
        </div>
        {/* <ConnectWalletButton onClick={handleConnectWallet} /> */}

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
