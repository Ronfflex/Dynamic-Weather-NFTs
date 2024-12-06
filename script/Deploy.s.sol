// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { WeatherNFTFactory } from "../src/WeatherNFTFactory.sol";
import { WeatherNFT } from "../src/WeatherNFT.sol";
import { WeatherOracle } from "../src/WeatherOracle.sol";

contract DeployWeather is Script {
    // Configuration parameters
    string constant NFT_NAME = "Weather Collection";
    string constant NFT_SYMBOL = "WEATHER";
    uint256 constant UPDATE_INTERVAL = 1 hours; // Minimum update interval

    // Deployed contract addresses
    WeatherNFTFactory public factory;
    WeatherNFT public weatherNFT;
    WeatherOracle public oracle;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address weatherProvider = vm.envAddress("WEATHER_PROVIDER_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Factory
        factory = new WeatherNFTFactory();
        console2.log("WeatherNFTFactory deployed at:", address(factory));

        // 2. Deploy WeatherNFT through factory
        address nftAddress = factory.deployWeatherNFT(NFT_NAME, NFT_SYMBOL);
        weatherNFT = WeatherNFT(nftAddress);
        console2.log("WeatherNFT deployed at:", address(weatherNFT));

        // 3. Deploy Oracle
        oracle = new WeatherOracle(address(weatherNFT), weatherProvider, UPDATE_INTERVAL);
        console2.log("WeatherOracle deployed at:", address(oracle));

        // 4. Transfer ownership of WeatherNFT to Oracle
        weatherNFT.transferOwnership(address(oracle));
        console2.log("Ownership transferred to Oracle");

        vm.stopBroadcast();

        console2.log("\nDeployment Summary:");
        console2.log("-------------------");
        console2.log("Factory:", address(factory));
        console2.log("WeatherNFT:", address(weatherNFT));
        console2.log("Oracle:", address(oracle));
        console2.log("Weather Provider:", weatherProvider);
        console2.log("Update Interval:", UPDATE_INTERVAL);
    }
}
