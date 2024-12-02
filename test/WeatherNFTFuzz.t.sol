// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/WeatherNFT.sol";

contract WeatherNFTFuzzTest is Test {
    WeatherNFT public weatherNFT;
    address public owner;

    function setUp() public {
        owner = address(this);
        weatherNFT = new WeatherNFT("Weather NFT", "WNFT");
    }

    function testFuzz_SafeMint(address to, string calldata uri) public {
        // Skip invalid addresses
        vm.assume(to != address(0));
        vm.assume(to != address(weatherNFT));
        vm.assume(to.code.length == 0);

        uint256 tokenId = weatherNFT.safeMint(to, uri);

        assertEq(weatherNFT.ownerOf(tokenId), to);
        assertEq(weatherNFT.tokenURI(tokenId), uri);
    }

    function testFuzz_UpdateWeatherData(
        int256 temperature,
        uint256 humidity,
        uint256 windSpeed,
        string calldata weatherType
    ) public {
        address recipient = makeAddr("recipient");
        uint256 tokenId = weatherNFT.safeMint(recipient, "uri");

        // Bound the inputs to realistic values
        temperature = bound(temperature, -100 * 1e18, 100 * 1e18); // -100°C to 100°C
        humidity = bound(humidity, 0, 100 * 1e18); // 0-100%
        windSpeed = bound(windSpeed, 0, 500 * 1e18); // 0-500 m/s

        weatherNFT.updateWeatherData(tokenId, temperature, humidity, windSpeed, weatherType);

        IWeatherNFT.WeatherData memory data = weatherNFT.getWeatherData(tokenId);
        assertEq(data.temperature, temperature);
        assertEq(data.humidity, humidity);
        assertEq(data.windSpeed, windSpeed);
        assertEq(data.weatherType, weatherType);
    }

    function testFuzz_Transfer(address to) public {
        // Skip invalid addresses
        vm.assume(to != address(0));
        vm.assume(to != address(weatherNFT));
        vm.assume(to.code.length == 0);

        address recipient = makeAddr("recipient");
        uint256 tokenId = weatherNFT.safeMint(recipient, "uri");

        vm.prank(recipient);
        weatherNFT.transferFrom(recipient, to, tokenId);

        assertEq(weatherNFT.ownerOf(tokenId), to);
    }
}
