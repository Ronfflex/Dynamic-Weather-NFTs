// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { IWeatherOracle } from "./Interface/IWeatherOracle.sol";
import { IWeatherNFT } from "./Interface/IWeatherNFT.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title WeatherOracle
 * @dev Oracle system for updating weather data in WeatherNFTs
 */
contract WeatherOracle is IWeatherOracle, Ownable {
    // State variables
    IWeatherNFT public immutable weatherNFT;
    address public weatherProvider;
    uint256 public updateInterval;

    // Mapping to track last update times
    mapping(uint256 => uint256) private _lastUpdateTime;

    // Constants
    uint256 public constant MIN_INTERVAL = 1 hours;
    uint256 public constant MAX_INTERVAL = 24 hours;

    /**
     * @dev Constructor
     * @param _weatherNFT Address of the WeatherNFT contract
     * @param _provider Initial weather data provider
     * @param _interval Initial update interval
     */
    constructor(address _weatherNFT, address _provider, uint256 _interval) Ownable(msg.sender) {
        if (_interval < MIN_INTERVAL || _interval > MAX_INTERVAL) {
            revert InvalidUpdateInterval();
        }
        if (_provider == address(0)) {
            revert UnauthorizedProvider();
        }

        weatherNFT = IWeatherNFT(_weatherNFT);
        weatherProvider = _provider;
        updateInterval = _interval;
    }

    /**
     * @inheritdoc IWeatherOracle
     */
    function submitWeatherData(
        uint256 tokenId,
        int256 temperature,
        uint256 humidity,
        uint256 windSpeed,
        string memory weatherType
    ) external {
        // Check provider authorization
        if (msg.sender != weatherProvider) {
            revert UnauthorizedProvider();
        }

        // Check update interval
        if (block.timestamp - _lastUpdateTime[tokenId] < updateInterval) {
            revert UpdateTooFrequent();
        }

        // Update weather data
        weatherNFT.updateWeatherData(tokenId, temperature, humidity, windSpeed, weatherType);

        // Update last update time
        _lastUpdateTime[tokenId] = block.timestamp;

        emit WeatherDataSubmitted(tokenId, temperature, humidity, windSpeed, weatherType);
    }

    /**
     * @inheritdoc IWeatherOracle
     */
    function requestUpdate(uint256 tokenId) external {
        // Verify token exists by trying to get its data
        weatherNFT.getWeatherData(tokenId);

        emit WeatherDataRequested(tokenId, msg.sender);
    }

    /**
     * @inheritdoc IWeatherOracle
     */
    function setUpdateInterval(uint256 interval) external onlyOwner {
        if (interval < MIN_INTERVAL || interval > MAX_INTERVAL) {
            revert InvalidUpdateInterval();
        }

        uint256 oldInterval = updateInterval;
        updateInterval = interval;

        emit UpdateIntervalChanged(oldInterval, interval);
    }

    /**
     * @inheritdoc IWeatherOracle
     */
    function setWeatherProvider(address provider) external onlyOwner {
        if (provider == address(0)) {
            revert UnauthorizedProvider();
        }

        address oldProvider = weatherProvider;
        weatherProvider = provider;

        emit WeatherProviderUpdated(oldProvider, provider);
    }

    /**
     * @inheritdoc IWeatherOracle
     */
    function lastUpdateTime(uint256 tokenId) external view returns (uint256) {
        return _lastUpdateTime[tokenId];
    }
}
