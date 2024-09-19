// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {BaseTest} from "./baseTest.t.sol";
import {InfiniCardVault} from "@InfiniCard/InfiniCardVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract InfiniCardVaultTesting is BaseTest {
    function setUp() override public {
        super.setUp();
    }

    function test_invest() public {
        deal(USDCAddress, address(this), 100000 * 10**6);
        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), 100000 * 10**6);
        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(infiniMorphoStrategy),
            100000 * 10**6
        );
    }

    function test_withdraw() public {
        deal(USDCAddress, address(this), 100000 * 10**6);
        SafeERC20.safeTransfer(IERC20(USDCAddress), address(infiniCardVault), 100000 * 10**6);
        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(infiniMorphoStrategy),
            100000 * 10**6
        );

        require(IERC20(USDCAddress).balanceOf(address(infiniCardVault)) == 0, "USDT balance should be 0");
        vm.warp(block.timestamp + 2 weeks);

        uint256 beforeAmount = IERC20(USDCAddress).balanceOf(shaneson);
        uint256 actualAmount = infiniCardVault.withdrawToCEX(
            USDCAddress, 
            100000 * 10**6, 
            shaneson, 
            address(infiniMorphoStrategy)
        );

        require(IERC20(USDCAddress).balanceOf(shaneson) == beforeAmount + actualAmount, "USDT balance should be actualAmount");
    }
}