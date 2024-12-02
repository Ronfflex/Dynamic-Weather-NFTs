// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IWeatherNFT {
    // Custom errors
    error InvalidTokenId();
    error TokenAlreadyMinted();
    error MaxSupplyReached();

    // Structs
    struct WeatherData {
        int256 temperature; // Celsius * 10^18
        uint256 humidity; // Percentage * 10^18
        uint256 windSpeed; // m/s * 10^18
        string weatherType; // Clear, Cloudy, Rainy, etc.
        uint256 lastUpdated; // Unix timestamp
    }

    // Events
    event WeatherNFTMinted(address indexed to, uint256 indexed tokenId, string uri);
    event WeatherDataUpdated(uint256 indexed tokenId, int256 temperature, uint256 humidity, uint256 windSpeed);

    /**
     * @dev Mints a new weather NFT
     * @param to The address that will own the minted NFT
     * @param uri The token URI for the NFT metadata
     * @return tokenId The ID of the newly minted token
     */
    function safeMint(address to, string memory uri) external returns (uint256 tokenId);

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
    ) external;

    /**
     * @dev Retrieves the weather data for a specific token
     * @param tokenId The ID of the token
     * @return WeatherData struct containing the weather information
     */
    function getWeatherData(uint256 tokenId) external view returns (WeatherData memory);

    /**
     * @dev Returns the URI for a given token ID
     * @param tokenId The ID of the token
     * @return The token URI string
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Returns the maximum supply of tokens
     * @return The maximum supply value
     */
    function MAX_SUPPLY() external view returns (uint256);
}
