// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BaseStrategyVault} from "@InfiniCard/strategys/BaseStrategyVault.sol";
import {IEthenaMinting} from "@InfiniCard/interfaces/ethena/IEthenaMinting.sol";

contract InfiniEthenaStrategyVault is BaseStrategyVault {
    using SafeERC20 for IERC20;

    address private immutable ethenaMintingAddress;
    string public constant override name = "InfiniEthenaStaking";

    event SetDelegateSigner(address delegateSigner);

    constructor(
        address _adminRole, 
        address _infiniCardVault,
        address _asset,
        address _usde,
        address _ethenaMintingAddress
    ) BaseStrategyVault(_adminRole, _infiniCardVault, _asset, _usde) {
        ethenaMintingAddress = _ethenaMintingAddress;
    }

    // USDE
    function getPosition() override external view returns(uint256) {
        return IERC20(shareToken).balanceOf(address(this));
    }

    function deposit(uint256 amount, bytes calldata) external override onlyRole(INFINI_CARD_VAULT) {
        if ( getBalance(underlyingToken) < amount ) revert UnderlyingTokenIsNotEnough();
        SafeERC20.forceApprove(IERC20(underlyingToken), ethenaMintingAddress, amount);
        emit DepositFinished(amount);
    }

    function redeem(uint256 amount, bytes calldata) external override onlyRole(INFINI_CARD_VAULT) returns (uint256 actualRedeemedAmount) {
        if ( getBalance(shareToken) < amount) revert ShareTokenIsNotEnough();
        SafeERC20.forceApprove(IERC20(shareToken), ethenaMintingAddress, amount);
        emit RedeemFinished(amount);
    }

    function setDelegateSigner(address delegateSigner) external onlyRole(ADMIN_ROLE) {
        IEthenaMinting(ethenaMintingAddress).setDelegatedSigner(delegateSigner);
        emit SetDelegateSigner(delegateSigner);
    }
}