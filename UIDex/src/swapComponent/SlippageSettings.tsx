import React from 'react';
import "./index.css"

interface SlippageSettingsProps {
  slippage: string;
  onSlippageChange: (slippage: string) => void;
  mevProtection: boolean;
  onMevProtectionChange: (mevProtection: boolean) => void;
}

const SlippageSettings: React.FC<SlippageSettingsProps> = ({
  slippage,
  onSlippageChange,
  mevProtection,
  onMevProtectionChange
}) => {
  return (
    <div className="slippage-settings">
      <label>
        Max Slippage:
        <select value={slippage} onChange={(e) => onSlippageChange(e.target.value)}>
          <option value="0.1%">0.1%</option>
          <option value="0.5%">0.5%</option>
          <option value="1%">1%</option>
        </select>
      </label>
      <label>
        <input
          type="checkbox"
          checked={mevProtection}
          onChange={(e) => onMevProtectionChange(e.target.checked)}
        />
        Add MEV Protection
      </label>
    </div>
  );
};

export default SlippageSettings;
