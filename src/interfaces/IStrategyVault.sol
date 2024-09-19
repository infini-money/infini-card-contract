// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

interface IStrategyVault {
    function name() external view returns (string memory);

    function getPosition() external view returns(uint256);

    function underlyingToken() external view returns (address);

    function shareToken() external view returns (address);

    function deposit(uint256 _amount, bytes calldata depositInfo) external;

    function redeem(uint256 _amount, bytes calldata redeemInfo) external returns (uint256);

    function withdraw(address token, uint256 _amount) external returns (uint256);

    function harvest() external returns (uint256 amount);
}
