import React from 'react';

interface CurrentPriceDisplayProps {
  currentPrice: number;
  pair1: string;
  pair2:string;
}

const CurrentPriceDisplay: React.FC<CurrentPriceDisplayProps> = ({ currentPrice, pair1, pair2 }) => {
  return (
    <div className="mt-2 font-bold text-white">
      Current price: {currentPrice} {pair1+ " per " + pair2}
    </div>
  );
};

export default CurrentPriceDisplay;
