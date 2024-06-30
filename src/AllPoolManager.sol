// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./LiquidityPool.sol";
import "./QoutationFeatch.sol";

import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract AllPoolManager {
    mapping(address => address) public poolToQuoteFetcher; // Pool address -> Quotation fetcher contract address
    mapping(address => PoolInfo) public poolInfo; // Pool address -> Pool information

    struct PoolInfo {
        address tokenA;
        address tokenB;
        uint256 totalLiquidity; // Total amount of liquidity deposited in the pool
    }

    function createPool(address tokenA, address tokenB) public {
        // Create a new liquidity pool for the given tokens
        address poolAddress = address(new LiquidityPool(tokenA, tokenB));

        // Associate the pool with a quotation fetcher contract
        poolToQuoteFetcher[poolAddress] = address(new QoutationFeatch(getOracleAddress(tokenA, tokenB)));

        // Store pool information
        poolInfo[poolAddress] = PoolInfo({tokenA: tokenA, tokenB: tokenB, totalLiquidity: 0});
    }

    function getPoolPrice(address poolAddress) public view returns (uint256) {
        address quoteFetcher = poolToQuoteFetcher[poolAddress];
        require(quoteFetcher != address(0), "Pool has no associated quotation fetcher");

        IQoutationFeatch quotationFeatch = IQoutationFeatch(quoteFetcher);

        return quotationFeatch.getPrice(LiquidityPool(poolAddress));
    }

    function addLiquidity(address poolAddress, uint256 amountA, uint256 amountB) public {
        LiquidityPool pool = LiquidityPool(poolAddress);

        // Transfer tokens from user to pool
        IERC20(pool.token0()).transferFrom(msg.sender, poolAddress, amountA);
        IERC20(pool.token1()).transferFrom(msg.sender, poolAddress, amountB);

        // Update pool information
        poolInfo[poolAddress].totalLiquidity += pool.addLiquidity(amountA, amountB, msg.sender);
    }

    function removeLiquidity(address poolAddress, uint256 liquidity) public {
        LiquidityPool pool = LiquidityPool(poolAddress);

        // Calculate amounts of tokens to be returned
        (uint256 amountA, uint256 amountB) = pool.removeLiquidity(liquidity, msg.sender);

        // Transfer tokens from pool to user
        IERC20(pool.token0()).transfer(msg.sender, amountA);
        IERC20(pool.token1()).transfer(msg.sender, amountB);

        // Update pool information
        poolInfo[poolAddress].totalLiquidity -= liquidity;
    }

    function getOracleAddress(address tokenA, address tokenB) internal pure returns (address) {
        // Placeholder for oracle address retrieval logic
        return address(0);
    }
}