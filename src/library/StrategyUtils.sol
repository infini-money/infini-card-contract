// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


abstract contract StrategyUtils {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public constant _ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    uint256 public constant _REQUEST_MASK = uint256(1) << 255;

    error AmountIsNotEnough();

    event WithdrawAssetToCustodian(address token, uint256 amount, address to);
    event WithdrawAssetFromStrategy(address token, uint256 amount, address strategy);
    event InvestWithStrategy(address strategy, uint256 amount);
    event DivestWithStaregy(address strategy, uint256 amount);
    
    function _isBalanceEnough(address token, uint256 amount) internal view {
        if (IERC20(token).balanceOf(address(this)) < amount) {
            revert AmountIsNotEnough(); 
        }
    }

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

}
