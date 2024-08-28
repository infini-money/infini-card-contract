// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IStrategyManager {
    
    struct StrategyStatus {
        uint256 poistion;
        uint256 profit;
    }

    function getStrategyStatus() external returns (StrategyStatus memory);

    function settle(uint256 unSettleProfit) external;
}
