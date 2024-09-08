// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


abstract contract VaultUtils {
    struct TokenReserve {
        address token;
        uint256 reserve;
    }

    function _getTokenReserve(address token) internal view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }
}