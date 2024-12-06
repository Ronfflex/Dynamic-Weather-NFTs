// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { WeatherNFTFactory } from "../src/WeatherNFTFactory.sol";

contract DeployNFT is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address factoryAddress = vm.envAddress("FACTORY_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        WeatherNFTFactory factory = WeatherNFTFactory(factoryAddress);
        address nftAddress = factory.deployWeatherNFT("Weather Collection", "WEATHER");
        console2.log("WeatherNFT deployed at:", nftAddress);

        vm.stopBroadcast();
    }
}
