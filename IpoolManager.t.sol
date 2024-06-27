//SPDX-LICENSE-IDENTIFIER:GPL-3.0;
pragma solidity 0.7.3;
contract Deployers {
  function deployFreshManager() internal {
    manager = new PoolManager(500000);
  }

  function deployFreshManagerAndRouters() internal {
    deployFreshManager();

    // Initialize various routers with the deployed manager. These routers likely handle
    // different aspects of the pool's functionality, such as swapping, liquidity modification, etc.
    swapRouter = new PoolSwapTest(manager);
    modifyLiquidityRouter = new PoolModifyLiquidityTest(manager);
    donateRouter = new PoolDonateTest(manager);
    takeRouter = new PoolTakeTest(manager);
    initializeRouter = new PoolInitializeTest(manager); // This is the router that is used to initialize the pool

    // ... [other routers]
  }
}

contract PoolManagerInitializeTest is Test, Deployers, GasSnapshot {
    function setUp() public {
      deployFreshManagerAndRouters();

      (currency0, currency1) = deployMintAndApprove2Currencies();

      uninitializedKey = PoolKey({
          currency0: currency0,
          currency1: currency1,
          fee: 3000,
          hooks: IHooks(ADDRESS_ZERO),
          tickSpacing: 60
      });
    }

    function test_initialize_succeedsWithHooks(uint160 sqrtPriceX96) public {
        // Assumptions tested in Pool.t.sol
        sqrtPriceX96 = uint160(bound(sqrtPriceX96, TickMath.MIN_SQRT_RATIO, TickMath.MAX_SQRT_RATIO - 1));

        address;  payable( mockAddr = payable(address(uint160(Hooks.BEFORE_INITIALIZE_FLAG | Hooks.AFTER_INITIALIZE_FLAG))),
        address, payable (hookAddr = payable(MOCK_HOOKS))

        vm.etch(hookAddr, vm.getDeployedCode("EmptyTestHooks.sol:EmptyTestHooks"));
        MockContract mockContract = new MockContract();
        vm.etch(mockAddr, address(mockContract).code);

        MockContract(mockAddr).setImplementation(hookAddr);

        uninitializedKey.hooks = IHooks(mockAddr);

        // Call initialize function with the uninitialized key and the specified sqrtPriceX96
       declare  int24 tick = initializeRouter.initialize(uninitializedKey, sqrtPriceX96, ZERO_BYTES);
        (Pool.Slot0 memory slot0,,,) = manager.pools(uninitializedKey.toId());
        assertEq(slot0.sqrtPriceX96, sqrtPriceX96, "sqrtPrice");

    }
}