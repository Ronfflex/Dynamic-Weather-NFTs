// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IWeatherNFT } from "./IWeatherNFT.sol";

interface IWeatherNFTFactory {
    // Custom errors
    error InvalidParameters();
    error DeploymentFailed();
    error UnauthorizedCaller(address caller);

    // Events
    event WeatherNFTDeployed(
        address indexed nftAddress, string name, string symbol, address indexed owner, uint256 timestamp
    );

    /**
     * @dev Deploys a new WeatherNFT contract
     * @param name The name of the NFT collection
     * @param symbol The symbol of the NFT collection
     * @return nft The address of the newly deployed WeatherNFT contract
     */
    function deployWeatherNFT(string memory name, string memory symbol) external returns (address nft);

    /**
     * @dev Returns all WeatherNFTs deployed by this factory
     * @return An array of WeatherNFT contract addresses
     */
    function getDeployedNFTs() external view returns (address[] memory);

    /**
     * @dev Checks if an address is a WeatherNFT deployed by this factory
     * @param nftAddress The address to check
     * @return bool indicating if the address is a deployed WeatherNFT
     */
    function isWeatherNFT(address nftAddress) external view returns (bool);
}
