// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../contracts/Crowdfund.sol";

contract DeployEverestOrBust is Script {
    function run() external {
        vm.startBroadcast();

        new EverestOrBust(
            0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48, // USDC (mainnet)
            0xdAC17F958D2ee523a2206206994597C13D831ec7, // USDT (mainnet)
            0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, // WBTC (mainnet)
            2500e18,   // ETH price $2500
            95000e18   // BTC price $95000
        );

        vm.stopBroadcast();
    }
}
