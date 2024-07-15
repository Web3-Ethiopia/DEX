// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StructsForLPs {

    
    struct TokenDetails {
        address tokenAddress;
        string name;
        string symbol;
        uint8 decimals;
    }

    
    struct PoolPriceRange {
        uint256 min;
        uint256 max;
        uint64 pricePercentLimit;
    }

    
    struct LiquidityPool {
        uint256 totalLiquidity;
        uint256 totalFeesCollected;
        PoolPriceRange priceRange;
        TokenDetails tokenA;
        TokenDetails tokenB;
    }

    
    struct LiquidityProvider {
        address providerAddress;
        uint256 providedLiquidity;
        uint256 variableFees; 
    }
    
    mapping(address => LiquidityProvider) public liquidityProviders;

    LiquidityPool public liquidityPool;

    event LiquidityAdded(address indexed provider, uint256 amount);

    event FeesCollected(address indexed provider, uint256 amount);

    constructor(
        address _tokenAAddress,
        string memory _tokenAName,
        string memory _tokenASymbol,
        uint8 _tokenADecimals,
        address _tokenBAddress,
        string memory _tokenBName,
        string memory _tokenBSymbol,
        uint8 _tokenBDecimals,
        uint256 _minPriceRange,
        uint256 _maxPriceRange
    ) {
        liquidityPool.tokenA = TokenDetails(_tokenAAddress, _tokenAName, _tokenASymbol, _tokenADecimals);
        liquidityPool.tokenB = TokenDetails(_tokenBAddress, _tokenBName, _tokenBSymbol, _tokenBDecimals);
        liquidityPool.totalLiquidity = 0;
        liquidityPool.totalFeesCollected = 0;
    }

    function addLiquidity(uint256 amount) external {
        require(amount > 0, "Amount must be greater than zero");

        LiquidityProvider storage provider = liquidityProviders[msg.sender];
        if (provider.providerAddress == address(0)) {
            provider.providerAddress = msg.sender;
        }

        provider.providedLiquidity += amount;
        liquidityPool.totalLiquidity += amount;

        emit LiquidityAdded(msg.sender, amount);
    }
function collectFees(address providerAddress, uint256 feeAmount) external {
        require(feeAmount > 0, "Fee amount must be greater than zero");
        require(liquidityProviders[providerAddress].providerAddress != address(0), "Provider does not exist");

        LiquidityProvider storage provider = liquidityProviders[providerAddress];
        provider.variableFees += feeAmount;
        liquidityPool.totalFeesCollected += feeAmount;

        emit FeesCollected(providerAddress, feeAmount);
    }

    function adjustDecimals(uint256 amount, uint8 fromDecimals, uint8 toDecimals) public pure returns (uint256) {
        if (fromDecimals > toDecimals) {
            return amount / (10 ** (fromDecimals - toDecimals));
        } else if (fromDecimals < toDecimals) {
            return amount * (10 ** (toDecimals - fromDecimals));
        } else {
            return amount;
        }
    }
    
}
