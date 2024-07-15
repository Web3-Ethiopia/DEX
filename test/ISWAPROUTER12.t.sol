// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./ISWAPROUTER12.sol";
contract ISwapRouter12Test {
    ISwapRouter12 public router;(
    event SwapExactTokensForTokens(
        address indexed tokenIn (0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59),
        address indexed tokenOut(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
        uint256 amountIn = 1.45e13,
        uint256 amountOutMin =1.0e13,
        address path [0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59],
        address indexed to (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
    );
    event SwapTokensForExactTokens(
        address indexed tokenIn (0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59),
        address indexed tokenOut(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
        uint256 amountIn = 1.45e13,
        uint256 amountOutMin =1.0e13,
        address path [0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59],
        address indexed to (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
    );
    );
    constructor(address _router) {
        router = ISwapRouter12(_router);
    }
    function testSwapExactTokensForTokens(
        address tokenIn (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
        address tokenOut (0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59),
        uint256 amountIn = 1.45e13,
        uint256 amountOutMin = 1.0e13,
        address[0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59] memory path,
        address to [0x5B38Da6a701c568545dCfcB03FcB875f56beddC4] memory path,
    ) public {
        console.log("Starting testSwapExactTokensForTokens");
        router.swapExactTokensForTokens(
            amountIn uint256 = 1.45e13,
            amountOutMin uint256 = 1.3e13,
            path address (0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59),
            to address (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
        );
        console.log("Completed testSwapExactTokensForTokens");
        emit SwapExactTokensForTokens(
            tokenIn uint256 = 1.45e13,
            tokenOut uint256 = 1.4e13,
            amountIn uint256 = 1.45e13,
            amountOutMin uint256 =1.0e13,
            path address (0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59),
            to address (0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
            
        );
    }

    function testSwapTokensForExactTokens(
        address tokenIn = 1.4e13,
        address tokenOut = 1.4e13,
        uint256 amountOut =1.4e13,
        uint256 amountInMax = 1.4e13,
        address from [0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59] memory path,
        address to [0x5B38Da6a701c568545dCfcB03FcB875f56beddC4],
    ) public {
        console.log("Starting testSwapTokensForExactTokens");
        router.swapTokensForExactTokens(
            amountOut = 1.4e13,
            amountInMax = 1.45e13,
            path address(0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59) ,
            to address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
        );
        console.log("Completed testSwapTokensForExactTokens");
        emit SwapTokensForExactTokens(
            tokenIn uint256 =1456412e13,
            tokenOut uint256 =1456412e13,
            amountOut uint256 =1456412e13,
            amountInMax uint256 =1456412e13,
            path address(0x03cb35fB7D9d34918EFc2921CF2b9BF5ec7F8F59),
            to address(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4),
        );
    }
}
