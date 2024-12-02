// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/WeatherNFT.sol";

contract WeatherNFTTest is Test {
    WeatherNFT public weatherNFT;
    address public owner;
    address public user1;
    address public user2;
    string public constant NAME = "Weather NFT";
    string public constant SYMBOL = "WNFT";
    string public constant BASE_URI = "ipfs://QmWeatherNFT/";

    event WeatherNFTMinted(address indexed to, uint256 indexed tokenId, string uri);
    event WeatherDataUpdated(uint256 indexed tokenId, int256 temperature, uint256 humidity, uint256 windSpeed);

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        weatherNFT = new WeatherNFT(NAME, SYMBOL);

        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function test_InitialState() public {
        assertEq(weatherNFT.name(), NAME);
        assertEq(weatherNFT.symbol(), SYMBOL);
        assertEq(weatherNFT.owner(), owner);
        assertEq(weatherNFT.MAX_SUPPLY(), 10000);
    }

    function test_SafeMint() public {
        string memory uri = "tokenURI/1";

        vm.expectEmit(true, true, false, true);
        emit WeatherNFTMinted(user1, 0, uri);

        uint256 tokenId = weatherNFT.safeMint(user1, uri);

        assertEq(weatherNFT.ownerOf(tokenId), user1);
        assertEq(weatherNFT.tokenURI(tokenId), uri);
        assertEq(weatherNFT.balanceOf(user1), 1);
    }

    function testFail_SafeMintUnauthorized() public {
        vm.prank(user1);
        weatherNFT.safeMint(user1, "uri");
    }

    function test_RevertWhenMaxSupplyReached() public {
        uint256 maxSupply = weatherNFT.MAX_SUPPLY();

        for (uint256 i = 0; i < maxSupply; i++) {
            weatherNFT.safeMint(user1, "uri");
        }

        vm.expectRevert(IWeatherNFT.MaxSupplyReached.selector);
        weatherNFT.safeMint(user1, "uri");
    }

    function test_UpdateWeatherData() public {
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        int256 temperature = 25 * 1e18;
        uint256 humidity = 60 * 1e18;
        uint256 windSpeed = 10 * 1e18;
        string memory weatherType = "Sunny";

        vm.expectEmit(true, false, false, true);
        emit WeatherDataUpdated(tokenId, temperature, humidity, windSpeed);

        weatherNFT.updateWeatherData(tokenId, temperature, humidity, windSpeed, weatherType);

        IWeatherNFT.WeatherData memory data = weatherNFT.getWeatherData(tokenId);
        assertEq(data.temperature, temperature);
        assertEq(data.humidity, humidity);
        assertEq(data.windSpeed, windSpeed);
        assertEq(data.weatherType, weatherType);
        assertEq(data.lastUpdated, block.timestamp);
    }

    function testFail_UpdateWeatherDataUnauthorized() public {
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        vm.prank(user1);
        weatherNFT.updateWeatherData(tokenId, 0, 0, 0, "");
    }

    function test_RevertOnInvalidTokenId() public {
        vm.expectRevert(IWeatherNFT.InvalidTokenId.selector);
        weatherNFT.updateWeatherData(999, 0, 0, 0, "");

        vm.expectRevert(IWeatherNFT.InvalidTokenId.selector);
        weatherNFT.getWeatherData(999);
    }

    function test_TransferNFT() public {
        uint256 tokenId = weatherNFT.safeMint(user1, "uri");

        vm.prank(user1);
        weatherNFT.transferFrom(user1, user2, tokenId);

        assertEq(weatherNFT.ownerOf(tokenId), user2);
        assertEq(weatherNFT.balanceOf(user1), 0);
        assertEq(weatherNFT.balanceOf(user2), 1);
    }

    function test_TransferOwnership() public {
        weatherNFT.transferOwnership(user1);

        vm.prank(user1);
        weatherNFT.acceptOwnership();

        assertEq(weatherNFT.owner(), user1);
    }

    function testFail_TransferOwnershipUnauthorized() public {
        vm.prank(user1);
        weatherNFT.transferOwnership(user2);
    }

    function test_TokenURIForNonexistentToken() public {
        vm.expectRevert(abi.encodeWithSignature("ERC721NonexistentToken(uint256)", 999));
        weatherNFT.tokenURI(999);
    }

    function test_GasUsage() public {
        string memory uri = "tokenURI/1";

        uint256 gasBefore = gasleft();
        weatherNFT.safeMint(user1, uri);
        uint256 gasUsed = gasBefore - gasleft();

        emit log_named_uint("Gas used for minting", gasUsed);

        uint256 tokenId = 0;
        gasBefore = gasleft();
        weatherNFT.updateWeatherData(tokenId, 25 * 1e18, 60 * 1e18, 10 * 1e18, "Sunny");
        gasUsed = gasBefore - gasleft();

        emit log_named_uint("Gas used for updating weather data", gasUsed);
    }
}
