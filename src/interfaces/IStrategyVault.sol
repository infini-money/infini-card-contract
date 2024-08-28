// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IStrategyVault {
   function name() external view returns (string memory);

    function underlyingToken() external view returns (address);

    function shareToken() external view returns (address);

    function deposit(uint256 _amount) external;

    function requestDeposit(uint256 _amount) external;

    function redeem(uint256 _amount) external;

    function requestRedeem(uint256 _amount) external;

    function withdraw(address token, uint256 _amount) external;

    function harvest() external returns (uint256 amount);
}
