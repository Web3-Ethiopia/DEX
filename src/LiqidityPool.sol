// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "./StructForLp.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityPool is StructsForLPs, Ownable {
    uint256 constant Q96 = 2**96;
    IERC20 public lpRewardsToken;

    mapping(string => Pool) public pools;
    mapping(address => mapping(address => PoolPortion)) public poolPortions;
    mapping(address => uint256) public liquidityProviderVolume; 
    mapping(address => uint256) public liquidityProviderTime;

    event LiquidityAdded(string indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event LiquidityRemoved(string indexed pool, address indexed provider, uint256 amount0, uint256 amount1, uint256 liquidity);
    event PoolStateUpdated(address indexed pool, uint256 reserve0, uint256 reserve1, uint256 liquidity);

    constructor(
        string memory _poolName,
        address _token0,
        address _token1,
        uint24 _fee,
        uint256 _lowPrice,
        uint256 _highPrice,
        address _lpRewardsToken
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
        lpRewardsToken = IERC20(_lpRewardsToken);
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
        if (pa > pb) {
            (pa, pb) = (pb, pa);
        }
        return (amount * uint256(pa) * uint256(pb) / Q96) / (uint256(pb) - uint256(pa));
    }

    function liquidity1(uint256 amount, uint160 pa, uint160 pb) public pure returns (uint256) {
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

        liquidity = liq0 < liq1 ? liq0 : liq1;

        pool.reserve0 += amount0;
        pool.reserve1 += amount1;
        pool.liquidity += liquidity;

        // Update the provider's portion
        poolPortions[provider][poolName].amount0 += amount0;
        poolPortions[provider][poolName].amount1 += amount1;

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
        require(liquidity <= pool.liquidity, "Insufficient liquidity");

        uint256 amount0 = (pool.reserve0 * liquidity) / pool.liquidity;
        uint256 amount1 = (pool.reserve1 * liquidity) / pool.liquidity;

        pool.reserve0 -= amount0;
        pool.reserve1 -= amount1;
        pool.liquidity -= liquidity;

        // Update the provider's portion
        poolPortions[provider][poolName].amount0 -= amount0;
        poolPortions[provider][poolName].amount1 -= amount1;

        emit LiquidityRemoved(poolName, provider, amount0, amount1, liquidity);
    }

    function changeReserveThroughSwap(
        string memory poolName,
        address tokenIn,
        uint256 amountIn,
        address provider
    ) external {
        Pool storage pool = pools[poolName];

        require(pool.token0 == tokenIn || pool.token1 == tokenIn, "Invalid token");

        uint256 amountOut;
        if (tokenIn == pool.token0) {
            amountOut = (amountIn * pool.reserve1) / pool.reserve0;
            pool.reserve0 += amountIn;
            pool.reserve1 -= amountOut;
        } else {
            amountOut = (amountIn * pool.reserve0) / pool.reserve1;
            pool.reserve1 += amountIn;
            pool.reserve0 -= amountOut;
        }

        // Mint LP rewards tokens to the provider
        uint256 rewards = calculateRewards(amountIn);
        lpRewardsToken.transfer(provider, rewards);

        emit PoolStateUpdated(address(this), pool.reserve0, pool.reserve1, pool.liquidity);
    }

      function calculateRewards(uint256 amountIn, uint256 totalVolume, address provider) internal view returns (uint256) {
        uint256 volumeFactor = (liquidityProviderVolume[provider] * 1e18) / totalVolume;
        uint256 timeFactor = (block.timestamp - liquidityProviderTime[provider]) * 1e18 / (30 days); // Example: 30 days as a base time unit
        uint256 reward = amountIn * volumeFactor * timeFactor / 1e36; // Adjusting for decimal scaling
        return reward;
    }
}
