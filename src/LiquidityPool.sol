// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./StructsForLPs.sol";
import "./ILiquidityPoolInterface.sol";
import "./IQoutationFeatch.sol"; // Import the interface

contract LiquidityPool is StructsForLPs {
    uint256 public constant Q96 = 2**96;

    mapping(string => Pool) public pools;
    mapping(address => mapping(address => PoolPortion)) public poolPortions;

    // Reference to the quotation service
    IQoutationFeatch public quotationFeatch;

    event LiquidityAdded(
        string indexed poolName,
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    event LiquidityRemoved(
        string indexed poolName,
        address indexed provider,
        uint256 amount0,
        uint256 amount1,
        uint256 liquidity
    );

    event PoolStateUpdated(
        string indexed poolName,
        uint256 reserve0,
        uint256 reserve1,
        uint256 liquidity
    );

    constructor(
        string memory _poolName,
        address _token0,
        address _token1,
        uint24 _fee,
        uint256 _lowPrice,
        uint256 _highPrice,
        IQoutationFeatch _quotationFeatch // Inject quotation service
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
        quotationFeatch = _quotationFeatch; // Set quotation service
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
        address provider
    ) public returns (uint256) {
        Pool storage pool = pools[poolName];
        require(amount0 > 0 && amount1 > 0, "Insufficient amount provided");

        // Fetch estimated price using quotation service
        uint256 estimatedPrice = quotationFeatch.getPrice(address(this));
        require(estimatedPrice > 0, "Failed to fetch price");

        // Calculate liquidity based
                // (Consider incorporating price impact calculations here)
        uint256 newLiquidity = liquidity0(amount0, priceToSqrtPrice(estimatedPrice), priceToSqrtPrice(pool.reserve1)) +
                                 liquidity1(amount1, priceToSqrtPrice(pool.reserve0), priceToSqrtPrice(estimatedPrice));

        pool.reserve0 += amount0;
        pool.reserve1 += amount1;
        pool.liquidity += newLiquidity;

        // Transfer tokens from provider (implementation omitted for brevity)

        emit LiquidityAdded(poolName, provider, amount0, amount1, newLiquidity);
        emit PoolStateUpdated(poolName, pool.reserve0, pool.reserve1, pool.liquidity);

        return newLiquidity;
    }

