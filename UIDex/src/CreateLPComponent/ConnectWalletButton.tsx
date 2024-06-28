import React from 'react';

interface ConnectWalletButtonProps {
  onClick: () => void;
}

const ConnectWalletButton: React.FC<ConnectWalletButtonProps> = ({ onClick }) => {
  return (
    <button 
      onClick={onClick} 
      className="mt-5 px-4 py-2 bg-yellow-600 text-white rounded cursor-pointer hover:bg-yellow-900"
    >
      Connect wallet
    </button>
  );
};

export default ConnectWalletButton;
