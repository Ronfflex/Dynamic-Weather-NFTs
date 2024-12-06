// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IWeatherNFT } from "./IWeatherNFT.sol";

interface IWeatherOracle {
    /// Custom errors
    error InvalidUpdateInterval();
    error UpdateTooFrequent();
    error UnauthorizedProvider();
    error InvalidTokenId();

    /// Events
    event WeatherProviderUpdated(address indexed oldProvider, address indexed newProvider);
    event UpdateIntervalChanged(uint256 oldInterval, uint256 newInterval);
    event WeatherDataRequested(uint256 indexed tokenId, address indexed requester);
    event WeatherDataSubmitted(
        uint256 indexed tokenId, int256 temperature, uint256 humidity, uint256 windSpeed, string weatherType
    );

    /**
     * @dev Updates weather data for a specific token
     * @param tokenId The ID of the token to update
     * @param temperature The temperature in Celsius (multiplied by 1e18)
     * @param humidity The humidity percentage (multiplied by 1e18)
     * @param windSpeed The wind speed in m/s (multiplied by 1e18)
     * @param weatherType The weather condition (e.g., "Sunny", "Rainy")
     */
    function submitWeatherData(
        uint256 tokenId,
        int256 temperature,
        uint256 humidity,
        uint256 windSpeed,
        string memory weatherType
    ) external;

    /**
     * @dev Requests a weather update for a specific token
     * @param tokenId The ID of the token to update
     */
    function requestUpdate(uint256 tokenId) external;

    /**
     * @dev Sets the minimum interval between updates
     * @param interval The new minimum interval in seconds
     */
    function setUpdateInterval(uint256 interval) external;

    /**
     * @dev Sets the authorized weather data provider
     * @param provider The address of the new provider
     */
    function setWeatherProvider(address provider) external;

    /**
     * @dev Returns the timestamp of the last update for a token
     * @param tokenId The ID of the token
     */
    function lastUpdateTime(uint256 tokenId) external view returns (uint256);
}
