// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/WeatherOracle.sol";
import "../src/WeatherNFT.sol";

contract WeatherOracleTest is Test {
    WeatherOracle public oracle;
    WeatherNFT public weatherNFT;
    address public owner;
    address public provider;
    address public user1;
    uint256 public constant UPDATE_INTERVAL = 1 hours;

    event WeatherProviderUpdated(address indexed oldProvider, address indexed newProvider);
    event UpdateIntervalChanged(uint256 oldInterval, uint256 newInterval);
    event WeatherDataRequested(uint256 indexed tokenId, address indexed requester);
    event WeatherDataSubmitted(
        uint256 indexed tokenId, int256 temperature, uint256 humidity, uint256 windSpeed, string weatherType
    );

    function setUp() public {
        owner = address(this);
        provider = makeAddr("provider");
        user1 = makeAddr("user1");

        weatherNFT = new WeatherNFT("Weather NFT", "WNFT");
        oracle = new WeatherOracle(address(weatherNFT), provider, UPDATE_INTERVAL);
        // Make sure we're the owner before transferring
        assertEq(weatherNFT.owner(), owner);
        // Transfer ownership of WeatherNFT to Oracle
        weatherNFT.transferOwnership(address(oracle));
        // Verify transfer
        assertEq(weatherNFT.owner(), address(oracle));
    }

    function test_InitialState() public {
        assertEq(address(oracle.weatherNFT()), address(weatherNFT));
        assertEq(oracle.weatherProvider(), provider);
        assertEq(oracle.updateInterval(), UPDATE_INTERVAL);
        assertEq(oracle.owner(), owner);
    }

    function test_SubmitWeatherData() public {
        vm.prank(address(oracle));
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        int256 temperature = 25 * 1e18;
        uint256 humidity = 60 * 1e18;
        uint256 windSpeed = 10 * 1e18;
        string memory weatherType = "Sunny";

        vm.warp(block.timestamp + UPDATE_INTERVAL + 1);

        vm.expectEmit(true, true, false, true);
        emit WeatherDataSubmitted(tokenId, temperature, humidity, windSpeed, weatherType);

        vm.prank(provider);
        oracle.submitWeatherData(tokenId, temperature, humidity, windSpeed, weatherType);

        IWeatherNFT.WeatherData memory data = weatherNFT.getWeatherData(tokenId);
        assertEq(data.temperature, temperature);
        assertEq(data.humidity, humidity);
        assertEq(data.windSpeed, windSpeed);
        assertEq(data.weatherType, weatherType);
    }

    function test_RevertUpdateTooFrequent() public {
        vm.prank(address(oracle));
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        console.log("Initial timestamp:", block.timestamp);
        console.log("Update interval:", UPDATE_INTERVAL);

        // Move to first valid update time
        uint256 firstTimestamp = block.timestamp + UPDATE_INTERVAL + 1;
        vm.warp(firstTimestamp);
        console.log("After first warp timestamp:", block.timestamp);

        // First update
        vm.prank(provider);
        oracle.submitWeatherData(tokenId, 0, 0, 0, "");
        console.log("Last update time after first update:", oracle.lastUpdateTime(tokenId));

        // Try to update too soon - should fail
        vm.prank(provider);
        vm.expectRevert(IWeatherOracle.UpdateTooFrequent.selector);
        oracle.submitWeatherData(tokenId, 0, 0, 0, "");

        // Move time forward by another interval
        uint256 secondTimestamp = firstTimestamp + UPDATE_INTERVAL + 1;
        vm.warp(secondTimestamp);
        console.log("After second warp timestamp:", block.timestamp);
        console.log("Last update time before final update:", oracle.lastUpdateTime(tokenId));

        vm.prank(provider);
        oracle.submitWeatherData(tokenId, 0, 0, 0, "");
    }

    function test_RevertUnauthorizedProvider() public {
        vm.prank(address(oracle));
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        vm.warp(block.timestamp + UPDATE_INTERVAL + 1); // Add time buffer

        vm.prank(user1);
        vm.expectRevert(IWeatherOracle.UnauthorizedProvider.selector);
        oracle.submitWeatherData(tokenId, 0, 0, 0, "");
    }

    function test_RequestUpdate() public {
        vm.prank(address(oracle));
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        // No need to be owner to request updates
        vm.expectEmit(true, true, false, true);
        emit WeatherDataRequested(tokenId, user1);

        vm.prank(user1);
        oracle.requestUpdate(tokenId);
    }

    function test_RevertRequestInvalidToken() public {
        vm.expectRevert();
        oracle.requestUpdate(999);
    }

    function test_SetUpdateInterval() public {
        uint256 newInterval = 2 hours;

        vm.expectEmit(true, true, false, true);
        emit UpdateIntervalChanged(UPDATE_INTERVAL, newInterval);

        oracle.setUpdateInterval(newInterval);
        assertEq(oracle.updateInterval(), newInterval);
    }

    function test_RevertInvalidInterval() public {
        vm.expectRevert(IWeatherOracle.InvalidUpdateInterval.selector);
        oracle.setUpdateInterval(30 minutes);

        vm.expectRevert(IWeatherOracle.InvalidUpdateInterval.selector);
        oracle.setUpdateInterval(25 hours);
    }

    function test_SetWeatherProvider() public {
        address newProvider = makeAddr("newProvider");

        vm.expectEmit(true, true, false, true);
        emit WeatherProviderUpdated(provider, newProvider);

        oracle.setWeatherProvider(newProvider);
        assertEq(oracle.weatherProvider(), newProvider);
    }

    function test_RevertSetZeroAddressProvider() public {
        vm.expectRevert(IWeatherOracle.UnauthorizedProvider.selector);
        oracle.setWeatherProvider(address(0));
    }

    function test_LastUpdateTime() public {
        vm.prank(address(oracle));
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        assertEq(oracle.lastUpdateTime(tokenId), 0);

        vm.warp(block.timestamp + UPDATE_INTERVAL + 1);

        vm.prank(provider);
        oracle.submitWeatherData(tokenId, 0, 0, 0, "");

        assertEq(oracle.lastUpdateTime(tokenId), block.timestamp);
    }

    function test_OracleOwnership() public {
        oracle.transferOwnership(user1);
        assertEq(oracle.owner(), user1);

        // Test that only new owner can set provider
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", address(this)));
        oracle.setWeatherProvider(address(0x123));

        vm.prank(user1);
        oracle.setWeatherProvider(address(0x123));
    }

    function testFuzz_SetUpdateInterval(uint256 interval) public {
        interval = bound(interval, oracle.MIN_INTERVAL(), oracle.MAX_INTERVAL());

        oracle.setUpdateInterval(interval);
        assertEq(oracle.updateInterval(), interval);
    }

    function test_GasUsage() public {
        vm.prank(address(oracle));
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        vm.warp(block.timestamp + UPDATE_INTERVAL + 1);

        uint256 gasBefore = gasleft();
        vm.prank(provider);
        oracle.submitWeatherData(tokenId, 25 * 1e18, 60 * 1e18, 10 * 1e18, "Sunny");
        uint256 gasUsed = gasBefore - gasleft();

        emit log_named_uint("Gas used for weather update", gasUsed);
    }
}
