// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LiquidityPool {
    struct Pool {
        uint160 sqrtPriceX96;
        uint128 liquidity;
        uint256 lowPrice;
        uint256 highPrice;
        address creator;
        string poolName;
    }

    struct SwapCache {
        uint8 feeProtocol;
        uint128 liquidityStart;
        uint32 blockTimestamp;
        bool isOutOfRange;
        uint160 secondsPerLiquidityCumulativeX128;
        bool computedLatestObservation;
    }

    struct SwapState {
        int256 amountSpecifiedRemaining;
        int256 amountCalculated;
        uint160 sqrtPriceX96;
        int24 tickOfCurrentPrice;
        uint128 protocolFee;
        uint128 liquidity;
    }

    event Swap(
        address indexed sender,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut,
        address to
    );

    IERC20 public token0;
    IERC20 public token1;
    Pool[] public pools;
    mapping(string => uint256) public poolIndex; // Map pool name to index

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function createPool(
        string memory _poolName,
        uint160 _sqrtPriceX96,
        uint128 _liquidity,
        uint256 _lowPrice,
        uint256 _highPrice
    ) external {
        Pool memory newPool = Pool({
            sqrtPriceX96: _sqrtPriceX96,
            liquidity: _liquidity,
            lowPrice: _lowPrice,
            highPrice: _highPrice,
            creator: msg.sender,
            poolName: _poolName
        });

        pools.push(newPool);
        poolIndex[_poolName] = pools.length - 1;
    }

    function getPool(string memory _poolName) public view returns (Pool memory) {
        return pools[poolIndex[_poolName]];
    }

    function swap(
        string memory _poolName,
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin,
        address _to
    ) external {
        Pool storage pool = pools[poolIndex[_poolName]];

        require(_tokenIn == address(token0) || _tokenIn == address(token1), "Invalid input token");
        require(_tokenOut == address(token0) || _tokenOut == address(token1), "Invalid output token");
        require(_amountIn > 0, "Amount in must be greater than 0");

        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        SwapState memory state = SwapState({
            amountSpecifiedRemaining: int256(_amountIn),
            amountCalculated: 0,
            sqrtPriceX96: pool.sqrtPriceX96,
            tickOfCurrentPrice: getCurrentTick(pool.sqrtPriceX96),
            protocolFee: 0,
            liquidity: pool.liquidity
        });

        SwapCache memory cache = SwapCache({
            feeProtocol: 0,
            liquidityStart: pool.liquidity,
            blockTimestamp: uint32(block.timestamp),
            isOutOfRange: false,
            secondsPerLiquidityCumulativeX128: 0,
            computedLatestObservation: false
        });

        uint256 amountOut = _performSwap(_tokenIn, _tokenOut, _amountIn, state, cache, pool);

        require(amountOut >= _amountOutMin, "Output amount less than minimum");

        IERC20(_tokenOut).transfer(_to, amountOut);

        emit Swap(msg.sender, _tokenIn, _tokenOut, _amountIn, amountOut, _to);
    }

    function _performSwap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        SwapState memory state,
        SwapCache memory cache,
        Pool storage pool
    ) internal returns (uint256) {
        uint160 sqrtPriceX96 = state.sqrtPriceX96;
        uint128 liquidity = state.liquidity;

        uint256 amountOut;
        if (_tokenIn == address(token0) && _tokenOut == address(token1)) {
            uint256 amount0Delta = _amountIn * sqrtPriceX96 / (1 << 96);
            amountOut = amount0Delta * liquidity / sqrtPriceX96;
        } else if (_tokenIn == address(token1) && _tokenOut == address(token0)) {
            uint256 amount1Delta = _amountIn * (1 << 96) / sqrtPriceX96;
            amountOut = amount1Delta * liquidity / sqrtPriceX96;
        } else {
            revert("Invalid token pair");
        }

        pool.sqrtPriceX96 = uint160(uint256(sqrtPriceX96) + _amountIn / liquidity);

        return amountOut;
    }

    function getCurrentTick(uint160 sqrtPriceX96) internal pure returns (int24) {
        int256 tick = int256(uint256(sqrtPriceX96) / (1 << 96));
        require(tick >= type(int24).min && tick <= type(int24).max, "Tick out of int24 range");
        return int24(tick);
    }
}
