// QoutationFeatch.sol

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function getAnswer(uint256 roundId) external view returns (int256);
    function latestRoundData() external view returns (uint256, int256, uint256, uint256, uint8);
}

contract QoutationFeatch is IQoutationFeatch {

    // Chainlink Aggregator interface for price feeds (replace with actual address)
    address public oracleAddress;

    constructor(address _oracleAddress) {
        oracleAddress = _oracleAddress;
    }

    function getPrice(address tokenA, address tokenB) external view override returns (uint256) {
        // Fetch price data from the Chainlink oracle for the specific token pair
        AggregatorV3Interface priceFeed = AggregatorV3Interface(oracleAddress);
        (, int256 answer, , , ) = priceFeed.latestRoundData();

        // Handle potential errors (e.g., oracle unavailable, invalid tokens)
        require(answer > 0, "Invalid price data from oracle");

        // Convert the price to a uint256 with appropriate decimal handling
        uint256 price = uint256(answer) * 10**(18 - priceFeed.decimals());

        return price;
    }
}
