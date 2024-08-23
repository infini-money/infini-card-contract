// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IStrategy {
    function name() external view returns (string memory);

    function deposit(uint256 _amount) external;

    function requestWithdraw(uint256 _amount) external;

    function withdraw(uint256 _amount) external;

    function harvest() external returns (uint256 amount);

}
