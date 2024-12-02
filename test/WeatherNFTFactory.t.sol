// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import "forge-std/Test.sol";
import "../src/WeatherNFTFactory.sol";
import "../src/WeatherNFT.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WeatherNFTFactoryTest is Test {
    using Strings for uint256;

    WeatherNFTFactory public factory;
    address public owner;
    address public user1;
    address public user2;

    event WeatherNFTDeployed(
        address indexed nftAddress, string name, string symbol, address indexed owner, uint256 timestamp
    );

    function setUp() public {
        owner = address(this);
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");

        // Deploy factory
        factory = new WeatherNFTFactory();

        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
    }

    function test_InitialState() public view {
        assertEq(factory.owner(), owner);
        assertEq(factory.getDeployedNFTs().length, 0);
    }

    function test_DeployMultipleNFTs() public {
        address[] memory nfts = new address[](3);

        for (uint256 i = 0; i < 3; i++) {
            string memory name = string(abi.encodePacked("Weather NFT ", i.toString()));
            string memory symbol = string(abi.encodePacked("WNFT", i.toString()));

            nfts[i] = factory.deployWeatherNFT(name, symbol);
        }

        // Verify all deployments
        address[] memory deployedNFTs = factory.getDeployedNFTs();
        assertEq(deployedNFTs.length, 3);

        for (uint256 i = 0; i < 3; i++) {
            assertTrue(factory.isWeatherNFT(nfts[i]));
            assertEq(deployedNFTs[i], nfts[i]);
        }
    }

    function test_RevertOnInvalidParams() public {
        vm.expectRevert(IWeatherNFTFactory.InvalidParameters.selector);
        factory.deployWeatherNFT("", "WNFT");

        vm.expectRevert(IWeatherNFTFactory.InvalidParameters.selector);
        factory.deployWeatherNFT("Weather NFT", "");
    }

    function testFuzz_DeployWithRandomNames(string calldata name, string calldata symbol) public {
        // Skip empty strings
        vm.assume(bytes(name).length > 0);
        vm.assume(bytes(symbol).length > 0);

        address nftAddress = factory.deployWeatherNFT(name, symbol);

        WeatherNFT nft = WeatherNFT(nftAddress);
        assertEq(nft.name(), name);
        assertEq(nft.symbol(), symbol);
    }

    function test_PredictDeploymentAddress() public {
        string memory name = "Weather NFT";
        string memory symbol = "WNFT";

        address predicted = factory.predictDeploymentAddress(name, symbol, address(this));
        address deployed = factory.deployWeatherNFT(name, symbol);

        assertEq(deployed, predicted);
    }

    function test_FactoryOwnership() public {
        // Transfer factory ownership
        factory.transferOwnership(user1);
        
        assertEq(factory.owner(), user1);
        
        // Ensure the new owner can still deploy NFTs
        vm.prank(user1);
        address nft = factory.deployWeatherNFT("Weather NFT", "WNFT");
        assertTrue(factory.isWeatherNFT(nft));
    }

    function test_GasUsage() public {
        uint256 gasBefore = gasleft();
        factory.deployWeatherNFT("Weather NFT", "WNFT");
        uint256 gasUsed = gasBefore - gasleft();

        emit log_named_uint("Gas used for NFT deployment", gasUsed);
    }
}
