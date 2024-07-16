// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract IQoutationFeatch {
  

    struct LiquidityPool {
        uint256 reserve0;
        uint256 reserve1;
        uint256 lowerBound;
        uint256 upperBound;
        mapping(address => uint256) providerAmounts;
    }

    mapping(bytes32 => LiquidityPool) public liquidityPools;
    mapping(address => AggregatorV3Interface) public priceFeeds;

    event MultiHopQuote(address[] transactionOrder, uint256 gasLimit, uint256 estimatedGasCost);
    event SwapRoute(address pair1, address pair2, address[] route);

    // Method to get a price quote from the liquidity pool and adjust to USDC decimals (6 decimals)
    function getPriceQuote(address token) public view returns (uint256) {
        require(priceFeeds[token] != AggregatorV3Interface(address(0)), "Price feed not available for this token");
        
        (,int256 price,,,) = priceFeeds[token].latestRoundData();
        require(price > 0, "Invalid price from price feed");

        // Chainlink prices typically have 8 decimals, we need to convert it to 6 decimals for USDC
        uint256 adjustedPrice = uint256(price).div(10**2); // Adjusting 8 decimals to 6 decimals

        return adjustedPrice;
    }

    // Validator method to fetch relevant info from Chainlink PriceFeeds and validate the quote
    function validateQuote(address token, uint256 quotedPrice, uint256 toleranceBps) public view returns (bool) {
        uint256 chainlinkPrice = getPriceQuote(token);
        uint256 lowerBound = chainlinkPrice.mul(uint256(10000).sub(toleranceBps)).div(10000);
        uint256 upperBound = chainlinkPrice.mul(uint256(10000).add(toleranceBps)).div(10000);
        require(quotedPrice >= lowerBound && quotedPrice <= upperBound, "Quoted price is out of acceptable range");
        return true;
    }

    // Helper method to check for the existence of a liquidity pool
    function liquidityPoolExists(bytes32 poolId) public view returns (bool) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return pool.reserve0 > 0 || pool.reserve1 > 0;
    }

    // Function to view the possible range for a quote
    function getPriceRange(bytes32 poolId) public view returns (uint256 lowerBound, uint256 upperBound) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return (pool.lowerBound, pool.upperBound);
    }

    // Function to get the details of a pool provider
    function getProviderDetails(bytes32 poolId, address provider) public view returns (uint256 amountProvided) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return pool.providerAmounts[provider];
    }

    // Function to fetch the latest price from Chainlink PriceFeeds
    function getChainlinkPrice(address aggregator) public view returns (int256 price, uint8 decimals) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggregator);
        (, price, , , ) = priceFeed.latestRoundData();
        decimals = priceFeed.decimals();
    }

    // Method to get a multi-hop quote
    function GetMultiHopQuote(address[] memory transactionOrder, uint256 gasLimit) public  returns (uint256) {
        require(transactionOrder.length >= 2, "Transaction order must have at least two tokens");

        
        uint256 estimatedGasCost = gasLimit * tx.gasprice;

        emit MultiHopQuote(transactionOrder, gasLimit, estimatedGasCost);

        return estimatedGasCost;
    }

    // Method to get the best swap route between two token pairs
    function GetSwapRoute(address pair1, address pair2) public  returns (address[] memory) {
        address[] memory route = new address[](2);
        route[0] = pair1;
        route[1] = pair2;

        emit SwapRoute(pair1, pair2, route);

        return route;
    }
}
