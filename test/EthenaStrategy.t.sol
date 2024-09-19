
// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {BaseTest} from "./baseTest.t.sol";
import {IEthenaMinting} from "@InfiniCard/interfaces/ethena/IEthenaMinting.sol";
import "forge-std/console.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {StrategyUtils} from "@InfiniCard/library/StrategyUtils.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IStrategyManager} from  "@InfiniCard/interfaces/IStrategyManager.sol";

contract EthenaStrategyTesting is BaseTest, StrategyUtils {
    function setUp() override public  {
        super.setUp();
    }

    function test_mint() public {
        deal(USDTAddress, address(this), 100000 * 10**6);
        SafeERC20.safeTransfer(IERC20(USDTAddress), address(infiniCardVault), 100000 * 10**6);
        vm.startPrank(shaneson);
        infiniCardVault.invest(
            address(infiniEthenaStrategy),
            100000 * 10**6,
            ""
        );
        vm.stopPrank();
        require(IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy)) == 100000 * 10**6, "balance is not enough");
        console.log( "infiniEthenaStrategy:", address(infiniEthenaStrategy));

        address benefactor = address(infiniEthenaStrategy);
        uint128 amountToDeposit = 100 * 10**6;
        uint128 _usdeToMint = 100 * 10**18;
        IEthenaMinting.Order memory order = IEthenaMinting.Order({
            order_id: "0x101010",
            order_type: IEthenaMinting.OrderType.MINT,
            expiry: uint120(block.timestamp) + 10 minutes,
            nonce: 10,
            benefactor: benefactor,
            beneficiary: benefactor,
            collateral_asset: address(USDTAddress),
            collateral_amount: amountToDeposit,
            usde_amount: _usdeToMint
        });

        address[] memory targets = new address[](1);
        targets[0] = address(shaneson);

        uint128[] memory ratios = new uint128[](1);
        ratios[0] = 10_000;

        IEthenaMinting.Route memory route = IEthenaMinting.Route({addresses: targets, ratios: ratios});

        bytes32 digest1 = IEthenaMinting(EthenaMintingAddress).hashOrder(order);

        bytes32 MINTER_ROLE = keccak256("MINTER_ROLE");
        bool roleAdminAddress = IEthenaMinting(EthenaMintingAddress).hasRole(MINTER_ROLE, minter);
        console.log(roleAdminAddress);

        bytes32 DEFAULT_ADMIN_ROLE = 0x00;
        // Transfer Admin Role to Geneisis default_admin_role
        bool defaultAdminRoleAddress = IEthenaMinting(EthenaMintingAddress).hasRole(DEFAULT_ADMIN_ROLE, default_admin_role);
        console.log(defaultAdminRoleAddress);

        vm.startPrank(default_admin_role);
        IEthenaMinting(EthenaMintingAddress).addWhitelistedBenefactor(benefactor);

        // Just east for testing to addCustodianAddress
        IEthenaMinting(EthenaMintingAddress).addCustodianAddress(shaneson);
        vm.stopPrank();

        uint256 beforeUSDTBalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 beforeUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        vm.startPrank(minter);
        IEthenaMinting.Signature memory signature = signOrder(deployerPrivateKey, digest1, IEthenaMinting.SignatureType.EIP712);
        IEthenaMinting(EthenaMintingAddress).mint(order, route, signature);
        vm.stopPrank();
        uint256 afterUSDTalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 afterUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        require(beforeUSDTBalance == afterUSDTalance + uint256(amountToDeposit), "usdt amount invalid");
        require(beforeUSDEBalance + _usdeToMint == afterUSDEBalance , "usde amount invalid");
    }

    function test_redeem() public {
        deal(USDEAddress, address(infiniEthenaStrategy), 100000 * 10**18);
        vm.startPrank(shaneson);
        infiniCardVault.redeem(
            address(infiniEthenaStrategy), 
            100000 * 10**18,
            ""
        );
        vm.stopPrank();

        require(IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy)) == 100000 * 10**18, "balance is not enough");
        
        address benefactor = address(infiniEthenaStrategy);
        uint128 amountToRedeem = 100 * 10**6;
        uint128 _usdeToBurn = 100 * 10**18;
        IEthenaMinting.Order memory order = IEthenaMinting.Order({
            order_id: "0x101010",
            order_type: IEthenaMinting.OrderType.REDEEM,
            expiry: uint120(block.timestamp) + 10 minutes,
            nonce: 10,
            benefactor: benefactor,
            beneficiary: benefactor,
            collateral_asset: address(USDTAddress),
            collateral_amount: amountToRedeem,
            usde_amount: _usdeToBurn
        });

        bytes32 digest1 = IEthenaMinting(EthenaMintingAddress).hashOrder(order);
        vm.startPrank(default_admin_role);
        IEthenaMinting(EthenaMintingAddress).addWhitelistedBenefactor(benefactor);
        vm.stopPrank();

        uint256 beforeUSDTBalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 beforeUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        address redeemer = 0xD0899998CCEB5B3df5cdcFaAdd43e53B8e1d553e;
        vm.startPrank(redeemer);
        IEthenaMinting.Signature memory signature = signOrder(deployerPrivateKey, digest1, IEthenaMinting.SignatureType.EIP712);
        IEthenaMinting(EthenaMintingAddress).redeem(order, signature);
        vm.stopPrank();

        uint256 afterUSDTalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 afterUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        require(beforeUSDTBalance + uint256(amountToRedeem) == afterUSDTalance ,  "usdt amount invalid");
        require(beforeUSDEBalance  == afterUSDEBalance +_usdeToBurn , "usde amount invalid");
    }

    
    function test_settlement() public {
        // Ethena send reward to infiniEthenaStrategyManager
        deal(USDEAddress, address(infiniEthenaStrategyManager), 1000 * 10**18);
        vm.startPrank(shaneson);
        uint256 unsettleAmount = 1000 * 10**18;

        IStrategyManager.StrategyStatus memory status = infiniEthenaStrategyManager.getStrategyStatus();
        require(status.profit == 1000 * 10**18, "CHECK profit1");

        infiniEthenaStrategyManager.settle(unsettleAmount);

        uint256 protocolProfit = unsettleAmount * 500 / 10000;

        require(IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategyManager)) == 0, "CHECK0");
        require(IERC20(USDEAddress).balanceOf(address(infiniTreasure)) == protocolProfit, "CHECK1");
        require(IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy)) == unsettleAmount - protocolProfit, "CHECK2");

        status = infiniEthenaStrategyManager.getStrategyStatus();
        require(status.profit == 0, "CHECK profit2");
        require(status.poistion == unsettleAmount - protocolProfit, "CHECK profit3");

        vm.stopPrank();
    }


}