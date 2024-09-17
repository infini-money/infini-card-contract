
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* solhint-disable private-vars-leading-underscore  */
/* solhint-disable func-name-mixedcase  */
/* solhint-disable var-name-mixedcase  */
import "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
import {IEthenaMinting} from "@InfiniCard/interfaces/ethena/IEthenaMinting.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract InfiniEthenaStrategy {
    using SafeERC20 for IERC20;
    function setApprove(address fromToken, address spender, uint256 amount) external {
        IERC20(fromToken).forceApprove(spender, amount);
    }

    function setDelegateSigner(address ethenaMintingAddress, address deletegateSinger) external {
        IEthenaMinting(ethenaMintingAddress).setDelegatedSigner(deletegateSinger);
    }
}

contract EthenaTesting is Test {
    using SafeERC20 for IERC20;

    address shaneson = 0x790ac11183ddE23163b307E3F7440F2460526957;
    address delegateSinger;
    address EthenaMintingAddress = 0xe3490297a08d6fC8Da46Edb7B6142E4F461b62D3;
    address USDTAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address USDEAddress = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
    address minter = 0xb229D6dB056750E22499191156Bf4c3654DF3826;
    address default_admin_role = 0x3B0AAf6e6fCd4a7cEEf8c92C32DFeA9E64dC1862;

    uint256 deployerPrivateKey;
    InfiniEthenaStrategy infiniEthenaStrategy;

    function _packRsv(bytes32 r, bytes32 s, uint8 v) internal pure returns (bytes memory) {
        bytes memory sig = new bytes(65);
        assembly {
        mstore(add(sig, 32), r)
        mstore(add(sig, 64), s)
        mstore8(add(sig, 96), v)
        }
        return sig;
    }

    function signOrder(uint256 key, bytes32 digest, IEthenaMinting.SignatureType sigType)
        public
        pure
        returns (IEthenaMinting.Signature memory)
    {
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(key, digest);
        bytes memory sigBytes = _packRsv(r, s, v);

        IEthenaMinting.Signature memory signature =
        IEthenaMinting.Signature({signature_type: sigType, signature_bytes: sigBytes});

        return signature;
    }

    function setUp() public {
        deployerPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        delegateSinger = vm.addr(deployerPrivateKey);
        vm.createSelectFork("https://rpc.mevblocker.io");
        infiniEthenaStrategy = new InfiniEthenaStrategy();

        infiniEthenaStrategy.setApprove(USDEAddress, EthenaMintingAddress, 100000 * 10**18);
        infiniEthenaStrategy.setApprove(USDTAddress, EthenaMintingAddress, 100000 * 10**6);
        infiniEthenaStrategy.setDelegateSigner(EthenaMintingAddress, delegateSinger);

        vm.startPrank(delegateSinger);
        IEthenaMinting(EthenaMintingAddress).confirmDelegatedSigner(address(infiniEthenaStrategy));
        vm.stopPrank();
    }

    function test_delegate_mint_on_ethena() public {
        deal(USDTAddress, address(infiniEthenaStrategy), 100000 * 10**6);

        address benefactor = address(infiniEthenaStrategy);
        uint128 amountToDeposit = 100 * 10**6;
        uint128 _usdeToMint = 100 * 10**6;
        IEthenaMinting.Order memory order = IEthenaMinting.Order({
            order_id: "0x101010",
            order_type: IEthenaMinting.OrderType.MINT,
            expiry: uint120(block.timestamp) + 10 minutes,
            nonce: 10,
            benefactor: benefactor,
            beneficiary: benefactor,
            collateral_asset: address(USDTAddress),
            collateral_amount: amountToDeposit,
            usde_amount: _usdeToMint
        });

        address[] memory targets = new address[](1);
        targets[0] = address(shaneson);

        uint128[] memory ratios = new uint128[](1);
        ratios[0] = 10_000;

        IEthenaMinting.Route memory route = IEthenaMinting.Route({addresses: targets, ratios: ratios});

        bytes32 digest1 = IEthenaMinting(EthenaMintingAddress).hashOrder(order);

        bytes32 MINTER_ROLE = keccak256("MINTER_ROLE");
        bool roleAdminAddress = IEthenaMinting(EthenaMintingAddress).hasRole(MINTER_ROLE, minter);
        console.log(roleAdminAddress);

        bytes32 DEFAULT_ADMIN_ROLE = 0x00;
        // Transfer Admin Role to Geneisis default_admin_role
        bool defaultAdminRoleAddress = IEthenaMinting(EthenaMintingAddress).hasRole(DEFAULT_ADMIN_ROLE, default_admin_role);
        console.log(defaultAdminRoleAddress);

        vm.startPrank(default_admin_role);
        IEthenaMinting(EthenaMintingAddress).addWhitelistedBenefactor(benefactor);

        // Just east for testing to addCustodianAddress
        IEthenaMinting(EthenaMintingAddress).addCustodianAddress(shaneson);
        vm.stopPrank();

        uint256 beforeUSDTBalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 beforeUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        vm.startPrank(minter);
        IEthenaMinting.Signature memory signature = signOrder(deployerPrivateKey, digest1, IEthenaMinting.SignatureType.EIP712);
        IEthenaMinting(EthenaMintingAddress).mint(order, route, signature);
        vm.stopPrank();
        uint256 afterUSDTalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 afterUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        require(beforeUSDTBalance == afterUSDTalance + uint256(amountToDeposit), "usdt amount invalid");
        require(beforeUSDEBalance + _usdeToMint == afterUSDEBalance , "usde amount invalid");
    }

    function test_delegate_redeem_on_ethena() public {
        deal(USDEAddress, address(infiniEthenaStrategy), 100 * 10**18);

        address benefactor = address(infiniEthenaStrategy);
        uint128 amountToRedeem = 100 * 10**6;
        uint128 _usdeToBurn = 100 * 10**18;
        IEthenaMinting.Order memory order = IEthenaMinting.Order({
            order_id: "0x101010",
            order_type: IEthenaMinting.OrderType.REDEEM,
            expiry: uint120(block.timestamp) + 10 minutes,
            nonce: 10,
            benefactor: benefactor,
            beneficiary: benefactor,
            collateral_asset: address(USDTAddress),
            collateral_amount: amountToRedeem,
            usde_amount: _usdeToBurn
        });
    
        bytes32 digest1 = IEthenaMinting(EthenaMintingAddress).hashOrder(order);
        vm.startPrank(default_admin_role);
        IEthenaMinting(EthenaMintingAddress).addWhitelistedBenefactor(benefactor);
        vm.stopPrank();

        uint256 beforeUSDTBalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 beforeUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        address redeemer = 0xD0899998CCEB5B3df5cdcFaAdd43e53B8e1d553e;
        vm.startPrank(redeemer);
        IEthenaMinting.Signature memory signature = signOrder(deployerPrivateKey, digest1, IEthenaMinting.SignatureType.EIP712);
        IEthenaMinting(EthenaMintingAddress).redeem(order, signature);
        vm.stopPrank();

        uint256 afterUSDTalance = IERC20(USDTAddress).balanceOf(address(infiniEthenaStrategy));
        uint256 afterUSDEBalance = IERC20(USDEAddress).balanceOf(address(infiniEthenaStrategy));

        require(beforeUSDTBalance + uint256(amountToRedeem) == afterUSDTalance ,  "usdt amount invalid");
        require(beforeUSDEBalance  == afterUSDEBalance +_usdeToBurn , "usde amount invalid");
    }
}