# InfiniCard Vault

## Overview

InfiniCard Vault is a decentralized asset management platform designed to efficiently manage and grow assets through various strategies. The platform supports multiple strategies, including Ethena and Morpho, allowing users to deposit, withdraw, and settle profits.

## Contract Structure

### Main Contracts

1. **InfiniCardVault.sol**
   - The primary asset management contract responsible for adding strategies, investing assets, and redeeming assets.

2. **InfiniCardController.sol**
   - The controller contract that manages the whitelist of strategies and custodians.

3. **InfiniEthenaStrategyVault.sol**
   - The Ethena strategy contract, inheriting from BaseStrategyVault, implements the specific deposit and redeem operations for the Ethena strategy.

4. **InfiniMorphoStrategyVault.sol**
   - The Morpho strategy contract, inheriting from BaseStrategyVault, implements the specific deposit and redeem operations for the Morpho strategy.


## Core Vault InfiniCardVault

// TODO: translate to English
// InfiniCardVault is a contract designed for backend integration, allowing backend operations such as deposits and withdrawals through this contract.

### DepositToVault

The administrator will transfer money directly from the CEX to the InfiniCardVault contract. Then the strategy administrator will call the investment function to transfer the tokens to the corresponding strategy contract.


```solidity
IERC20(token).TransferFrom(CEX, Vault, amount)
```

### WithdrawToCEX
When the Admin needs to withdraw funds from InfiniCardVault to the CEX, the WithdrawToCEX function will be called.


```solidity
    function withdrawToCEX(
        address token,
        uint256 amount,
        address custodian
    ) onlyRole(INFINI_BACKEND_ROLE) external {
        _isTokenValid(token);
        _isCusdianValid(custodian);
        _isBalanceEnough(token, amount);

        _transferAsset(token, amount, custodian);
        emit WithdrawAssetToCustodian(token, amount, custodian);
    }
```

## Core Strategy Vault

### Morpho



### Ethena


### Deployment

1. Deploy the contracts using the `forge` tool with the following command:
   ```bash
   forge script script/0.deployInfiniCardVault.s.sol:DeployInfiniCardVault --broadcast --rpc-url https://eth.llamarpc.com --legacy
   ```

### Usage

1. **Add Strategy**
   - Administrators can add new strategies using the `addStrategy` function.
   ```solidity
   function addStrategy(address strategy) onlyRole(ADMIN_ROLE) external;
   ```

2. **Invest**
   - Users can invest assets into a specified strategy using the `invest` function.
   ```solidity
   function invest(address strategy, uint256 amount) onlyRole(OPERATOR_ROLE) external payable;
   ```

3. **Redeem**
   - Users can redeem assets from a specified strategy using the `redeem` function.
   ```solidity
   function redeem(address strategy, uint256 amount) onlyRole(OPERATOR_ROLE) external;
   ```

4. **Settle Profits**
   - Administrators can settle profits for a strategy using the `settle` function.
   ```solidity
   function settle(uint256 unSettleProfit) external onlyRole(ADMIN_ROLE);
   ```

## Testing

1. Test the contracts using the `forge` tool with the following command:
   ```bash
   forge test
   ```

2. Test files include:
   - `test/baseTest.t.sol`
   - `test/EthenaStrategy.t.sol`
   - `test/MorphoStrategy.t.sol`

## License

This project is licensed under the BUSL-1.1 License.

