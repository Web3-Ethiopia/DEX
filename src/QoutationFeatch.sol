// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import "./IQoutationFeatch.sol";

contract QuotationFetch is IQuotationFetch {
    mapping(bytes32 => LiquidityPool) public liquidityPools;
    mapping(address => AggregatorV3Interface) public priceFeeds;

    function getPriceQuote(address token) public view override returns (uint256) {
        require(priceFeeds[token] != AggregatorV3Interface(address(0)), "Price feed not available for this token");

        (,int256 price,,,) = priceFeeds[token].latestRoundData();
        require(price > 0, "Invalid price from price feed");
        
        // Chainlink prices typically have 8 decimals, we need to convert it to 6 decimals for USDC
        uint256 adjustedPrice = uint256(price) / 10**2; // Adjusting 8 decimals to 6 decimals
        return adjustedPrice;
    }

    function validateQuote(address token, uint256 quotedPrice, uint256 toleranceBps) public view override returns (bool) {
        uint256 chainlinkPrice = getPriceQuote(token);
        uint256 lowerBound = chainlinkPrice * (10000 - toleranceBps) / 10000;
        uint256 upperBound = chainlinkPrice * (10000 + toleranceBps) / 10000;
        
        require(quotedPrice >= lowerBound && quotedPrice <= upperBound, "Quoted price is out of acceptable range");
        return true;
    }

    function liquidityPoolExists(bytes32 poolId) public view override returns (bool) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return pool.reserve0 > 0 || pool.reserve1 > 0;
    }

    function getPriceRange(bytes32 poolId) public view override returns (uint256 lowerBound, uint256 upperBound) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return (pool.lowerBound, pool.upperBound);
    }

    function getProviderDetails(bytes32 poolId, address provider) public view override returns (uint256 amountProvided) {
        LiquidityPool storage pool = liquidityPools[poolId];
        return pool.providerAmounts[provider];
    }

    function getChainlinkPrice(address aggregator) public view override returns (int256 price, uint8 decimals) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(aggregator);
        (, price, , , ) = priceFeed.latestRoundData();
        decimals = priceFeed.decimals();
    }

    function getMultiHopQuote(address[] memory transactionOrder, uint256 gasLimit) public override returns (uint256) {
        require(transactionOrder.length >= 2, "Transaction order must have at least two tokens");

        uint256 estimatedGasCost = gasLimit * tx.gasprice;
        emit MultiHopQuote(transactionOrder, gasLimit, estimatedGasCost);
        return estimatedGasCost;
    }

    function getSwapRoute(address pair1, address pair2) public override returns (address[] memory) {
        address[] memory route = new address[](2);
        route[0] = pair1;
        route[1] = pair2;
        emit SwapRoute(pair1, pair2, route);
        return route;
    }
}