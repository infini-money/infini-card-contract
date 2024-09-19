

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {BaseTest} from "./baseTest.t.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {StrategyUtils} from "@InfiniCard/library/StrategyUtils.sol";
import "forge-std/console.sol";
import {IStrategyManager} from  "@InfiniCard/interfaces/IStrategyManager.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";


contract MorphoStrategyTesting is BaseTest, StrategyUtils {
    function setUp() override public  {
        super.setUp();
    }

    function test_deposit_and_redeem() public {
        uint256 amount = 100000 * 10**6;
        deal(USDCAddress, address(this), amount * 2);
        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), amount);

        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(infiniMorphoStrategy),
            amount,
            ""
        );
        vm.stopPrank();
        uint256 vaultShare = IERC20(MorphoUSDCUSD04626Vault).balanceOf(address(infiniMorphoStrategy)) ;
        require(vaultShare > 0, "check shareToken Amount");

        uint256 _usdc_posiiton = infiniMorphoStrategy.getPosition();
        require(_usdc_posiiton == 100000 * 10**6, "position is invalid");

    
        vm.warp(block.timestamp + 1 weeks);

        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), amount);

        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(infiniMorphoStrategy),
            amount,
            ""
        );
        vm.stopPrank();


        uint256 _profit1 = infiniMorphoStrategy.getProfit();
        console.log(_profit1);

        // redeem
        vm.warp(block.timestamp + 2 weeks);
        vm.startPrank(shaneson);
        uint256 actualAmount = infiniCardVault.redeem(
            address(infiniMorphoStrategy),
            amount * 2,
            ""  
        );
        vm.stopPrank();

        uint256 _profit2 = infiniMorphoStrategy.getProfit();
        console.log(_profit2);

        require(IERC20(USDCAddress).balanceOf(address(infiniMorphoStrategy)) == actualAmount, "check redeem result");
 
        IStrategyManager.StrategyStatus memory status = IStrategyManager(address(infiniMorphoStrategy)).getStrategyStatus();
  
        require(status.poistion == 2 * amount - actualAmount, "check status posistion");
        require(status.profit == _profit2, "check status profit");
    }
}