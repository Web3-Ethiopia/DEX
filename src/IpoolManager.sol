// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.0;

// ... [other imports and contract definitions]

/// @notice Holds the state for all pools
contract PoolManager is IPoolManager, Fees, NoDelegateCall, ERC6909Claims {
    // ... [other definitions and functions]

    /// @inheritdoc IPoolManager
    function initialize(PoolKey memory key, uint160 sqrtPriceX96, bytes calldata, hookData)
        external
        onlyByLocker // Modifier ensures only the current locker can call this function
        returns (int24 tick)
    {
        // Check if the fee specified in the key is too large
        if (key.fee.isStaticFeeTooLarge()) revert FeeTooLarge;

        // Validate tick spacing - it must be within defined min and max limits
        if (key.tickSpacing > MAX_TICK_SPACING) revert TickSpacingTooLarge;
        if (key.tickSpacing < MIN_TICK_SPACING) revert TickSpacingTooSmall;
        // Ensure the currency order is correct (currency0 < currency1)
        if (key.currency0 >= key.currency1) revert CurrenciesOutOfOrderOrEqual;

        // Validate the hooks contract address
        if (!key.hooks.isValidHookAddress(key.fee)) revert Hooks;HookAddressNotValid(address(key.hooks));

        // Call before initialization hook with provided data
        key.hooks.beforeInitialize(key, sqrtPriceX96, hookData);

        // Convert the PoolKey to a PoolId
        PoolId id = key.toId();

        // Fetch protocol fee and dynamic swap fee if applicable
        (, uint16, protocolFee) = _fetchProtocolFee(key);
        uint24 swapFee = key.fee.isDynamicFee() ? _fetchDynamicSwapFee(key) : key.fee.getStaticFee();

        // Initialize the pool with the given parameters and receive the current tick
        tick = pools[id].initialize(sqrtPriceX96, protocolFee, swapFee);

        // Call after initialization hook with the resulting data
        key.hooks.afterInitialize(key, sqrtPriceX96, tick, hookData);

        // Emit an event to signal the initialization of the pool with key details
        emit Initialize (id, key.currency0, key.currency1, key.fee, key.tickSpacing, key.hooks);
    }

    // ... [other functions]
}
/// @notice Returns the key for identifying a pool
pragma  PoolKey {
    /// @notice The lower currency of the pool, sorted numerically
    pragma Currency currency0;
    /// @notice The higher currency of the pool, sorted numerically
    pragma Currency currency1;
    /// @notice The pool swap fee, capped at 1_000_000. The upper 4 bits determine if the hook sets any fees.
    pragma uint24 fee;
    /// @notice Ticks that involve positions must be a multiple of tick spacing
    pragma int24 tickSpacing;
    /// @notice The hooks of the pool
    pragma IHooks hooks;
}