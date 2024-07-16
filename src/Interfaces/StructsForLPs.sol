// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IAllPoolManager {
    function fetchTokenReserves(string memory poolName) external view returns (uint256, uint256);
    function isMultiHopSwapPossible(string memory poolName) external view returns (bool);
} 

contract StructsForLPs is Ownable {
    
    struct TokenDetails {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
    }

    
    struct PoolPriceRange {
        uint256 min;
        uint256 max;
        uint64 pricePercentLimit;
    }

    
    struct LiquidityPool {
        uint256 totalLiquidity;
        uint256 totalFeesCollected;
        PoolPriceRange priceRange;
        TokenDetails tokenA;
        TokenDetails tokenB;
    }

    struct Pool {
        uint160 sqrtPriceX96;
        uint128 liquidity;
        uint256 lowPrice;
        uint256 highPrice;
        address creator;
        string poolName;
    }

    
    struct LiquidityProvider {
        address providerAddress;
        uint256 providedLiquidity;
        uint256 variableFees; 
    }
    
    mapping(address => LiquidityProvider) public liquidityProviders;

    LiquidityPool public liquidityPool;

    event LiquidityAdded(address indexed provider, uint256 amount);

    event FeesCollected(address indexed provider, uint256 amount);
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

    constructor(address _token0, address _token1, address initialOwner 
       
        address _tokenAAddress,
        string memory _tokenAName,
        string memory _tokenASymbol,
        uint8 _tokenADecimals,
        address _tokenBAddress,
        string memory _tokenBName,
        string memory _tokenBSymbol,
        uint8 _tokenBDecimals,
        uint256 _minPriceRange,
        uint256 _maxPriceRange ) Ownable(initialOwner)
     {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        
    }   

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

    uint256 contractBalanceAfter = IERC20(_tokenOut).balanceOf(address(this));
    console.log("Contract balance of output token after swap:", contractBalanceAfter);

    require(contractBalanceAfter >= amountOut, "Contract does not have enough output tokens");

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

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        LiquidityProvider storage provider = liquidityProviders[msg.sender];
        if (provider.providerAddress == address(0)) {
            provider.providerAddress = msg.sender;
        }

        provider.providedLiquidity += amount;
        liquidityPool.totalLiquidity += amount;

        emit LiquidityAdded(msg.sender, amount);
    }
function collectFees(address providerAddress, uint256 feeAmount) external {
        require(feeAmount > 0, "Fee amount must be greater than zero");
        require(liquidityProviders[providerAddress].providerAddress != address(0), "Provider does not exist");

        LiquidityProvider storage provider = liquidityProviders[providerAddress];
        provider.variableFees += feeAmount;
        liquidityPool.totalFeesCollected += feeAmount;

        emit FeesCollected(providerAddress, feeAmount);
    }

    function adjustDecimals(uint256 amount, uint8 fromDecimals, uint8 toDecimals) public pure returns (uint256) {
        if (fromDecimals > toDecimals) {
            return amount / (10 ** (fromDecimals - toDecimals));
        } else if (fromDecimals < toDecimals) {
            return amount * (10 ** (toDecimals - fromDecimals));
        } else {
            return amount;
        }
    }
    
}
