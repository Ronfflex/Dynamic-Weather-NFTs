// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IWeatherNFT } from "./Interface/IWeatherNFT.sol";

/**
 * @title WeatherNFT
 * @dev Implementation of a dynamic NFT that represents weather conditions
 */
abstract contract WeatherNFT is ERC721URIStorage, Ownable2Step, IWeatherNFT {
    using Strings for uint256;

    // State variables
    uint256 private _nextTokenId;
    uint256 public constant MAX_SUPPLY = 10000;

    // Mapping from token ID to weather data
    mapping(uint256 => WeatherData) private _weatherData;

    constructor() ERC721("WeatherNFT", "WNFT") { }

    /**
     * @dev Mints a new weather NFT
     * @param to The address that will own the minted NFT
     * @param uri The token URI for the NFT metadata
     * @return tokenId The ID of the newly minted token
     */
    function safeMint(address to, string memory uri) public onlyOwner returns (uint256 tokenId) {
        if (_nextTokenId >= MAX_SUPPLY) revert MaxSupplyReached();

        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        emit WeatherNFTMinted(to, tokenId, uri);
    }

    /**
     * @dev Updates the weather data for a specific token
     * @param tokenId The ID of the token to update
     * @param temperature The new temperature value
     * @param humidity The new humidity value
     * @param windSpeed The new wind speed value
     * @param weatherType The new weather type
     */
    function updateWeatherData(
        uint256 tokenId,
        int256 temperature,
        uint256 humidity,
        uint256 windSpeed,
        string memory weatherType
    ) public onlyOwner {
        if (!_exists(tokenId)) revert InvalidTokenId();

        _weatherData[tokenId] = WeatherData({
            temperature: temperature,
            humidity: humidity,
            windSpeed: windSpeed,
            weatherType: weatherType,
            lastUpdated: block.timestamp
        });

        emit WeatherDataUpdated(tokenId, temperature, humidity, windSpeed);
    }

    /**
     * @dev Retrieves the weather data for a specific token
     * @param tokenId The ID of the token
     * @return WeatherData struct containing the weather information
     */
    function getWeatherData(uint256 tokenId) public view returns (WeatherData memory) {
        if (!_exists(tokenId)) revert InvalidTokenId();
        return _weatherData[tokenId];
    }

    /**
     * @dev Checks if a token exists
     * @param tokenId The ID of the token to check
     * @return bool indicating if the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        return tokenId < _nextTokenId && tokenId < MAX_SUPPLY;
    }

    /**
     * @dev Override for token URI generation (optional - can be customized based on needs)
     * @param tokenId The ID of the token
     * @return string The token URI
     */
    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage, IWeatherNFT) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
