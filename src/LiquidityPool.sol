// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./StructsForLPs.sol";

contract LiquidityPool is StructsForLPs {
    address public token0;
    address public token1;
    uint24 public fee;

    uint256 private reserve0;
    uint256 private reserve1;
    uint256 public liquidity;

    Pool public pool;

    constructor(address _token0, address _token1, uint24 _fee, uint256 _reserve0, uint256 _reserve1, uint256 _liquidity) {
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        reserve0 = _reserve0;
        reserve1 = _reserve1;
        liquidity = _liquidity;
        pool.token0 = _token0;
        pool.token1 = _token1;
        pool.fee = _fee;
        pool.reserve0 = _reserve0;
        pool.reserve1 = _reserve1;
        pool.liquidity = _liquidity;
    }

    function getReserves() external view returns (uint256, uint256) {
        return (reserve0, reserve1);
    }

    function getPrice(string memory /* poolName */) external view returns (uint256) {
        return reserve0 * 1e18 / reserve1;
    }

    function getToken0() external view returns (address) {
        return token0;
    }

    function getToken1() external view returns (address) {
        return token1;
    }

    function addLiquidity(uint256 amountA, uint256 amountB, address /* to */) external returns (uint256) {
        reserve0 += amountA;
        reserve1 += amountB;
        return reserve0 + reserve1;
    }

    function removeLiquidity(uint256 amount, address /* to */) external returns (uint256, uint256) {
        uint256 amountA = reserve0 * amount / (reserve0 + reserve1);
        uint256 amountB = reserve1 * amount / (reserve0 + reserve1);
        reserve0 -= amountA;
        reserve1 -= amountB;
        return (amountA, amountB);
    }

    function getPoolState() external view returns (Pool memory) {
        return pool;
    }
}
