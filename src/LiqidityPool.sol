// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./StructForLp.sol";

contract LiquidityPool is StructsForLPs {
    uint256 constant Q96 = 2**96;
    mapping(string => Pool) public pools;
    mapping(address => mapping(address => PoolPortion)) public poolPortions;

    event LiquidityAdded(string indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event LiquidityRemoved(string indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event PoolStateUpdated(address indexed pool, uint256 reserve0, uint256 reserve1, uint256 liquidity);
    event Swap(string indexed pool, address indexed user, uint256 amountTokenIn, uint256 amountTokenOut, uint256 feeRewards);

    constructor(
        string memory _poolName,
        address _token0,
        address _token1,
        uint24 _fee,
        uint256 _lowPrice,
        uint256 _highPrice
    ) {
        require(_token0 != address(0) && _token1 != address(0), "Invalid token address");
        require(_lowPrice < _highPrice, "Invalid price range");

        PoolPriceRange memory priceRange = PoolPriceRange({
            minLowerBound: _lowPrice,
            maxUpperBound: _highPrice
        });
        Pool memory newPool = Pool({
            token0: _token0,
            token1: _token1,
            fee: _fee,
            reserve0: 0,
            reserve1: 0,
            liquidity: 0,
            priceRange: priceRange
        });
        pools[_poolName] = newPool;
    }

    function getReserves(string memory poolName) public view returns (uint256 reserve0, uint256 reserve1) {
        Pool storage pool = pools[poolName];
        return (pool.reserve0, pool.reserve1);
    }

    function priceToSqrtPrice(uint256 price) public pure returns (uint160) {
        return uint160(sqrt(price * Q96));
    }

    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 z = (x + 1) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return z;
    }

    function liquidity0(uint256 amount, uint160 pa, uint160 pb) public pure returns (uint256) {
        require(pa != pb, "Price bounds must not be equal");
        if (pa > pb) {
            (pa, pb) = (pb, pa);
        }
        return (amount * uint256(pa) * uint256(pb) / Q96) / (uint256(pb) - uint256(pa));
    }

    function liquidity1(uint256 amount, uint160 pa, uint160 pb) public pure returns (uint256) {
        require(pa != pb, "Price bounds must not be equal");
        if (pa > pb) {
            (pa, pb) = (pb, pa);
        }
        return amount * Q96 / (uint256(pb) - uint256(pa));
    }

    function addLiquidity(
        string memory poolName,
        uint256 amount0,
        uint256 amount1,
        uint256 rangeLow,
        uint256 rangeHigh,
        address provider
    ) external returns (uint256 liquidity) {
        Pool storage pool = pools[poolName];
        require(pool.token0 != address(0) && pool.token1 != address(0), "Pool does not exist");
        require(rangeLow < rangeHigh, "Invalid price range");
        require(pool.priceRange.minLowerBound <= rangeLow && pool.priceRange.maxUpperBound >= rangeHigh, "Out of bounds price range");

        uint160 sqrtPriceLow = priceToSqrtPrice(rangeLow);
        uint160 sqrtPriceHigh = priceToSqrtPrice(rangeHigh);
        uint160 sqrtPriceCur = priceToSqrtPrice((rangeLow + rangeHigh) / 2);
        uint256 liq0 = liquidity0(amount0, sqrtPriceCur, sqrtPriceHigh);
        uint256 liq1 = liquidity1(amount1, sqrtPriceCur, sqrtPriceLow);

        require(liq0 > 0 && liq1 > 0, "Liquidity must be greater than 0");

        liquidity = liq0 < liq1 ? liq0 : liq1;

        pool.reserve0 += amount0;
        pool.reserve1 += amount1;
        pool.liquidity += liquidity;

        emit LiquidityAdded(poolName, provider, amount0, amount1, liquidity);
        return liquidity;
    }

    function removeLiquidity(
        string memory poolName,
        uint256 liquidity,
        address provider
    ) external {
        Pool storage pool = pools[poolName];
        require(pool.token0 != address(0) && pool.token1 != address(0), "Pool does not exist");
        require(liquidity > 0, "Cannot remove zero liquidity");

        uint256 amount0 = (pool.reserve0 * liquidity) / pool.liquidity;
        uint256 amount1 = (pool.reserve1 * liquidity) / pool.liquidity;

        pool.reserve0 -= amount0;
        pool.reserve1 -= amount1;
        pool.liquidity -= liquidity;

        emit LiquidityRemoved(poolName, provider, amount0, amount1, liquidity);
    }

    function changeReserveThroughSwap(
        string memory poolName,
        uint256 amountTokenIn,
        bool isToken0In,
        address user
    ) external returns (uint256 amountTokenOut, uint256 feeRewards) {
        Pool storage pool = pools[poolName];
        require(pool.token0 != address(0) && pool.token1 != address(0), "Pool does not exist");

        uint256 fee = (pool.fee * amountTokenIn) / 10000;
        feeRewards = fee;

        if (isToken0In) {
            require(pool.reserve0 >= amountTokenIn, "Insufficient reserve0 for token0");
            amountTokenOut = (amountTokenIn - fee) * pool.reserve1 / pool.reserve0;
            pool.reserve0 += amountTokenIn;
            pool.reserve1 -= amountTokenOut;
        } else {
            require(pool.reserve1 >= amountTokenIn, "Insufficient reserve1 for token1");
            amountTokenOut = (amountTokenIn - fee) * pool.reserve0 / pool.reserve1;
            pool.reserve1 += amountTokenIn;
            pool.reserve0 -= amountTokenOut;
        }

        emit Swap(poolName, user, amountTokenIn, amountTokenOut, feeRewards);
        return (amountTokenOut, feeRewards);
    }
}