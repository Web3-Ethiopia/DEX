// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {LiquidityPool} from "./LiqidityPool.sol";
import {AllPoolManager} from "./AllPoolManger.sol";



interface ILiquidityPool {
    function liquidity0(uint256 amount, uint160 pa, uint160 pb) external pure  returns(uint256);
    function liquidity1(uint256 amount, uint160 pa, uint160 pb) external pure returns(uint256);
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

    event MultiSwap(
        address indexed sender,
        address[] tokensIn,
        address[] tokensOut,
        uint256[] amountsIn,
        uint256 totalAmountOut,
        address indexed to
);

    IERC20 public token0;
    IERC20 public token1;
    AllPoolManager public allPoolManager;
    Pool[] public pools;
    mapping(string => uint256) public poolIndex; // Map pool name to index
    mapping(string => LiquidityPool) liquidityPoolMap;
    IAllPoolManager public allPoolManager;
    IliquidityPool public liquidityPool;

    constructor(address _token0, address _token1, address initialOwner, address _IliquidityPool) Ownable(initialOwner) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        liquidityPool = IliquidityPool(_IliquidityPool);
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

    // IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    // console.log("Transferred", _amountIn, "of", _tokenIn, "to the contract");

    bool success = IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
    require(success, "Transfer from failed");


    uint256 contractBalanceBefore = IERC20(_tokenOut).balanceOf(address(this));
    // console.log("Contract balance of output token before swap:", contractBalanceBefore);

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

    // console.log("amountOut:", amountOut); // Debugging statement

    require(amountOut >= _amountOutMin, "Output amount less than minimum");

    uint256 contractBalanceAfter = IERC20(_tokenOut).balanceOf(address(this));
    // console.log("Contract balance of output token after swap:", contractBalanceAfter);

    require(contractBalanceAfter >= amountOut, "Contract does not have enough output tokens");

    // console.log("Transferring", amountOut, "of", _tokenOut, "to", _to)

    // IERC20(_tokenOut).transfer(_to, amountOut);
    bool success = IERC20(_tokensOut[_tokensOut.length - 1]).transfer(_to, totalAmountOut);
    require(success, "Transfer to recipient failed");

    // LiquidtyPool.changeReserveThroughSwap(_poolName,_tokenIn,_amountIn,_to);
    // liquidityPoolMap[_poolName].changeReserveThroughSwap(_poolName, _tokenIn, _amountIn, _to);

    ILiquidityPool(allPoolManager.fetchLiquidityPoolAddress(_poolName)).changeReserveThroughSwap(_poolName, _tokenIn, _amountIn, address(this));

    emit Swap(msg.sender, _tokenIn, _tokenOut, _amountIn, amountOut, _to);
}

function multiSwap(
    string[] memory _poolNames,
    address[] memory _tokensIn,
    address[] memory _tokensOut,
    uint256[] memory _amountsIn,
    uint256[] memory _amountsOutMin,
    address _to
) external {
    require(_poolNames.length == _tokensIn.length, "Mismatched input lengths");
    require(_tokensIn.length == _tokensOut.length, "Mismatched input lengths");
    require(_tokensOut.length == _amountsIn.length, "Mismatched input lengths");
    require(_amountsIn.length == _amountsOutMin.length, "Mismatched input lengths");

    for (uint256 i = 0; i < _poolNames.length - 1; i++) {
            require(allPoolManager.isMultiHopSwapPossible(_poolNames[i], _poolNames[i+1]), "Multi-hop swap not possible");
        }

    uint256 totalAmountOut = 0;
    for (uint256 i = 0; i < _poolNames.length; i++) {
        uint256 amountOut = swap(
            _poolNames[i],
            _tokensIn[i],
            _tokensOut[i],
            _amountsIn[i],
            _amountsOutMin[i],
            address(this)  
        );
        totalAmountOut += amountOut;

    ILiquidityPool(allPoolManager.fetchLiquidityPoolAddress(_poolNames[i])).changeReserveThroughSwap(
            _poolNames[i],
            _tokensIn[i],
            _amountsIn[i],
            msg.sender  
        );
    }


    require(totalAmountOut >= _amountsOutMin[_amountsOutMin.length - 1], "Output amount less than minimum");
    // IERC20(_tokensOut[_tokensOut.length - 1]).transfer(_to, totalAmountOut);

    bool success = IERC20(_tokensOut[_tokensOut.length - 1]).transfer(_to, totalAmountOut);
    require(success, "Transfer to recipient failed");

    emit MultiSwap(msg.sender, _tokensIn, _tokensOut, _amountsIn, totalAmountOut, _to);

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

    // console.log("Performing swap with initial sqrtPriceX96:", state.sqrtPriceX96);
    uint256 liquidity0 = liquidityPool.liquidity0(_amountIn, sqrtPriceBX96, sqrtPriceCX96);
    uint256 liquidity1 = liquidityPool.liquidity1(_amountIn, sqrtPriceBX96, sqrtPriceCX96);

    // Simplified price calculation for demonstration purposes
    uint256 priceDiff = (liquidity * liquidity0) / liquidity1;
    uint160 newSqrtPriceX96 = uint160(uint256(sqrtPriceBX96) + priceDiff);

    // console.log("Calculated price difference:", priceDiff);
    // console.log("New sqrtPriceX96 after price difference:", newSqrtPriceX96);

    if (_tokenIn == address(token0) && _tokenOut == address(token1)) {
        amountOut = (_amountIn * uint256(sqrtPriceBX96)) / uint256(sqrtPriceCX96);
    } else if (_tokenIn == address(token1) && _tokenOut == address(token0)) {
        amountOut = (_amountIn * uint256(sqrtPriceCX96)) / uint256(sqrtPriceBX96);
    } else {
        revert("Invalid token pair");
    }

    // console.log("New sqrtPriceX96:", newSqrtPriceX96);
    // console.log("Calculated amountOut:", amountOut);

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