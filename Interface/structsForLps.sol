// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructsForLps {

    struct PriceRange {
        uint256 minPrice;
        uint256 maxPrice;
    }

    struct LiquidityPool {
        uint256 dailyVolume;
        uint256 totalValueIn;
        address lp_Provider;
        PriceRange[] priceRanges;
    }

    mapping(string => LiquidityPool) liquidityPools;

    function swap(address pair1, address pair2) public {
        LiquidityPool storage localLP = liquidityPools[""]; 
        localLP.dailyVolume += 1; 
    }

    function bridge (address msg.sender, address pair1, address pair2) {
        LiquidityPool storage localLP = liquidityPools[""];
        localLP.dailyVolume += 1;
    }
}