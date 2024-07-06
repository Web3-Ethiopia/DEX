# DEX Approaches and Requirements

## LiquidityPool Contract

### Context of approach:
- Mappings should store the overall state of the pool on addition/removal of liquidity along with provider based individual pool portion details.
  - Example: Change in total liquidity reserves for both pairs after adding or removal
- The liquidity should not cross the max and min range when provided by a provider.
- New method `changeReserveThroughSwap` should be added:
  - Performs addition of given token reserve being provided by the user or "sold" to the pool and removal of token2 reserve being "bought" by the user.
  - Function `changeReserveThroughSwap` mints feeRewards tokens according to fee % of the pool
- `RemoveLiquidity` should remove liquidity with releasing feeReward equivalent pair tokens being removed and update state to amount of total liquidity removed from a provider
- Methods for returning reserves of the pool.
- Methods for returning poolPortion details based on providers address.
- Methods for calculating amounts based on Liquidity reserves and swapPrice:
  ```
  Formulae for calculation:
  amount0 = uint256(liquidity) * uint256(sqrtPHigh - sqrtPCurrent) * Q96 / uint256(sqrtPHigh * sqrtPCurrent);
  amount1 = uint256(liquidity) * (sqrtPCurrent - sqrtPLow) / Q96;
  ```
- Method for calculating current liquidity based on the current overall state of the pool
  ```
  Formulae for Liquidity:
  uint256 liquidity0 = (amount0 * Q96 * (sqrtPHigh - sqrtPCurrent)) / (sqrtPHigh - sqrtPLow);
  uint256 liquidity1 = (amount1 * (sqrtPCurrent - sqrtPLow)) / Q96
  ```

## AllPoolManager Contract

### Context of approach:
- The mappings should store the Pool contract address based on string PoolName key pair.
  - Example: `("ETH/BNB"=>0x225d16264d40dea10560ca0d8d02f208f614348f)` (mapping(string=>address))
- Interface methods for calling addLiquidity and removeLiquidity along with obtaining current pool state functions of the LiquidityPool contracts based on PoolName query.
  - Example: `ILiquidityPool(poolNames["ETH/DAI"]).addLiquidity(..params)`
- Methods for confirming whether multi route swap is possible returns boolean.
  - Example: `isMultiHopSwapPossible(ETH/DAI)` - "checks for all pairs of ETH, checks for all pairs of DAI. Finds whether either pairs have common pair like 'ETH/USDT' and 'DAI/USDT'"
- Methods to fetch poolPortion data for a given poolName based on providers address.
  - Example: `getProviderBasedOnPool("ETH/BNB", providerAddress)-> calls ILiquidityPool(poolNames["ETH/BNB"]).getProviderPoolDetails(providerAddress)`
- Methods to call fetch liquidity Token reserves for a pool based on poolName

## Swap Contract

### Context of approach:
- The swap cache and swap state should maintain their individual state in case of either multihop swaps or a poolPortion that runs out of funds crossing the range.
- Methods for calculating current price based on Liquidity reserves fetched from allPoolManager.
  - Example: `IAllPoolManger(address).fetchTokenReserves("ETH/USDT")` returns (uint256 ETHReserves, uint256 USDTReserves)
- Methods for making multiple calls for multiHopSwaps after checking from the AllPoolManagers method `isMultiHopSwapPossible(string poolName)`
  - Example:
    ```
    isMultiHopSwapPossible(ETH/DAI) = true?
    ILiquidityPool(address poolContract).changeReserveThroughSwap(ETH/USDT);
    ILiquidityPool(address poolContract).changeReserveThroughSwap(DAI/USDT);
    ```
