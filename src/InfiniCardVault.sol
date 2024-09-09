// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import {InfiniCardController} from "@InfiniCard/InfiniCardController.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {VaultUtils} from "./library/VaultUtils.sol";

contract InfiniCardVault is InfiniCardController, VaultUtils {
    using SafeERC20 for IERC20;

    constructor(
        address _admin_role, 
        address _operator_role,
        address _infinity_backend_role
    ) InfiniCardController(_admin_role, _operator_role, _infinity_backend_role) {}

    function getStrategyList() external view returns (address[] memory) {
        return strategyList;
    }

    function getTokenList() external view returns (address[] memory) {
        return tokenList;
    }   

    function getCusdianList() external view returns (address[] memory) {
        return custodianList;
    }

    function getTokensReserve() public view returns (TokenReserve[] memory) {
        TokenReserve[] memory reserves = new TokenReserve[](tokenList.length);
        for (uint256 i = 0; i < tokenList.length; i++) {
            reserves[i] = TokenReserve(tokenList[i], _getTokenReserve(tokenList[i]));
        }
        return reserves;
    }   

    function withdrawToCEX(
        address token,
        uint256 amount,
        address custodian
    ) onlyRole(INFINI_BACKEND_ROLE) external {
        _isTokenValid(token);
        _isCusdianValid(custodian);
        _isBalanceEnough(token, amount);

        _transferAsset(token, amount, custodian);
        emit WithdrawAssetToCustodian(token, amount, custodian);
    }

    function withdrawFromStrategy(
        address strategy, 
        uint256 amount
    ) onlyRole(OPERATOR_ROLE) external {
        _isStrategyValid(strategy);

        address underlyingToken = IStrategyVault(strategy).underlyingToken();
        IStrategyVault(strategy).withdraw(underlyingToken, amount);

        emit WithdrawAssetFromStrategy(underlyingToken, amount, strategy);
    }
    
    function invest(
        address strategy,  
        uint256 amount
    )  onlyRole(OPERATOR_ROLE) external payable {
        _isStrategyValid(strategy);

        address underlyingToken = IStrategyVault(strategy).underlyingToken();
        SafeERC20.safeTransfer(IERC20(underlyingToken), strategy, amount);

        IStrategyVault(strategy).deposit(amount);

        emit InvestWithStrategy(strategy, amount);
    }

    function redeem(
        address strategy, 
        uint256 amount
    )  onlyRole(OPERATOR_ROLE) external {
        _isStrategyValid(strategy);

        IStrategyVault(strategy).redeem(amount);
        
        emit DivestWithStaregy(strategy, amount);
    }


    receive() external payable {}
}