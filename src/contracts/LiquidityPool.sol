// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

struct Pool {
    address creator;
    string poolName;
    uint256 lowPrice;
    uint256 highPrice;
    uint256 token1Liquidity;
    uint256 token2Liquidity;
}

contract LiquidityPool {
    string public name;
    address public token1;
    address public token2;
    uint256 public token1Liquidity;
    uint256 public token2Liquidity;
    uint256 public lowPrice;
    uint256 public highPrice;
    Pool[] public pools;

    constructor(
        string _name,
        address _token1,
        address _token2,
        uint256 _token1Liquidity,
        uint256 _token2Liquidity,
        uint256 _lowPrice,
        uint256 _highPrice
    ) {
        name = _name;
        token1 = _token1;
        token2 = _token2;
        token1Liquidity = _token1Liquidity;
        token2Liquidity = _token2Liquidity;
        lowPrice = _lowPrice;
        highPrice = _highPrice;
        pools.push(
            Pool({
                creator: msg.sender,
                poolName: name,
                lowPrice: lowPrice,
                highPrice: highPrice,
                token1Liquidity: token1Liquidity,
                token2Liquidity: token2Liquidity
            })
        );
    }
}
