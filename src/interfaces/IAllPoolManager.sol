// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;




interface IAllPoolManager{

    function createPool(address inputToken, address outputToken,uint256 fee)external returns(address pool);
    function addLiquidityToPool(address inputToken,address pool,uint256 amount) external;
    function removeLiquidityFromPool(address outputToken,address pool,uint256 amount)external;
    function collectReward(address pool)external;
    function swap(address inputToken,address outputToken,uint256 amount) external;
}