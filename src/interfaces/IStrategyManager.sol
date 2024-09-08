// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IStrategyManager {
    error ProfitIsNotEnough();

    event Settlement(address profitToken, uint256 protocolProfit, uint256 settleProfit);
    struct StrategyStatus {
        uint256 poistion;
        uint256 profit;
        address underlyingToken;
        address strategyAddress;
    }

    function getStrategyStatus() external view returns (StrategyStatus memory);

    function settle(uint256 unSettleProfit) external;
}
