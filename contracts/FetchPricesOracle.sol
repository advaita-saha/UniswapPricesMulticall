//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6; 
pragma abicoder v2;

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/libraries/OracleLibrary.sol";

/**
 * @title FetchPricesFromUniswapOracle
 * @dev This contract is used to fetch prices from Uniswap Oracle
 * also has the multicall functionality
 * @author Advaita Saha
 */
contract FetchPricesFromUniswapOracle {

    address[] public assets;        // list of assets
    address[] public assetPools;    // list of asset pools

    address public UniswapFactory   = 0x1F98431c8aD98523631AE4a59f267346ea31F984;   // Deafault Uniswap Factory
    address public baseToken        = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;   // WETH - Default base token
    uint24  public fee               = 3000;                                         // Default fee

    /**
     * @dev Constructor, sets the base token and fee
     * @param _baseToken address of the base token
     * @param _fee fee of the pool
     */
    constructor(address _baseToken, uint24 _fee) {
        baseToken = _baseToken; // update the base token
        fee = _fee;             // update the fee
    }

    /**
     * @dev Returns the list of assets
     * @return address[] memory list of assets
     */
    function getAssets() external view returns (address[] memory) {
        return assets;
    }

    /**
     * @dev Add a token to the index
     * Fetches the uniswap liquidity pool address for 
     * the token and base token, reverts if the pool doesn't exist
     * @param _token address of the token to be added
     */
    function addTokenToIndex(address _token) external {
        address tokenpool = IUniswapV3Factory(UniswapFactory).getPool(
            _token,
            baseToken,
            fee
        );
        require(tokenpool != address(0), "pool doesn't exist");
        assets.push(_token);
        assetPools.push(tokenpool);
    }

    /**
     * @dev Returns the price of a single token at a particular index
     * @param _tokenIndex index of the token
     * @return uint price of the token
     */
    function getQuoteOfToken(uint _tokenIndex) external view returns (uint) {
        (int24 tick, ) = OracleLibrary.consult(assetPools[_tokenIndex], 10);
        uint amountOut = OracleLibrary.getQuoteAtTick(
            tick,
            1 ether,
            assets[_tokenIndex],
            baseToken
        );
        return amountOut;
    }

    /**
     * @dev Generates the calldata for a single token price at a particular index
     * @param _tokenIndex index of the token
     * @return bytes calldata for the token price function
     */
    function getCallData(uint _tokenIndex) internal pure returns (bytes memory) {
        return abi.encodeWithSelector(this.getQuoteOfToken.selector, _tokenIndex);
    }

    /**
     * @dev Executes multiple static calls in a single transaction
     * @param targets array of addresses to call
     * @param data array of calldata for each call
     * @return bytes[] array of results
     */
    function multiCall(
        address[] memory targets,
        bytes[] memory data
    ) internal view returns (bytes[] memory) {
        require(targets.length == data.length, "target length != data length");

        bytes[] memory results = new bytes[](data.length);

        for (uint i; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "call failed");
            results[i] = result;
        }

        return results;
    }

    /**
     * @dev Returns the price of all the tokens in the index
     * leverages the multicall function
     * @return bytes[] array of results
     */
    function getAllPrices() external view returns (bytes[] memory) {
        address[] memory targets = new address[](assets.length);
        bytes[] memory data = new bytes[](assets.length);

        for (uint i; i < assets.length; i++) {
            targets[i] = address(this);
            data[i] = getCallData(i);
        }

        return multiCall(targets, data);
    }
}