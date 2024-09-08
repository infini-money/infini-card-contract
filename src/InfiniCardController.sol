// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/access/AccessControl.sol";
import {StrategyUtils} from "./library/StrategyUtils.sol";
import {IStrategyVault} from "./interfaces/IStrategyVault.sol";

contract InfiniCardController is AccessControl, StrategyUtils {

    mapping(address => bool) strategyWhiteList;
    mapping(address => bool) custodianWhiteList;
    mapping(address => bool) tokenWhiteList;

    address[] strategyList;
    address[] tokenList;
    address[] custodianList;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant INFINI_BACKEND_ROLE = keccak256("INFINI_BACKEND_ROLE");

    error StrategyInvalid();
    error CustianInvalid(); 
    error TokenInvalid();

    constructor(address _admin_role, address _operator_role) {
        _grantRole(DEFAULT_ADMIN_ROLE, _admin_role);
        _grantRole(ADMIN_ROLE, _admin_role);
        _grantRole(OPERATOR_ROLE, _operator_role);
    }

    function addStrategy(address strategy) onlyRole(ADMIN_ROLE) external {
        strategyWhiteList[strategy] = true;
        _addToken(IStrategyVault(strategy).underlyingToken());
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

    function _addToken(address token) internal {
        tokenWhiteList[token] = true;
        tokenList.push(token);
    }   

    function _isTokenValid(address token) internal view {
        if (!tokenWhiteList[token]) {
            revert TokenInvalid();
        }
    }

    function _isStrategyValid(address strategy) internal view {
        if (!strategyWhiteList[strategy]) {
            revert StrategyInvalid(); 
        }
    }

    function _isCusdianValid(address cusdian) internal view  {
        if (!custodianWhiteList[cusdian]) {
            revert CustianInvalid();
        }
    }

}