// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


interface IQuotationFetch {
    struct LiquidityPool {
        uint256 reserve0;
        uint256 reserve1;
        uint256 lowerBound;
        uint256 upperBound;
        mapping(address => uint256) providerAmounts;
    }

    event MultiHopQuote(address[] transactionOrder, uint256 gasLimit, uint256 estimatedGasCost);
    event SwapRoute(address pair1, address pair2, address[] route);

    function getPriceQuote(address token) external view returns (uint256);
    function validateQuote(address token, uint256 quotedPrice, uint256 toleranceBps) external view returns (bool);
    function liquidityPoolExists(bytes32 poolId) external view returns (bool);
    function getPriceRange(bytes32 poolId) external view returns (uint256 lowerBound, uint256 upperBound);
    function getProviderDetails(bytes32 poolId, address provider) external view returns (uint256 amountProvided);
    function getChainlinkPrice(address aggregator) external view returns (int256 price, uint8 decimals);
    function getMultiHopQuote(address[] memory transactionOrder, uint256 gasLimit) external returns (uint256);
    function getSwapRoute(address pair1, address pair2) external returns (address[] memory);
}