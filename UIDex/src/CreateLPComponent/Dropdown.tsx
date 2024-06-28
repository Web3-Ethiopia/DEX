import React from 'react';

interface DropdownProps {
  options: string[];
  selectedOption: string;
  onChange: (option: string) => void;
}

const Dropdown: React.FC<DropdownProps> = ({ options, selectedOption, onChange }) => {
  return (
    <select 
      value={selectedOption} 
      onChange={(e) => onChange(e.target.value)} 
      className="p-2 border border-gray-600 bg-gray-800 text-white rounded"
    >
      {options.map((option) => (
        <option key={option} value={option}>
          {option}
        </option>
      ))}
    </select>
  );
};

export default Dropdown;
