import React from 'react';
import "./index.css"

interface TokenInputProps {
  value: string;
  token: string;
  onValueChange: (value: string) => void;
  onTokenChange: (token: string) => void;
}

const TokenInput: React.FC<TokenInputProps> = ({
  value,
  token,
  onValueChange,
  onTokenChange
}) => {
  return (
    <div className="token-input">
      <input
        type="text"
        value={value}
        onChange={(e) => onValueChange(e.target.value)}
      />
      <select value={token} onChange={(e) => onTokenChange(e.target.value)}>
        <option value="ETH">ETH</option>
        <option value="USDT">USDT</option>
        {/* Add more tokens as needed */}
      </select>
    </div>
  );
};

export default TokenInput;
