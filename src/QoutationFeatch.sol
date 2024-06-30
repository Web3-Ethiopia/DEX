// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./IQoutationFeatch.sol";
import "./LiquidityPool.sol";
import "./StructsForLPs.sol";
import {AggregatorV3Interface} from "@chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract QoutationFeatch is IQoutationFeatch, StructsForLPs {
    uint256 private constant PRICE_SCALE = 1e18;
    uint256 private constant PRICE_TOLERANCE = 1e16;

    // Address of the Chainlink oracle contract for the desired price feed
    AggregatorV3Interface public priceFeedContract;

    // Flag to indicate if Chainlink oracle is being used for price fetching
    bool public useChainlinkPriceFeed;

    // Declare `currentDecimals` outside the constructor and initialize to 0
    uint256 public currentDecimals = 0;

    constructor(address _priceFeedAddress) {
        if (_priceFeedAddress != address(0)) {
            priceFeedContract = AggregatorV3Interface(_priceFeedAddress);
            currentDecimals = priceFeedContract.decimals(); // Initialize here
        }
        useChainlinkPriceFeed = _priceFeedAddress != address(0);
    }

    function getPrice(LiquidityPool pool, string memory poolName) public view override returns (uint256) {
        // Fetch price from Chainlink oracle if enabled, otherwise use pool's price
        if (useChainlinkPriceFeed) {
            (, int256 answer, , , ) = priceFeedContract.latestRoundData();
            require(answer >= 0, "Invalid Chainlink price feed data");
            return uint256(answer);
        } else {
            return pool.getPrice(poolName);
        }
    }

    function getSwapOutput(LiquidityPool pool, address tokenIn, address tokenOut, uint256 amountIn)
        external
        view
        override
        returns (uint256)
    {
        require(tokenIn != address(0) && tokenOut != address(0) && tokenIn != tokenOut, "Invalid tokens");

        (uint256 reserveIn, uint256 reserveOut) = pool.getReserves();

        uint256 reserve0;
        uint256 reserve1;

        if (tokenIn == pool.getToken0()) {
            reserve0 = reserveIn;
            reserve1 = reserveOut;
        } else {
            reserve0 = reserveOut;
            reserve1 = reserveIn;
        }

        uint256 amountOut = amountIn * reserve1 / (reserve0 + amountIn);
        return amountOut;
    }

    function validateQuote(LiquidityPool pool, string memory poolName, uint256 quotedPrice) external view override returns (bool) {
        uint256 currentPrice = getPrice(pool, poolName); // Call `getPrice` here
        return quotedPrice >= currentPrice - PRICE_TOLERANCE && quotedPrice <= currentPrice + PRICE_TOLERANCE;
    }
}
