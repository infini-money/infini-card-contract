


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {InfiniCardVault} from "../../src/InfiniCardVault.sol";

contract MorphoInvestScript is Script {
    // forge script script/strategys/morpho_invest.s.sol:MorphoInvestScript --rpc-url https://eth-pokt.nodies.app --broadcast --legacy
    function run() external {
        // 1. send usdc to infiniCardVault

        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        address adminRole = vm.addr(adminPrivateKey);

        vm.startBroadcast(adminPrivateKey);

        address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

        // uint256 usdcBalance = IERC20(USDC).balanceOf(adminRole);
        // IERC20(USDC).transfer(infiniCardVault, usdcBalance);

        // 2. deposit usdc to morpho
        address vault = 0x09E52AA36484c20288D9C148458Ea4DA991118Af;
        address morpho = 0x6ac25F85a8fA9a7D77B3f2165103Fc0F09642B6A;
        address payable infiniCardVault = payable(0x09E52AA36484c20288D9C148458Ea4DA991118Af);

        uint256 usdcBalance = IERC20(USDC).balanceOf(vault);
        InfiniCardVault(infiniCardVault).invest(address(morpho), usdcBalance, "");

        vm.stopBroadcast();

    }
}