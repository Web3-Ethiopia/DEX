import React from 'react';
import "./index.css"

interface ConnectButtonProps {
  onClick: () => void;
}

const ConnectButton: React.FC<ConnectButtonProps> = ({ onClick }) => {
  return (
    <button className="connect-button" onClick={onClick}>
      Connect
    </button>
  );
};

export default ConnectButton;
