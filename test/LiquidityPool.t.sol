// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {LiquidityPool} from "../src/LiquidityPool.sol";
// import {ERC20Mock} from "./mocks/ERC20Mock.sol";


// contract LiquidityTest {
//  LiquidityPool liquidityPool;
//     ERC20Mock token0;
//     ERC20Mock token1;
//     address owner;
//     address provider;
//     function setUp() public {
//           owner = address(this);
//         provider = address(0x1234);

//         token0 = new ERC20Mock("Token0", "TK0", owner, 1000 ether);
//         token1 = new ERC20Mock("Token1", "TK1", owner, 1000 ether);

//         liquidityPool = new LiquidityPool("ETH/DAI", address(token0), address(token1), 3000, 1000, 2000);
//     };
//     function test() public {};
//       function testAddLiquidity() public {
//         uint256 amount0 = 10 ether;
//         uint256 amount1 = 20 ether;

//         token0.approve(address(liquidityPool), amount0);
//         token1.approve(address(liquidityPool), amount1);

//         uint256 liquidity = liquidityPool.addLiquidity("ETH/DAI", amount0, amount1, 1100, 1900, owner);

//         (,, uint256 reserve0, uint256 reserve1, uint256 poolLiquidity,) = liquidityPool.pools("ETH/DAI");

//         assertEq(reserve0, amount0);
//         assertEq(reserve1, amount1);
//         assertEq(poolLiquidity, liquidity);
//     }









// }