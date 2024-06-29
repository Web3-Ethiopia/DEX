// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {LiquidityPool} from "../src/LiquidityPool.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";


contract LiquidityTest {
 LiquidityPool liquidityPool;
    ERC20Mock token0;
    ERC20Mock token1;
    address owner;
    address provider;
    function setUp() public {
          owner = address(this);
        provider = address(0x1234);

        token0 = new ERC20Mock("Token0", "TK0", owner, 1000 ether);
        token1 = new ERC20Mock("Token1", "TK1", owner, 1000 ether);

        liquidityPool = new LiquidityPool("ETH/DAI", address(token0), address(token1), 3000, 1000, 2000);
    };
    function test() public {};
}