

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {InfiniMorphoStrategyVault} from "../../src/strategys/morpho/InfiniMorphoStrategyVault.sol";

contract PreviewInvestInfoScript is Script {

    // forge script script/strategys/preview_investInfo.s.sol:PreviewInvestInfoScript --rpc-url https://eth.llamarpc.com
    function run() external {
        address morpho = 0x6ac25F85a8fA9a7D77B3f2165103Fc0F09642B6A;
        address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        address infiniCardVault = 0x09E52AA36484c20288D9C148458Ea4DA991118Af;
        address market = 0xd63070114470f685b75B74D60EEc7c1113d33a3D;
        
        uint256 shares = IERC20(market).balanceOf(morpho);
        console.log("balance", shares);

        uint256 amount = IERC4626(market).previewRedeem(shares);
        console.log("amount", amount);

        uint256 profit = InfiniMorphoStrategyVault(morpho).getProfit();
        console.log("profit", profit);

        uint256 position = InfiniMorphoStrategyVault(morpho).getPosition();
        console.log("position", position);
    }
}
