// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {VaultUtils} from "./library/VaultUtils.sol";
import {IInfiniCardVault} from "./interfaces/IInfiniCardVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";
import {InfiniCardController} from "@InfiniCard/InfiniCardController.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// InfiniCardVault contract, inheriting from IInfiniCardVault, InfiniCardController, and VaultUtils
contract InfiniCardVault is IInfiniCardVault, InfiniCardController, VaultUtils {
    using SafeERC20 for IERC20;

    // Constructor to initialize roles
    constructor(
        address _admin_role, 
        address _strategy_operator_role,
        address _infinity_backend_role
    ) InfiniCardController(_admin_role, _strategy_operator_role, _infinity_backend_role) {}

    // =============================================================
    // ==================== View Functions ====================   
    // =============================================================

    // Function to get the list of strategies
    function getStrategyList() external view returns (address[] memory) {
        return strategyList;
    }

    // Function to get the list of tokens
    function getTokenList() external view returns (address[] memory) {
        return tokenList;
    }   

    // Function to get the list of custodians
    function getCusdianList() external view returns (address[] memory) {
        return custodianList;
    }

    // Function to get the token reserves
    function getTokensReserve() public view returns (TokenReserve[] memory) {
        TokenReserve[] memory reserves = new TokenReserve[](tokenList.length);
        for (uint256 i = 0; i < tokenList.length; i++) {
            reserves[i] = TokenReserve(tokenList[i], _getTokenReserve(tokenList[i]));
        }
        return reserves;
    }   

    // =============================================================
    // ==================== INFINI_BACKEND_ROLE ====================   
    // =============================================================

    // Function to withdraw to CEX
    function withdrawToCEX(
        address token,
        uint256 amount,
        address custodian,
        address strategy,
        bytes calldata redeemInfo
    ) onlyRole(INFINI_BACKEND_ROLE) external returns(uint256 actualAmount) {
        _isTokenValid(token);
        _isCusdianValid(custodian);
        actualAmount = amount;

        // If balance is not enough, try to withdraw from strategy
        if( !_isBalanceEnough(address(this), token, amount)) {
            if (strategy == address(0)) {
                revert StrategyNotSet();
            }

            address underlyingToken = IStrategyVault(strategy).underlyingToken();
            if(underlyingToken != token) {
                revert TokenMismatch();
            }

            // Amount may change (less than requested, due to slippage/fee/etc.), 
            // so we use actualGetAmount to withdraw
            actualAmount = _withdraw_from_strategy(strategy, amount, redeemInfo);
        }

        _transferAsset(token, actualAmount, custodian);

        emit WithdrawAssetToCustodian(token, actualAmount, custodian, strategy);
    }

    // =============================================================
    // ==================== STRATEGY_OPERATOR_ROLE ====================   
    // =============================================================

    // Function to withdraw from strategy
    function withdrawFromStrategy(
        address strategy, 
        uint256 amount,
        bytes calldata redeemInfo   
    ) onlyRole(STRATEGY_OPERATOR_ROLE) external {
        _withdraw_from_strategy(strategy, amount, redeemInfo);

        emit WithdrawAssetFromStrategy(strategy, amount);
    }
    
    // Function to invest in a strategy
    function invest(
        address strategy,  
        uint256 amount,
        bytes calldata investmentInfo
    )  onlyRole(STRATEGY_OPERATOR_ROLE) external payable {
        _isStrategyValid(strategy);

        address underlyingToken = IStrategyVault(strategy).underlyingToken();
        SafeERC20.safeTransfer(IERC20(underlyingToken), strategy, amount);

        IStrategyVault(strategy).deposit(amount, investmentInfo);

        emit InvestWithStrategy(strategy, amount);
    }

    // Function to redeem from a strategy
    function redeem(
        address strategy, 
        uint256 amount,
        bytes calldata redeemInfo
    )  onlyRole(STRATEGY_OPERATOR_ROLE) external returns (uint256 actualAmount) {
        _isStrategyValid(strategy);

        actualAmount = IStrategyVault(strategy).redeem(amount, redeemInfo);
        
        emit DivestWithStaregy(strategy, actualAmount);
    }

    // Fallback function to receive Ether
    receive() external payable {}
}