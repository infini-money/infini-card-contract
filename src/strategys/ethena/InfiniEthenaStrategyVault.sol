// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BaseStrategy} from "@InfiniCard/strategys/BaseStrategy.sol";
import {IEthenaMinting} from "@InfiniCard/interfaces/ethena/IEthenaMinting.sol";

contract InfiniEthenaStrategyVault is BaseStrategy, AccessControl {
    using SafeERC20 for IERC20;

    uint256 public position;
    uint256 public carryRate;

    string public constant override name = "InfiniEthenaStaking";

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 private constant INFINI_CARD_VAULT = keccak256("INFINI_CARD_VAULT");

    address private immutable infiniVault;
    address private immutable ethenaMintingAddress;
    address public immutable override underlyingToken;
    address public immutable override shareToken;

    error InvalidZeroAddress();
    error UnderlyingTokenIsNotEnough();
    error USDEIsNotEnough();
    error AssetNotEnough();

    event WithdrawAssetToVault(address token, uint256 amount);
    event RequestDepositFinished(uint256 amount);
    event RequestRedeemFinished(uint256 amount);
    event SetDelegateSigner(address delegateSigner);
    event SetCarryRate(uint256 carryRate);

    constructor(
        address _adminRole, 
        address _ethenaMintingAddress,
        address _infiniCardVault,
        address _asset,
        address _usde
    ) {
        if (_adminRole == address(0) || _infiniCardVault == address(0) || address(_asset) == address(0)) {
            revert InvalidZeroAddress();
        }

        ethenaMintingAddress = _ethenaMintingAddress;
        underlyingToken = _asset;
        shareToken = _usde;
        infiniVault = _infiniCardVault;
        carryRate = 1000;

        _grantRole(ADMIN_ROLE, _adminRole);
        _grantRole(INFINI_CARD_VAULT, _infiniCardVault);
    }

    function requestDeposit(uint256 amount) external override onlyRole(INFINI_CARD_VAULT) {
        if ( getBalance(underlyingToken) < amount ) revert UnderlyingTokenIsNotEnough();
        SafeERC20.forceApprove(IERC20(underlyingToken), ethenaMintingAddress, amount);
        emit RequestDepositFinished(amount);
    }

    function requestRedeem(uint256 amount) external override onlyRole(INFINI_CARD_VAULT) {
        if ( getBalance(shareToken) < amount) revert USDEIsNotEnough();
        SafeERC20.forceApprove(IERC20(shareToken), ethenaMintingAddress, amount);
        emit RequestRedeemFinished(amount);
    }

    function withdraw(address token, uint256 amount) external override onlyRole(INFINI_CARD_VAULT) {
        if (IERC20(token).balanceOf(address(this)) < amount ) revert AssetNotEnough();
        SafeERC20.safeTransfer(IERC20(token), infiniVault, amount);
        emit WithdrawAssetToVault(token, amount);
    }

    function setDelegateSigner(address delegateSigner) external onlyRole(ADMIN_ROLE) {
        IEthenaMinting(ethenaMintingAddress).setDelegatedSigner(delegateSigner);
        emit SetDelegateSigner(delegateSigner);
    }

    function setCarryRate(uint256 newCarryRate) external onlyRole(ADMIN_ROLE) {
        carryRate = newCarryRate;
        emit SetCarryRate(newCarryRate);
    } 

}