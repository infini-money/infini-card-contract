
interface IInfiniCardVault {
    error StrategyNotSet();

    function redeem(address strategy, uint256 amount, bytes calldata redeemInfo) external returns(uint256);
    function withdrawToCEX(address token, uint256 amount, address to, address strategy, bytes calldata withdrawInfo) external returns(uint256);
    function withdrawFromStrategy(address strategy, uint256 amount, bytes calldata redeemInfo) external;
}