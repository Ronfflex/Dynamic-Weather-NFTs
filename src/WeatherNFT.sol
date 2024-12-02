// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { ERC721URIStorage, ERC721 } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { Ownable2Step, Ownable } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { IWeatherNFT } from "./Interface/IWeatherNFT.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title WeatherNFT
 * @dev Implementation of a dynamic NFT that represents weather conditions
 */
contract WeatherNFT is ERC721URIStorage, Ownable2Step, IWeatherNFT {
    using Strings for uint256;

    // State variables
    uint256 private _nextTokenId;
    uint256 public constant MAX_SUPPLY = 10000;

    // Mapping from token ID to weather data
    mapping(uint256 => WeatherData) private _weatherData;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) Ownable(msg.sender) { }

    /**
     * @inheritdoc IWeatherNFT
     */
    function safeMint(address to, string memory uri) public onlyOwner returns (uint256 tokenId) {
        if (_nextTokenId >= MAX_SUPPLY) revert MaxSupplyReached();

        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);

        emit WeatherNFTMinted(to, tokenId, uri);
    }

    /**
     * @inheritdoc IWeatherNFT
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
     * @inheritdoc IWeatherNFT
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
     * @inheritdoc IWeatherNFT
     */
    function tokenURI(uint256 tokenId) public view override(ERC721URIStorage, IWeatherNFT) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
