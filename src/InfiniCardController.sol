// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import {CommonUtils} from "./library/CommonUtils.sol";

contract InfiniCardController is AccessControl, CommonUtils {

    mapping(address => bool) strategyWhiteList;
    mapping(address => bool) custodianWhiteList;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant INFINI_BACKEND_ROLE = keccak256("INFINI_BACKEND_ROLE");

    error StrategyInvalid();
    error CustianInvalid();

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

    function addCusdianToWhiteList(address cusdian) onlyRole(ADMIN_ROLE) external {
        custodianWhiteList[cusdian] = true;
    }

    function removeCusdianToWhiteList(address cusdian) onlyRole(ADMIN_ROLE) external {
        custodianWhiteList[cusdian] = false;
    }

    function isStrategyValid(address strategy) public view {
        if (!strategyWhiteList[strategy]) {
            revert StrategyInvalid(); 
        }
    }

    function isCusdianValid(address cusdian) public view  {
        if (!custodianWhiteList[cusdian]) {
            revert CustianInvalid();
        }
    }

}