// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

abstract contract BaseStrategyVault is IStrategyVault, AccessControl {
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant INFINI_CARD_VAULT = keccak256("INFINI_CARD_VAULT");

    address public immutable infiniVault;
    address public immutable override underlyingToken;
    address public immutable override shareToken;

    error InvalidZeroAddress();
    error AssetNotEnough();
    error UnderlyingTokenIsNotEnough();
    error ShareTokenIsNotEnough();
    error profitNotEnough();

    event WithdrawAssetToVault(address token, uint256 amount);
    event DepositFinished(uint256 amount);
    event RedeemFinished(uint256 amount);

    constructor(
        address _adminRole, 
        address _infiniCardVault,
        address _asset,
        address _shareToken
    ) {
        if (_adminRole == address(0) || _infiniCardVault == address(0) || address(_asset) == address(0) || address(_shareToken) == address(0)) {
            revert InvalidZeroAddress();
        }

        underlyingToken = _asset;
        shareToken = _shareToken;
        infiniVault = _infiniCardVault;

        _grantRole(ADMIN_ROLE, _adminRole);
        _grantRole(INFINI_CARD_VAULT, _infiniCardVault);
    }

    function withdraw(address token, uint256 amount) virtual external onlyRole(INFINI_CARD_VAULT) {
        // Use actualAmount to withdraw
        uint256 actualAmount = IERC20(token).balanceOf(address(this));
        if ( actualAmount < amount ) {
            amount = actualAmount;
        }

        SafeERC20.safeTransfer(IERC20(token), infiniVault, amount);
        emit WithdrawAssetToVault(token, amount);
    }

    function getBalance(address token) public view returns (uint256 amount) {
        return IERC20(token).balanceOf(address(this));
    }

    function getPosition() virtual external view returns(uint256) {
        return IERC20(underlyingToken).balanceOf(address(this));
    }

    function name() virtual external view returns (string memory) {}

    function deposit(uint256 _amount) virtual external {}

    function redeem(uint256 _amount) virtual external {}

    function harvest() external returns (uint256 amount) {}
}