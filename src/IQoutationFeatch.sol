// IQoutationFeatch.sol

interface IQoutationFeatch {

    /// @notice Fetches the latest price for a given token pair using an oracle.
    /// @param tokenA Address of the first token in the pair.
    /// @param tokenB Address of the second token in the pair.
    /// @return The price of tokenA in terms of tokenB (e.g., 1 ETH = 2000 DAI).
    function getPrice(address tokenA, address tokenB) external view returns (uint256);
}
