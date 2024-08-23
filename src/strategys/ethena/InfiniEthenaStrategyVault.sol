// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IStrategy} from "@InfiniCard/interfaces/IStrategy.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract InfiniEthenaStrategyVault is IStrategy, AccessControl {
    string public constant override name = "InfiniEthenaStaking";

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private constant INFINI_CARD_VAULT = keccak256("INFINI_CARD_VAULT");

    error InvalidZeroAddress();
    error DoNothiing();

    constructor(
        address _adminRole, 
        address _infiniCardVault,
        address _asset
    ) public {
        if (_adminRole == address(0) || _infiniCardVault == address(0) || address(_asset) == address(0)) {
            revert InvalidZeroAddress();
        }

        _grantRole(ADMIN_ROLE, _adminRole);
        _grantRole(INFINI_CARD_VAULT, _infiniCardVault);
    }

    function deposit(uint256)  onlyRole(INFINI_CARD_VAULT) external {

    }

    function withdraw(uint256)  onlyRole(INFINI_CARD_VAULT) external {

    }

    function requestWithdraw(uint256)  onlyRole(INFINI_CARD_VAULT) external {

    }

    function harvest() onlyRole(INFINI_CARD_VAULT) external returns (uint256 amount)  {

    }
}