// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { WeatherOracle } from "../src/WeatherOracle.sol";
import { WeatherNFT } from "../src/WeatherNFT.sol";

contract DeployOracle is Script {
    function run() external {
        // Get configuration from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address nftAddress = vm.envAddress("NFT_ADDRESS");
        address weatherProvider = vm.envAddress("WEATHER_PROVIDER_ADDRESS");

        // Log pre-deployment information
        console2.log("Deployment Configuration:");
        console2.log("------------------------");
        console2.log("NFT Address:", nftAddress);
        console2.log("Weather Provider:", weatherProvider);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Oracle
        WeatherOracle oracle = new WeatherOracle(
            nftAddress,
            weatherProvider,
            1 hours // Update interval
        );
        console2.log("WeatherOracle deployed at:", address(oracle));

        // Try to transfer ownership
        try WeatherNFT(nftAddress).transferOwnership(address(oracle)) {
            console2.log("Successfully transferred NFT ownership to Oracle");
        } catch Error(string memory reason) {
            console2.log("Failed to transfer ownership:", reason);
        }

        vm.stopBroadcast();
    }
}
