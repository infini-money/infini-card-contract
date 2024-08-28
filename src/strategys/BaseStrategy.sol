// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

import {IStrategyVault} from "@InfiniCard/interfaces/IStrategyVault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract BaseStrategy is IStrategyVault {
    function name() virtual external view returns (string memory) {}

    function underlyingToken() virtual external view returns (address) {}

    function shareToken() virtual external view returns (address) {}

    function deposit(uint256 _amount) virtual external {}

    function requestDeposit(uint256 _amount) virtual external {}

    function redeem(uint256 _amount) virtual external {}

    function requestRedeem(uint256 _amount) virtual external {}

    function withdraw(address token, uint256 amount) virtual external {}

    function harvest() external returns (uint256 amount) {}

    function getBalance(address token) public view returns (uint256 amount) {
        return IERC20(token).balanceOf(address(this));
    }
}