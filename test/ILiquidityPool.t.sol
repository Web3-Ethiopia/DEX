// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/ILiquidityPool.sol";
import "node_modules/@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "node_modules/@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";

contract LiquidityPoolTest is Test {
    LiquidityPool public liquidityPool;
    IUniswapV3Factory public factory;
    IUniswapV3Pool public pool;
    address public token0 = address(0x1);
    address public token1 = address(0x2);
    uint24 public fee = 3000;

    function setUp() public {
        factory = IUniswapV3Factory(address(0x3));
        liquidityPool = new LiquidityPool(address(factory), token0, token1, fee);

        // Mock the pool address
        pool = IUniswapV3Pool(address(0x4));
    }

    function testAddLiquidity() public {
        // Mock the getPool function
        vm.mockCall(
            address(factory),
            abi.encodeWithSelector(factory.getPool.selector, token0, token1, fee),
            abi.encode(address(pool))
        );

        // Mock the mint function
        vm.mockCall(
            address(pool),
            abi.encodeWithSelector(pool.mint.selector, msg.sender, int24(-887272), int24(887272), uint128(1000), ""),
            abi.encode(uint256(500), uint256(500))
        );

        liquidityPool.addLiquidity(int24(-887272), int24(887272), uint128(1000), "");

        }

    function testRemoveLiquidity() public {
        // Mock the getPool function
        vm.mockCall(
            address(factory),
            abi.encodeWithSelector(factory.getPool.selector, token0, token1, fee),
            abi.encode(address(pool))
        );

        // Mock the burn function
        vm.mockCall(
            address(pool),
            abi.encodeWithSelector(pool.burn.selector, int24(-887272), int24(887272), uint128(1000)),
            abi.encode(uint256(500), uint256(500))
        );

        liquidityPool.removeLiquidity(int24(-887272), int24(887272), uint128(1000));
    }
}