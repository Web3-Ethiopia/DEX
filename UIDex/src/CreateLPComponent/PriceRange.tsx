import React from 'react';

interface PriceRangeProps {
  lowPrice: number;
  highPrice: number;
  onLowPriceChange: (price: number) => void;
  onHighPriceChange: (price: number) => void;
}

const PriceRange: React.FC<PriceRangeProps> = ({ lowPrice, highPrice, onLowPriceChange, onHighPriceChange }) => {
  return (
    <div className="flex flex-col mt-2">
      <label className="mb-2 text-gray-400">
        Low price:
        <input 
          type="number" 
          value={lowPrice} 
          onChange={(e) => onLowPriceChange(parseFloat(e.target.value))} 
          className="ml-2 p-1 border border-gray-600 bg-gray-800 text-white rounded"
        />
      </label>
      <label className="text-gray-400">
        High price:
        <input 
          type="number" 
          value={highPrice} 
          onChange={(e) => onHighPriceChange(parseFloat(e.target.value))} 
          className="ml-2 p-1 border border-gray-600 bg-gray-800 text-white rounded"
        />
      </label>
    </div>
  );
};

export default PriceRange;
