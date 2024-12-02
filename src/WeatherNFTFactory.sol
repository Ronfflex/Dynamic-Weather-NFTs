// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { WeatherNFT } from "./WeatherNFT.sol";
import { IWeatherNFTFactory } from "./Interface/IWeatherNFTFactory.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Create2 } from "@openzeppelin/contracts/utils/Create2.sol";

/**
 * @title WeatherNFTFactory
 * @dev Implementation of a factory contract to deploy WeatherNFT contracts
 */
contract WeatherNFTFactory is IWeatherNFTFactory, Ownable {
    address[] private _deployedNFTs;
    mapping(address => bool) private _isWeatherNFT;

    constructor() Ownable(msg.sender) { }

    /**
     * @inheritdoc IWeatherNFTFactory
     */
    function deployWeatherNFT(string memory name, string memory symbol) external returns (address nft) {
        // Input validation
        if (bytes(name).length == 0 || bytes(symbol).length == 0) {
            revert InvalidParameters();
        }

        // Create deterministic salt based on name, symbol and sender
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, msg.sender, block.timestamp));

        // Combine creation code with constructor parameters
        bytes memory bytecode = abi.encodePacked(type(WeatherNFT).creationCode, abi.encode(name, symbol));

        // Deploy new WeatherNFT contract
        nft = Create2.deploy(0, salt, bytecode);
        if (nft == address(0)) revert DeploymentFailed();

        // Register the new NFT
        _deployedNFTs.push(nft);
        _isWeatherNFT[nft] = true;

        // Transfer ownership to the caller
        WeatherNFT(nft).transferOwnership(msg.sender);

        emit WeatherNFTDeployed(nft, name, symbol, msg.sender, block.timestamp);
    }

    /**
     * @inheritdoc IWeatherNFTFactory
     */
    function getDeployedNFTs() external view returns (address[] memory) {
        return _deployedNFTs;
    }

    /**
     * @inheritdoc IWeatherNFTFactory
     */
    function isWeatherNFT(address nftAddress) external view returns (bool) {
        return _isWeatherNFT[nftAddress];
    }

    /**
     * @dev Predicts the address where a WeatherNFT will be deployed
     * @param name The name of the NFT collection
     * @param symbol The symbol of the NFT collection
     * @param deployer The address that will deploy the NFT
     * @return The predicted address of the WeatherNFT
     */
    function predictDeploymentAddress(string memory name, string memory symbol, address deployer)
        public
        view
        returns (address)
    {
        bytes32 salt = keccak256(abi.encodePacked(name, symbol, deployer, block.timestamp));
        bytes memory bytecode = abi.encodePacked(type(WeatherNFT).creationCode, abi.encode(name, symbol));
        return Create2.computeAddress(salt, keccak256(bytecode));
    }
}
