// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC4626} from "@openzeppelin/contracts/interfaces/IERC4626.sol";
import {BaseStrategyVault} from "@InfiniCard/strategys/BaseStrategyVault.sol";
import {IStrategyManager} from  "@InfiniCard/interfaces/IStrategyManager.sol";

contract InfiniMorphoStrategyVault is BaseStrategyVault, IStrategyManager {
    uint256 public vaultPosition;
    address public immutable market;
    address public immutable infiniTreasure;

    string public constant override name = "InfiniMorphoStrategy";
    uint256 carryRate = 500;
    
    constructor(
        address _adminRole, 
        address _infiniCardVault,
        address _asset,
        address _shareToken,
        address _market,
        address _treasure
    ) 
        BaseStrategyVault(_adminRole, _infiniCardVault, _asset, _shareToken) 
    {
        market = _market;
        infiniTreasure = _treasure;
    }

    function getProfit() public view returns (uint256) {
        uint256 shares = IERC20(shareToken).balanceOf(address(this));
        uint256 totalPosition = IERC4626(market).previewRedeem(shares);

        // convert share to asset may cause this case.
        if (vaultPosition > totalPosition) return 0;
        return totalPosition - vaultPosition;
    }

    function getPosition() external view override returns (uint256) {
        return vaultPosition;
    }

    function getStrategyStatus() external view override returns (StrategyStatus memory status) {
        status = StrategyStatus({
            poistion: vaultPosition,
            profit: getProfit(),
            underlyingToken: underlyingToken,
            strategyAddress: address(this)
        });
    }

    function settle(uint256 unSettleProfit) external onlyRole(ADMIN_ROLE) {
        uint256 profit = getProfit();
        if (unSettleProfit > profit) revert profitNotEnough();

        uint256 unsettleShare = IERC4626(market).convertToShares(unSettleProfit);

        uint256 protocolProfitShare = unsettleShare * carryRate / 10000;
        uint256 settleProfitShare = unsettleShare - protocolProfitShare;

        IERC4626(market).redeem(protocolProfitShare, infiniTreasure, address(this));
        IERC4626(market).redeem(settleProfitShare, address(this), address(this));

        // redeposit again
        uint256 underlyingTokenAmount = getBalance(underlyingToken);
        _deposit(underlyingTokenAmount);

        emit Settlement(shareToken, settleProfitShare, protocolProfitShare);
    }

    function deposit(uint256 amount, bytes calldata) virtual external override  onlyRole(INFINI_CARD_VAULT) {
        if ( getBalance(underlyingToken) < amount ) revert UnderlyingTokenIsNotEnough();
        _deposit(amount);
    }

    function redeem(uint256 amount, bytes calldata) virtual external override  onlyRole(INFINI_CARD_VAULT) returns (uint256 actualRedeemedAmount) {
        if (amount > vaultPosition) revert AmountCannotBeGreaterThanPosition();
        uint256 shouldRedeemSharesAmount = IERC4626(shareToken).convertToShares(amount);

        if (getBalance(shareToken) < shouldRedeemSharesAmount) revert ShareTokenIsNotEnough();
        
        actualRedeemedAmount = IERC4626(market).redeem(shouldRedeemSharesAmount, address(this), address(this));

        // TODO: minus redeem
        vaultPosition -= actualRedeemedAmount;

        emit RedeemFinished(actualRedeemedAmount);
    }


    function _deposit(uint256 amount) internal {
        SafeERC20.forceApprove(IERC20(underlyingToken), market, amount);
        IERC4626(market).deposit(amount, address(this));

        // update vaultPosition
        vaultPosition += amount;

        emit DepositFinished(amount);
    }
}


