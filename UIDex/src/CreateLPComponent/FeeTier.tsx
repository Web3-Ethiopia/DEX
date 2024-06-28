import React from 'react';

interface FeeTierProps {
  selectedFeeTier: string;
  onEdit: () => void;
}

const FeeTier: React.FC<FeeTierProps> = ({ selectedFeeTier, onEdit }) => {
  return (
    <div className="flex items-center mt-2">
      <span className="text-gray-400">{selectedFeeTier} fee tier</span>
      <button 
        onClick={onEdit} 
        className="ml-2 px-2 py-1 bg-yellow-700 text-white rounded hover:bg-yellow-900"
      >
        Edit
      </button>
    </div>
  );
};

export default FeeTier;
