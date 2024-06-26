import React from 'react';
import "./index.css"

interface EstimatedOutputProps {
  output: string;
}

const EstimatedOutput: React.FC<EstimatedOutputProps> = ({ output }) => {
  return (
    <div className="estimated-output">
      Est. Output: {output}
    </div>
  );
};

export default EstimatedOutput;
