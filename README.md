# Dynamic Weather NFT System 🌤️

A blockchain-based system for creating and managing dynamic NFTs that represent real-time weather conditions. The NFTs automatically update their metadata based on weather data provided through a decentralized oracle system.

## 📋 Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Getting Started](#getting-started)
- [Deployment Guide](#deployment-guide)
- [Contract Interaction](#contract-interaction)
- [Testing](#testing)
- [Test Coverage](#test-coverage)

## ✨ Features

- Dynamic NFTs that update based on weather conditions
- Decentralized oracle system for weather data
- Factory pattern for easy NFT collection deployment
- Comprehensive testing suite
- Gas-optimized contract implementations
- Role-based access control
- Automated metadata updates

## 🏗️ Architecture

The system consists of three main components:

1. **WeatherNFTFactory**: Factory contract for deploying new WeatherNFT collections
   - Handles creation and tracking of WeatherNFT instances
   - Uses CREATE2 for deterministic addresses
   - Maintains registry of deployed contracts

2. **WeatherNFT**: ERC721 contract with dynamic metadata
   - Implements ERC721URIStorage for metadata management
   - Stores weather data on-chain
   - Updates metadata based on oracle input
   - Enforces access control for updates

3. **WeatherOracle**: Oracle system for weather data
   - Manages authorized data providers
   - Enforces update intervals
   - Validates and processes weather data
   - Triggers NFT metadata updates

## 🛠️ Tech Stack

- **Smart Contract Development**:
  - Solidity ^0.8.28
  - OpenZeppelin Contracts 5.x.x
  
- **Development Framework**:
  - Foundry
  - Forge (testing)
  - Cast (contract interaction)
  - Anvil (local network)

- **Testing**:
  - Forge Test Suite
  - Fuzz Testing
  - Gas Usage Analysis
  
## 🚀 Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/dynamic-weather-nft.git
cd dynamic-weather-nft
```

2. Install dependencies:
```bash
forge install
```

3. Copy the environment file:
```bash
cp .env.example .env
```

4. Set up your environment variables in `.env`

### Build

```bash
forge build
```

## 📝 Deployment Guide

### Local Deployment (Anvil)

1. Start local node:
```bash
anvil
```

2. Deploy Factory:
```bash
forge script script/DeployFactory.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

3. Deploy NFT:
```bash
export FACTORY_ADDRESS=<deployed-factory-address>
forge script script/DeployNFT.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

4. Deploy Oracle:
```bash
export NFT_ADDRESS=<deployed-nft-address>
export WEATHER_PROVIDER_ADDRESS=<provider-address>
forge script script/DeployOracle.s.sol --rpc-url http://localhost:8545 --private-key $PRIVATE_KEY --broadcast
```

### Sepolia Deployment

1. Deploy Factory:
```bash
forge script script/DeployFactory.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

2. Deploy NFT:
```bash
forge script script/DeployNFT.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

3. Deploy Oracle (NOT WORKING YET):
```bash
forge script script/DeployOracle.s.sol --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## 🎮 Contract Interaction

### Create New NFT Collection
```bash
cast send --rpc-url $RPC_URL --private-key $PRIVATE_KEY $FACTORY_ADDRESS "deployWeatherNFT(string,string)" "Weather Collection" "WEATHER"
```

### Mint New NFT
```bash
cast send --rpc-url $RPC_URL --private-key $PRIVATE_KEY $NFT_ADDRESS "safeMint(address,string)" $RECIPIENT_ADDRESS "ipfs://metadata-uri"
```

### Update Weather Data
```bash
cast send --rpc-url $RPC_URL --private-key $PROVIDER_KEY $ORACLE_ADDRESS "submitWeatherData(uint256,int256,uint256,uint256,string)" 1 "250000000000000000" "600000000000000000" "100000000000000000" "Sunny"
```

## 🧪 Test Coverage Results

```
Ran 36 tests (0 failed, 0 skipped)

| File                      | % Lines         | % Statements    | % Branches    | % Funcs         |
|---------------------------|-----------------|-----------------|---------------|-----------------|
| src/WeatherNFT.sol        | 100.00% (17/17) | 100.00% (19/19) | 100.00% (3/3) | 100.00% (5/5)   |
| src/WeatherNFTFactory.sol | 100.00% (19/19) | 95.65% (22/23)  | 50.00% (1/2)  | 100.00% (4/4)   |
| src/WeatherOracle.sol     | 93.94% (31/33)  | 93.75% (30/32)  | 66.67% (4/6)  | 100.00% (6/6)   |
| Total                     | 97.10% (67/69)  | 95.95% (71/74)  | 72.73% (8/11) | 100.00% (15/15) |
```

### Running Tests

```bash
# Run all tests
forge test

# Run tests with gas reporting
forge test --gas-report

# Run specific test file
forge test --match-path test/WeatherNFT.t.sol

# Run with verbosity level
forge test -vvvv
```