import React from 'react';
import "./index.css"

interface TransactionDetailsProps {
  rate: string;
  minimumReceived: string;
  priceImpact: string;
  gasRefund: string;
}

const TransactionDetails: React.FC<TransactionDetailsProps> = ({
  rate,
  minimumReceived,
  priceImpact,
  gasRefund
}) => {
  return (
    <div className="transaction-details">
      <div>Rate: {rate}</div>
      <div>Minimum Received: {minimumReceived}</div>
      <div>Price Impact: {priceImpact}</div>
      <div>Gas Refund: {gasRefund}</div>
    </div>
  );
};

export default TransactionDetails;
