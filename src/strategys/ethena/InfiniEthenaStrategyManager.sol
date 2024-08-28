// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";
import {IStrategyManager} from  "@InfiniCard/interfaces/IStrategyManager.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract InfiniEthenaStrategyManager is IStrategyManager, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address private immutable infiniTreasure;
    address private immutable strategyVault;
    address private immutable usde;
    uint256 carryRate = 500;

    error ProfitIsNotEnough();

    event Settlement(address usde, uint256 protocolProfit, uint256 settleProfit);

    constructor(address _strategy, address _treasure, address _adminRole) {
        strategyVault = _strategy;
        infiniTreasure = _treasure;
        usde = IStrategyVault(strategyVault).shareToken();

        _grantRole(ADMIN_ROLE, _adminRole);
    }

    function getProfit() public view returns(uint256) {
        return IERC20(usde).balanceOf(address(this));
    }

    function getPosition() public view returns(uint256) {
        return IERC20(usde).balanceOf(strategyVault);
    }

    function getStrategyStatus() external returns (StrategyStatus memory status) {
        status = StrategyStatus({
            poistion: getPosition(),
            profit: getProfit()
        });
    }

    function settle(uint256 unSettleProfit) external onlyRole(ADMIN_ROLE) {
        uint256 profit = getProfit();
        if (profit < unSettleProfit) revert ProfitIsNotEnough();

        uint256 protocolProfit = unSettleProfit * carryRate / 10000;
        uint256 settleProfit = unSettleProfit - protocolProfit;

        IERC20(usde).transfer(infiniTreasure, protocolProfit);
        IERC20(usde).transfer(strategyVault, settleProfit);

        emit Settlement(usde, protocolProfit, settleProfit);
    }

}