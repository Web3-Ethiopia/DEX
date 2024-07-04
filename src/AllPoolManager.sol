// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./LiquidityPool.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AllPoolManager is Ownable {

    // Mapping to store liquidity pools by their name
    mapping(string => LiquidityPool) private liquidityPoolMap;

    // Mapping to store user pool portions
    mapping(address => mapping(address => LiquidityPool.PoolPortion)) public poolPortions;

    // Event declarations
    event PoolCreated(string name, address indexed token1, address indexed token2, address poolAddress);
    event LiquidityAdded(address indexed provider, string poolName, uint256 amount0, uint256 amount1);
    event LiquidityRemoved(address indexed provider, string poolName, uint256 liquidity);
    event SwapExecuted(address indexed sender, string poolName, address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    // Modifier to ensure only the pool owner can perform certain actions
    modifier onlyPoolOwner(string memory name) {
        require(poolOwners[name] == msg.sender, "Not pool owner");
        _;
    }

    // Modifier to check if a pool exists
    modifier poolExists(string memory name) {
        require(address(liquidityPoolMap[name]) != address(0), "Pool does not exist");
        _;
    }

    // Mapping to store pool owners by pool name
    mapping(string => address) public poolOwners;

    // Function to create a new liquidity pool
    function createPool(
        string memory name,
        address token1,
        address token2,
        uint24 fee,
        uint256 lowPrice,
        uint256 highPrice
    ) external onlyOwner returns (LiquidityPool) {
        require(highPrice > lowPrice, "High range must exceed low range");
        require(address(liquidityPoolMap[name]) == address(0), "Pool already exists");

        LiquidityPool liquidityPool = new LiquidityPool(name, token1, token2, fee, lowPrice, highPrice);
        liquidityPoolMap[name] = liquidityPool;
        poolOwners[name] = msg.sender;

        emit PoolCreated(name, token1, token2, address(liquidityPool));
        return liquidityPool;
    }

    // Function to add liquidity to an existing pool
    function addLiquidity(
        string memory name,
        uint256 token1Amount,
        uint256 token2Amount
    ) external poolExists(name) onlyPoolOwner(name) returns (uint256 liquidity) {
        LiquidityPool pool = liquidityPoolMap[name];
        (uint256 amount0, uint256 amount1) = pool.addLiquidity(token1Amount, token2Amount, msg.sender);

        emit LiquidityAdded(msg.sender, name, amount0, amount1);
        return liquidity;
    }

    // Function to remove liquidity from an existing pool
    function removeLiquidity(
        string memory name,
        uint256 liquidity
    ) external poolExists(name) onlyPoolOwner(name) returns (uint256 amount0, uint256 amount1) {
        LiquidityPool pool = liquidityPoolMap[name];
        (amount0, amount1) = pool.removeLiquidity(liquidity, msg.sender);

        emit LiquidityRemoved(msg.sender, name, liquidity);
        return (amount0, amount1);
    }

    // Function to execute a swap
    function swap(
        string memory name,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        address to
    ) external poolExists(name) {
        LiquidityPool pool = liquidityPoolMap[name];

        // Ensure the input token is one of the pool tokens
        require(tokenIn == address(pool.token0()) || tokenIn == address(pool.token1()), "Invalid input token");
        // Ensure the output token is one of the pool tokens
        require(tokenOut == address(pool.token0()) || tokenOut == address(pool.token1()), "Invalid output token");

        // Transfer the input tokens from the sender to this contract
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);

        // Perform the swap
        uint256 amountOut = pool.swap(name, tokenIn, tokenOut, amountIn, amountOutMin, to);

        // Ensure the output amount is greater than or equal to the minimum specified
        require(amountOut >= amountOutMin, "Output amount less than minimum");

        // Transfer the output tokens to the specified address
        IERC20(tokenOut).transfer(to, amountOut);

        emit SwapExecuted(msg.sender, name, tokenIn, tokenOut, amountIn, amountOut);
    }

    // Function to calculate the average price
    function getAvgPrice(uint256 lowPrice, uint256 highPrice) public pure returns (uint256) {
        require(highPrice > lowPrice, "High price must be greater than low price");
        return (highPrice + lowPrice) / 2;
    }
}
