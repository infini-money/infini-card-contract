// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


abstract contract StrategyUtils {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public constant _ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    uint256 public constant _REQUEST_MASK = uint256(1) << 255;

    event WithdrawAssetToCustodian(address token, uint256 amount, address to, address strategy);
    event WithdrawAssetFromStrategy(address strategy, uint256 amount);
    event InvestWithStrategy(address strategy, uint256 amount);
    event DivestWithStaregy(address strategy, uint256 amount);
    
    function _isBalanceEnough(address target, address token, uint256 amount) internal view returns (bool) {
        if (token == NATIVE_TOKEN) {
            if (address(target).balance < amount) {
                return false;
            }
        } else {
            if (IERC20(token).balanceOf(address(target)) < amount) {
                return false;
            }
        }

        return true;
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
