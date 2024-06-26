import React, { useState } from 'react';
import Header from './Header';
import TokenInput from './TokenInput';
import EstimatedOutput from './EstOut';
import SlippageSettings from './SlippageSettings';
import TransactionDetails from './TransactionDetails';
import ConnectButton from './ConnectButton';
import "./index.css"

const Swap: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'Swap' | 'Limit Order'>('Swap');
  const [inputValue, setInputValue] = useState('');
  const [inputToken, setInputToken] = useState('ETH');
  const [outputValue, setOutputValue] = useState('');
  const [slippage, setSlippage] = useState('0.5%');
  const [mevProtection, setMevProtection] = useState(false);
  const [rate, setRate] = useState('1 ETH = 3,380.965 USDT');
  const [minimumReceived, setMinimumReceived] = useState('3,364 USDT');
  const [priceImpact, setPriceImpact] = useState('< 0.01%');
  const [gasRefund, setGasRefund] = useState('--% Refund');

  const handleSwap = () => {
    // Handle the swap logic here
  };

  return (
    <div className="swap-component  shadow-inner shadow-yellow-500">
      <Header activeTab={activeTab} onTabChange={setActiveTab} />
      <TokenInput
        value={inputValue}
        token={inputToken}
        onValueChange={setInputValue}
        onTokenChange={setInputToken}
      />
      <EstimatedOutput output={outputValue} />
      <SlippageSettings
        slippage={slippage}
        onSlippageChange={setSlippage}
        mevProtection={mevProtection}
        onMevProtectionChange={setMevProtection}
      />
      <TransactionDetails
        rate={rate}
        minimumReceived={minimumReceived}
        priceImpact={priceImpact}
        gasRefund={gasRefund}
      />
      <ConnectButton onClick={handleSwap} />
    </div>
  );
};

export default Swap;
