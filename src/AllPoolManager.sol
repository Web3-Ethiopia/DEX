// AllPoolManager.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/SafeERC20.sol";

contract AllPoolManager {
    using SafeERC20 for IERC20;

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
