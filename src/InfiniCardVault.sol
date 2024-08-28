// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import {InfiniCardController} from "@InfiniCard/InfiniCardController.sol";
import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract InfiniCardVault is InfiniCardController {
    using SafeERC20 for IERC20;

    error AmountIsNotEnough();

    event WithdrawAssetToCustodian(address token, uint256 amount, address to);
    event InvestWithStrategy(uint256 strategy, uint256 amount);
    event DivestWithStaregy(uint256 strategy, uint256 amount);

    constructor(
        address _admin_role, 
        address _operator_role
    ) InfiniCardController(_admin_role, _operator_role) {}
    
    function withdrawToCEX(
        address token,
        uint256 amount,
        address custodian
    ) onlyRole(INFINI_BACKEND_ROLE) external {
        isCusdianValid(custodian);
        isBalanceEnough(token, amount);

        _transferAsset(token, amount, custodian);
        emit WithdrawAssetToCustodian(token, amount, custodian);
    }

    // TODO: Pauseable

    function invest(
        uint256 _strategy,  //TODO: 这个命名有问题
        uint256 amount
    )  onlyRole(OPERATOR_ROLE) external {
        address strategy = address(uint160(_strategy & _ADDRESS_MASK));
        isStrategyValid(strategy);
        bool isRequestDeposit = isRequest(_strategy);

        // Prepare money
        address underlyingToken = IStrategyVault(strategy).underlyingToken();
        SafeERC20.safeTransfer(IERC20(underlyingToken), strategy, amount);

        // Invest with strategy
        if (isRequestDeposit) IStrategyVault(strategy).requestDeposit(amount);
        else  IStrategyVault(strategy).deposit(amount);

        emit InvestWithStrategy(_strategy, amount);
    }

    function disinvest (
        uint256 _strategy,  //TODO: 这个命名有问题
        uint256 amount
    )  onlyRole(OPERATOR_ROLE) external {
        address strategy = address(uint160(_strategy & _ADDRESS_MASK));
        isStrategyValid(strategy);
        bool isRequestDeposit = isRequest(_strategy);

        // Divest with strategy
        if (isRequestDeposit) IStrategyVault(strategy).requestRedeem(amount);
        else IStrategyVault(strategy).redeem(amount);
        
        emit DivestWithStaregy(_strategy, amount);
    }

    function isBalanceEnough(address token, uint256 amount) public view{
        if (IERC20(token).balanceOf(address(this)) < amount) {
            revert AmountIsNotEnough(); 
        }
    }

    // TODO：思考一下能不能不放这里
    function isRequest(uint256 strategy) internal pure returns(bool) {
        if (uint256(strategy & _REQUEST_MASK) > 0) {
            return true;
        }
        return false;
    }

    // TODO：思考一下能不能不放这里
    function _transferAsset(
        address token,
        uint256 amount,
        address to
    ) internal {
        if (token == NATIVE_TOKEN) {
            (bool res, ) = payable(to).call{value: amount}("");
            require(res);
        } else {
            IERC20(token).transfer(to, amount);
        }
    }

    receive() external payable {}
}