// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

interface ILiquidityPool {

    event AddLiquidity(address indexed provider, uint256 token0amount, uint256 token1amount);

    event RemoveLiquidity(address indexed provider, uint256 token0amount, uint256 token1amount);

    event RangeBalance(uint256 lowerBound, uint256 upperBound);

    event FeeValue(uint256 fee);

    function addLiquidity(uint256 token0amount, uint256 token1amount) external returns (uint256 liquidity);
    
    function removeLiquidity(uint256 token0amount, uint256 token1amount) external returns (uint256 _token0amount, uint256 _token1amount);
    
    function totalLiquidity() external view returns (uint256);

    function getPrice0() external view returns (uint256);

    function getPrice1() external view returns (uint256);

    function getProviderDetails(address provider) external view returns (uint256 liquidityProvided);

    function setPriceRange(uint256 lowerBound, uint256 upperBound) external;

    function getPriceRange() external view returns (uint256 lowerBound, uint256 upperBound);

    function setFee(uint256 fee) external;
    
    function getFee() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to) external returns (uint256 amount0, uint256 amount1);

    function swap(uint256 amount0Out, uint256 amount1Out, address to) external;

    function totalSupply() external view returns (uint256);

    function getPoolDetails() external view returns (
        address token0,
        address token1,
        uint256 reserve0,
        uint256 reserve1,
        uint256 totalLiquidity,
        uint256 lowerBound,
        uint256 upperBound,
        uint256 fee
    );
}
