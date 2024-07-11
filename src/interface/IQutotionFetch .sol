// SPDX-License-Identifier: MIT

pragema solidity ^0.8.24;

contract IQutotionFetch  {

//Method to get price quote from liquidity  pool 
    function getPriceQuote(address liquidityPool) external view returns (uint256);
// metod to view possible price for a quote
    function getPriceRange(address liquidityPool) external view returns (uint256 lowerBound, uint256 upperbound);
// Validator method to fetch and verify chainlink price feeds
    function getMultiHopQuote(address[] memory transactionOrder, uint256 gasLimit) external view returns (uint256);
// Metod to get multi-hop quote
    function getMultiHopQuote(address[] memory transactionOrder, uint256 gasLimit) external view returns (uint256);
 // metod to get swap route 
    function getSwaproute(address pair1, address pair2) external view returns (uint256);

}

