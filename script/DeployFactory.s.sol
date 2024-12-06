// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { WeatherNFTFactory } from "../src/WeatherNFTFactory.sol";

contract DeployFactory is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);

        WeatherNFTFactory factory = new WeatherNFTFactory();
        console2.log("WeatherNFTFactory deployed at:", address(factory));

        vm.stopBroadcast();
    }
}
