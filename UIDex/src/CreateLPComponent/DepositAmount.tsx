import React from 'react';

interface DepositAmountProps {
  token: string;
  amount: number;
  onAmountChange: (amount: number) => void;
}

const DepositAmount: React.FC<DepositAmountProps> = ({ token, amount, onAmountChange }) => {
  return (
    <div className="flex items-center mt-2 text-gray-400">
      <label>
        {token}:
        <input 
          type="number" 
          value={amount} 
          onChange={(e) => onAmountChange(parseFloat(e.target.value))} 
          className="ml-2 p-1 border border-gray-600 bg-gray-800 text-white rounded"
        />
      </label>
    </div>
  );
};

export default DepositAmount;
