// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";
import {IStrategyManager} from  "@InfiniCard/interfaces/IStrategyManager.sol";

abstract contract BaseStrategyManager is IStrategyManager, AccessControl {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    address public immutable infiniTreasure;
    address public immutable strategyVault;
    address public immutable profitToken;
    uint256 carryRate = 500;

    constructor(address _strategy, address _treasure, address _adminRole) {
        strategyVault = _strategy;
        infiniTreasure = _treasure;
        profitToken = IStrategyVault(strategyVault).shareToken();

        _grantRole(ADMIN_ROLE, _adminRole);
    }

    function settle(uint256 unSettleProfit) external virtual {}

    function getStrategyStatus() external virtual view returns (StrategyStatus memory status)  {}
}