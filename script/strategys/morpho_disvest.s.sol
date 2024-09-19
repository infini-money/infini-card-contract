


// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {InfiniCardVault} from "../../src/InfiniCardVault.sol";
import {InfiniMorphoStrategyVault} from "../../src/strategys/morpho/InfiniMorphoStrategyVault.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";

import {IInfiniCardVault} from "../../src/interfaces/IInfiniCardVault.sol";

contract MorphoDisvestScript is Script {
    // forge script script/strategys/morpho_disvest.s.sol:MorphoDisvestScript --rpc-url https://eth-pokt.nodies.app --broadcast --legacy
    function run() external {

        uint256 adminPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        address adminRole = vm.addr(adminPrivateKey);

        vm.startBroadcast(adminPrivateKey);

        // 1. withdraw usdc from morpho
        address morpho = 0x6ac25F85a8fA9a7D77B3f2165103Fc0F09642B6A;
        address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address payable infiniCardVault = payable(0x09E52AA36484c20288D9C148458Ea4DA991118Af);
        address market = 0xd63070114470f685b75B74D60EEc7c1113d33a3D;
        address shaneson = 0x790ac11183ddE23163b307E3F7440F2460526957;

        // get poistion
        uint256 shares = IERC20(market).balanceOf(morpho);
        console.log("balance", shares);

        // settle profit
        uint256 profit = InfiniMorphoStrategyVault(morpho).getProfit();
        console.log("profit", profit);

        InfiniMorphoStrategyVault(morpho).settle(profit);
        console.log("settleProfit finished");

        // get position
        uint256 position = InfiniMorphoStrategyVault(morpho).getPosition();
        console.log("position", position);

        IInfiniCardVault(infiniCardVault).redeem(address(morpho), position, "");
        console.log("redeem finished");

        uint256 usdcBalance = IERC20(USDC).balanceOf(morpho);
        IInfiniCardVault(infiniCardVault).withdrawFromStrategy(address(morpho), usdcBalance, "");
        console.log("withdraw finished");

        uint256 usdcBalance2 = IERC20(USDC).balanceOf(infiniCardVault);
        console.log("usdcBalance2", usdcBalance2);

        IInfiniCardVault(infiniCardVault).withdrawToCEX(USDC, usdcBalance2, shaneson, address(morpho), "");
        console.log("withdrawToCEX finished");

        vm.stopBroadcast();

    }
}