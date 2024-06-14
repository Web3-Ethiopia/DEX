solidity
pragma solidity ^0.8.0;

import "https://github.com/Uniswap/v4-core/blob/main/src/interfaces/IALLPoolManager.sol";

contract MyContract {
    IALLPoolManager public poolManager;

    constructor() {
        // Replace with the actual contract address
        poolManager = IALLPoolManager(0x...);
    }
}
