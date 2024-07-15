// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IQuotationFetch {
    struct LiquidityPool {
        address tokenA;
        address tokenB;
        uint256 reserveA;
        uint256 reserveB;
        uint256 totalSupply;
        uint256 lastUpdated;
    }

    event PriceQuoteFetched(address indexed tokenA, address indexed tokenB, uint256 price);

    event PoolProviderDetailsFetched(address indexed provider, address indexed tokenA, address indexed tokenB, uint256 amountProvided);

    function getPriceQuote(address tokenA, address tokenB) external view returns (uint256 price);

    function getValidatedPriceQuote(address tokenA, address tokenB) external view returns (uint256 price);

    function getPossibleRangeForQuote(address tokenA, address tokenB) external view returns (uint256 lowerBound, uint256 upperBound);

    function getPoolProviderDetails(address provider, address tokenA, address tokenB) external view returns (uint256 amountProvided, LiquidityPool memory pool);

    function validatePriceUsingChainlink(address tokenA, address tokenB) external view returns (bool valid);
    
    function checkQuotationsWithChainlink(address tokenA, address tokenB) external view returns (uint256 price);

    function getPriceFromLiquidityPool(address tokenA, address tokenB) external view returns (uint256 price);

    function getMultiHopQuote(address[] memory transactionOrder, uint256 gasLimit) external view returns (uint256 quote);

    function getSwapRoute(address pair1, address pair2) external view returns (address[] memory route);
}
