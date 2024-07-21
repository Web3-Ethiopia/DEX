// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./ILiquidityPool.sol";
import "./LiqidityPool.sol";


contract AllPoolManager {
    mapping(string => address) public liquidityPoolMap;
    mapping(address => mapping(address => ILiquidityPool.Pool)) public miniPools;
    mapping(address => mapping(address => ILiquidityPool.PoolPortion)) public poolPortions;

    function addLiquidity(
        string memory name,
        uint256 amount0,
        uint256 amount1,
        uint256 rangeLow,
        uint256 rangeHigh
    ) external {
        require(liquidityPoolMap[name] != address(0), "Pool does not exist");
        require(rangeHigh > rangeLow, "High range must exceed low range");

        ILiquidityPool(liquidityPoolMap[name]).addLiquidity(
            liquidityPoolMap[name], amount0, amount1, rangeLow, rangeHigh, msg.sender
        );

        miniPools[liquidityPoolMap[name]][msg.sender] = ILiquidityPool(liquidityPoolMap[name]).getPoolDetails(liquidityPoolMap[name]);
        poolPortions[liquidityPoolMap[name]][msg.sender] = ILiquidityPool(liquidityPoolMap[name]).getProviderPoolDetails(msg.sender);
    }

    function createPool(
        string memory name,
        address token0,
        address token1,
        uint24 fee,
        uint256 lowPrice,
        uint256 highPrice
    ) external returns (address) {
        require(liquidityPoolMap[name] == address(0), "Pool already exists");
        require(highPrice > lowPrice, "High range must exceed low range");

        ILiquidityPool.PoolPriceRange memory priceRange = ILiquidityPool.PoolPriceRange({
            minLowerBound: lowPrice,
            maxUpperBound: highPrice
        });

        address liquidityPoolAddress = ILiquidityPool(address(new LiquidityPool(name, token0, token1, fee, lowPrice, highPrice))).createPool(
            token0, token1, fee, priceRange
        );

        liquidityPoolMap[name] = liquidityPoolAddress;
        return liquidityPoolAddress;
    }

    function removeLiquidity(
        string memory name,
        uint256 liquidityAmount
    ) external returns (uint256 amount0, uint256 amount1) {
        require(liquidityPoolMap[name] != address(0), "Pool does not exist");

        (amount0, amount1) = ILiquidityPool(liquidityPoolMap[name]).removeLiquidity(
            liquidityPoolMap[name], liquidityAmount, msg.sender
        );

        miniPools[liquidityPoolMap[name]][msg.sender] = ILiquidityPool(liquidityPoolMap[name]).getPoolDetails(liquidityPoolMap[name]);
        poolPortions[liquidityPoolMap[name]][msg.sender] = ILiquidityPool(liquidityPoolMap[name]).getProviderPoolDetails(msg.sender);

        return (amount0, amount1);
    }

    function getAvgPrice(uint256 lowPrice, uint256 highPrice) public pure returns (uint256) {
        return (highPrice + lowPrice) / 2;
    }

    function isMultiHopSwapPossible(string memory pair1, string memory pair2) public view returns (bool) {
        address pool1 = liquidityPoolMap[pair1];
        address pool2 = liquidityPoolMap[pair2];
        if (pool1 == address(0) || pool2 == address(0)) {
            return false;
        }

        (uint256 reserve1A, uint256 reserve1B) = ILiquidityPool(pool1).getReserves(pool1);
        (uint256 reserve2A, uint256 reserve2B) = ILiquidityPool(pool2).getReserves(pool2);

        return (reserve1A > 0 && reserve1B > 0 && reserve2A > 0 && reserve2B > 0);
    }

    function getProviderBasedOnPool(string memory name, address providerAddress)
        public
        view
        returns (ILiquidityPool.Pool memory)
    {
        return ILiquidityPool(liquidityPoolMap[name]).getPoolDetails(liquidityPoolMap[name]);
    }

    function fetchLiquidityTokenReserves(string memory name)
        public
        view
        returns (uint256 reserve0, uint256 reserve1)
    {
        return ILiquidityPool(liquidityPoolMap[name]).getReserves(liquidityPoolMap[name]);
    }

    function fetchLiquidityPoolAddress(string memory name)
        public
        view
        returns (address)
    {
        return liquidityPoolMap[name];
    }
}
