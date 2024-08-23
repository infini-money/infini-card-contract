// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";

contract InfiniCardController is AccessControl {

    mapping(address => bool) strategyWhiteList;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    error StrategyInvalid();

    modifier onlyValidStrategy(address strategy) {
        _isStrategyValid(strategy);
        _;
    }

    constructor(address _admin_role, address _operator_role) {
        _grantRole(ADMIN_ROLE, _admin_role);
        _grantRole(OPERATOR_ROLE, _operator_role);
    }

    function addStrategy(address strategy) onlyRole(ADMIN_ROLE) external {
        strategyWhiteList[strategy] = true;
    }

    function removeStrategy(address strategy) onlyRole(ADMIN_ROLE) external { 
        strategyWhiteList[strategy] = false;
    }

    function _isStrategyValid(address strategy) private  {
        if (!strategyWhiteList[strategy]) {
            revert StrategyInvalid(); 
        }
    }

}