// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IAllPoolManager {
    function fetchTokenReserves(string memory poolName) external view returns (uint256, uint256);
    function isMultiHopSwapPossible(string memory poolName) external view returns (bool);
}

contract LiquidityPool is Ownable {
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
    IAllPoolManager public allPoolManager;

    constructor(address _token0, address _token1, address initialOwner) Ownable(initialOwner) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function createPool(
        string memory _poolName,
        uint160 _sqrtPriceX96,
        uint128 _liquidity,
        uint256 _lowPrice,
        uint256 _highPrice
    ) external onlyOwner {
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

    // console.log("Swapping", _amountIn, "of", _tokenIn, "to", _tokenOut, "with min output", _amountOutMin);

    IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    // console.log("Transferred", _amountIn, "of", _tokenIn, "to the contract");

    uint256 contractBalanceBefore = IERC20(_tokenOut).balanceOf(address(this));
    console.log("Contract balance of output token before swap:", contractBalanceBefore);

    SwapState memory state = SwapState({
        amountSpecifiedRemaining: int256(_amountIn),
        amountCalculated: 0,
        sqrtPriceX96: pool.sqrtPriceX96,
        tickOfCurrentPrice: getCurrentTick(pool.sqrtPriceX96),
        protocolFee: 0,
        liquidity: pool.liquidity
    });

    // console.log("Initial swap state:", state.amountSpecifiedRemaining, state.amountCalculated, state.sqrtPriceX96, state.tickOfCurrentPrice, state.protocolFee, state.liquidity);

    SwapCache memory cache = SwapCache({
        feeProtocol: 0,
        liquidityStart: pool.liquidity,
        blockTimestamp: uint32(block.timestamp),
        isOutOfRange: false,
        secondsPerLiquidityCumulativeX128: 0,
        computedLatestObservation: false
    });

    // console.log("Initial swap cache:", cache.feeProtocol, cache.liquidityStart, cache.blockTimestamp, cache.isOutOfRange, cache.secondsPerLiquidityCumulativeX128, cache.computedLatestObservation);

    uint256 amountOut = _performSwap(_tokenIn, _tokenOut, _amountIn, state, cache, pool);

    console.log("amountOut:", amountOut); // Debugging statement

    require(amountOut >= _amountOutMin, "Output amount less than minimum");

    uint256 contractBalanceAfter = IERC20(_tokenOut).balanceOf(address(this));
    console.log("Contract balance of output token after swap:", contractBalanceAfter);

    require(contractBalanceAfter >= amountOut, "Contract does not have enough output tokens");

    // console.log("Transferring", amountOut, "of", _tokenOut, "to", _to);

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
    uint256 amountOut;
    uint160 sqrtPriceBX96 = state.sqrtPriceX96;
    uint160 sqrtPriceCX96 = state.sqrtPriceX96;
    uint256 liquidity = state.liquidity;

    console.log("Performing swap with initial sqrtPriceX96:", state.sqrtPriceX96);

    // Simplified price calculation for demonstration purposes
    uint256 priceDiff = (liquidity * _amountIn) / (uint256(sqrtPriceBX96) * uint256(sqrtPriceCX96));
    uint160 newSqrtPriceX96 = uint160(uint256(sqrtPriceBX96) + priceDiff);

    console.log("Calculated price difference:", priceDiff);
    console.log("New sqrtPriceX96 after price difference:", newSqrtPriceX96);

    if (_tokenIn == address(token0) && _tokenOut == address(token1)) {
        amountOut = (_amountIn * uint256(sqrtPriceBX96)) / uint256(sqrtPriceCX96);
    } else if (_tokenIn == address(token1) && _tokenOut == address(token0)) {
        amountOut = (_amountIn * uint256(sqrtPriceCX96)) / uint256(sqrtPriceBX96);
    } else {
        revert("Invalid token pair");
    }

    console.log("New sqrtPriceX96:", newSqrtPriceX96);
    console.log("Calculated amountOut:", amountOut);

    pool.sqrtPriceX96 = newSqrtPriceX96;
    return amountOut;
}

    function getCurrentTick(uint160 sqrtPriceX96) internal pure returns (int24) {
        int256 tick = int256(uint256(sqrtPriceX96) / (1 << 96));
        require(tick >= type(int24).min && tick <= type(int24).max, "Tick out of int24 range");
        return int24(tick);
    }

    function fetchTokenReserves(string memory poolName) public view returns (uint256, uint256) {
        return allPoolManager.fetchTokenReserves(poolName);
    }

    function isMultiHopSwapPossible(string memory poolName) public view returns (bool) {
        return allPoolManager.isMultiHopSwapPossible(poolName);
    }
}