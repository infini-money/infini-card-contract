// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BaseStrategyManager} from "@InfiniCard/strategys/BaseStrategyManager.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";

contract InfiniEthenaStrategyManager is BaseStrategyManager {
    using SafeERC20 for IERC20;

    constructor(
        address _strategy, 
        address _treasure, 
        address _adminRole
    ) BaseStrategyManager(_strategy, _treasure, _adminRole) {}

    function getStrategyStatus() external override returns (StrategyStatus memory status) {
        status = StrategyStatus({
            poistion: IStrategyVault(strategyVault).getPosition(),
            profit: _getProfit()
        });
    }

    function settle(uint256 unSettleProfit) external override onlyRole(ADMIN_ROLE) {
        uint256 profit = _getProfit();
        if (profit < unSettleProfit) revert ProfitIsNotEnough();

        uint256 protocolProfit = unSettleProfit * carryRate / 10000;
        uint256 settleProfit = unSettleProfit - protocolProfit;

        IERC20(profitToken).transfer(infiniTreasure, protocolProfit);
        IERC20(profitToken).transfer(strategyVault, settleProfit);

        emit Settlement(profitToken, protocolProfit, settleProfit);
    }

    function _getProfit() internal view returns(uint256) {
        return IERC20(profitToken).balanceOf(address(this));
    }

}