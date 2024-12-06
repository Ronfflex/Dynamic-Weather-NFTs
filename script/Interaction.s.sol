// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { WeatherNFTFactory } from "../src/WeatherNFTFactory.sol";
import { WeatherNFT } from "../src/WeatherNFT.sol";
import { WeatherOracle } from "../src/WeatherOracle.sol";
import { IWeatherNFT } from "../src/Interface/IWeatherNFT.sol";

contract WeatherInteractions is Script {
    WeatherNFTFactory public factory;
    WeatherNFT public weatherNFT;
    WeatherOracle public oracle;

    // Test data
    string constant IPFS_URI = "ipfs://QmWeatherMetadata/";
    int256 constant TEMPERATURE = 25 * 1e18; // 25°C
    uint256 constant HUMIDITY = 65 * 1e18; // 65%
    uint256 constant WIND_SPEED = 10 * 1e18; // 10 m/s
    string constant WEATHER_TYPE = "Sunny";

    function setUp() public {
        string memory factoryAddr = vm.envString("FACTORY_ADDRESS");
        string memory nftAddr = vm.envString("NFT_ADDRESS");
        string memory oracleAddr = vm.envString("ORACLE_ADDRESS");

        // Initialize contract instances
        factory = WeatherNFTFactory(payable(vm.parseAddress(factoryAddr)));
        weatherNFT = WeatherNFT(payable(vm.parseAddress(nftAddr)));
        oracle = WeatherOracle(payable(vm.parseAddress(oracleAddr)));
    }

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);

        console2.log("\n=== Factory Interactions ===");
        factoryInteractions();

        console2.log("\n=== NFT Interactions ===");
        nftInteractions();

        console2.log("\n=== Oracle Interactions ===");
        oracleInteractions();

        vm.stopBroadcast();
    }

    function factoryInteractions() internal view {
        // Get all deployed NFTs
        address[] memory deployedNFTs = factory.getDeployedNFTs();
        console2.log("Number of deployed NFTs:", deployedNFTs.length);

        // Check if address is a WeatherNFT
        for (uint256 i = 0; i < deployedNFTs.length; i++) {
            bool isWeatherNFT = factory.isWeatherNFT(deployedNFTs[i]);
            console2.log("Address", deployedNFTs[i], "is WeatherNFT:", isWeatherNFT);
        }

        // Predict deployment address
        address predictedAddr = factory.predictDeploymentAddress("New Weather NFT", "NWTH", address(this));
        console2.log("Predicted deployment address:", predictedAddr);
    }

    function nftInteractions() internal {
        // Mint new NFT
        uint256 tokenId = weatherNFT.safeMint(msg.sender, IPFS_URI);
        console2.log("Minted NFT with ID:", tokenId);

        // Get token URI
        string memory uri = weatherNFT.tokenURI(tokenId);
        console2.log("Token URI:", uri);

        // Get weather data
        IWeatherNFT.WeatherData memory data = weatherNFT.getWeatherData(tokenId);
        logWeatherData(tokenId, data);

        // Get balance
        uint256 balance = weatherNFT.balanceOf(msg.sender);
        console2.log("Owner balance:", balance);

        // Get owner
        address owner = weatherNFT.ownerOf(tokenId);
        console2.log("Token owner:", owner);

        // Get max supply
        uint256 maxSupply = weatherNFT.MAX_SUPPLY();
        console2.log("Maximum supply:", maxSupply);
    }

    function oracleInteractions() internal {
        // Get oracle configuration
        address provider = oracle.weatherProvider();
        uint256 interval = oracle.updateInterval();
        console2.log("Weather provider:", provider);
        console2.log("Update interval:", interval);

        // Request weather update
        oracle.requestUpdate(0); // For token ID 0
        console2.log("Update requested for token 0");

        // Get last update time
        uint256 lastUpdate = oracle.lastUpdateTime(0);
        console2.log("Last update time:", lastUpdate);

        // Submit weather data (if we're the provider)
        if (msg.sender == provider) {
            oracle.submitWeatherData(
                0, // tokenId
                TEMPERATURE,
                HUMIDITY,
                WIND_SPEED,
                WEATHER_TYPE
            );
            console2.log("Weather data submitted for token 0");
        }

        // Check minimum and maximum intervals
        uint256 minInterval = oracle.MIN_INTERVAL();
        uint256 maxInterval = oracle.MAX_INTERVAL();
        console2.log("Minimum interval:", minInterval);
        console2.log("Maximum interval:", maxInterval);
    }

    // Helper function to log weather data
    function logWeatherData(uint256 tokenId, IWeatherNFT.WeatherData memory data) internal pure {
        console2.log("Weather data for token", tokenId);
        //console2.log("Temperature:", data.temperature / 1e18, "C"); // Error (9582): Member "log" not found or not visible after argument-dependent lookup in type(library console). Only for him specifically ????
        console2.log("Humidity:", data.humidity / 1e18, "%");
        console2.log("Wind Speed:", data.windSpeed / 1e18, "m/s");
        console2.log("Weather Type:", data.weatherType);
        console2.log("Last Updated:", data.lastUpdated);
    }
}
