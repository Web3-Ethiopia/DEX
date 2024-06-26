import React from 'react';
import "./index.css"

interface HeaderProps {
  activeTab: 'Swap' | 'Limit Order';
  onTabChange: (tab: 'Swap' | 'Limit Order') => void;
}

const Header: React.FC<HeaderProps> = ({ activeTab, onTabChange }) => {
  return (
    <div className="header">
      <button
        className={activeTab === 'Swap' ? 'active' : ''}
        onClick={() => onTabChange('Swap')}
      >
        Swap
      </button>
      <button
        className={activeTab === 'Limit Order' ? 'active' : ''}
        onClick={() => onTabChange('Limit Order')}
      >
        Limit Order
      </button>
    </div>
  );
};

export default Header;
