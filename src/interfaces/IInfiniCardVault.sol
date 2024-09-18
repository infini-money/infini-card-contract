
interface IInfiniCardVault {
    error StrategyNotSet();

    function redeem(address strategy, uint256 amount) external returns(uint256);
    function withdrawToCEX(address token, uint256 amount, address to, address strategy) external returns(uint256);
    function withdrawFromStrategy(address strategy, uint256 amount) external;
}