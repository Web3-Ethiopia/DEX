// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./Pool.sol";

interface IAllPoolManager{

    function createPool(address inputToken, address outputToken,uint256 fee)external returns(address pool);
    function addLiquidityToPool(address inputToken,address pool,uint256 amount) external;
    function removeLiquidityFromPool(address outputToken,address pool,uint256 amount)external;
    function collectReward(address pool)external;
    function swap(address inputToken,address outputToken,uint256 amount) external;
}

contract AllPoolManager is IAllPoolManager {
    mapping(address => address) public pools; // pool address to pool contract

    function createPool(address inputToken, address outputToken, uint256 fee) external override returns (address pool) {
        Pool newPool = new Pool(inputToken, outputToken, fee);
        pool = address(newPool);
        pools[pool] = pool;
    }

    function addLiquidityToPool(address inputToken, address poolAddress, uint256 amount) external override {
        Pool pool = Pool(poolAddress);
        require(pool.inputToken() == inputToken, "Invalid input token for pool");
        pool.addLiquidity(msg.sender, amount);
    }

    function removeLiquidityFromPool(address outputToken, address poolAddress, uint256 amount) external override {
        Pool pool = Pool(poolAddress);
        require(pool.outputToken() == outputToken, "Invalid output token for pool");
        pool.removeLiquidity(msg.sender, amount);
    }

    function collectReward(address poolAddress) external override {
        Pool pool = Pool(poolAddress);
        pool.collectReward(msg.sender);
    }

    function swap(address inputToken, address outputToken, uint256 amount) external override {
        
        address poolAddress = findPool(inputToken, outputToken);
        require(poolAddress != address(0), "Pool does not exist");
        Pool pool = Pool(poolAddress);
        pool.swap(inputToken, outputToken, amount);
    }

}