
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
import {InfiniEthenaStrategyVault} from "@InfiniCard/strategys/ethena/InfiniEthenaStrategyVault.sol";
import {InfiniCardVault} from "@InfiniCard/InfiniCardVault.sol";
import {IEthenaMinting} from "@InfiniCard/interfaces/ethena/IEthenaMinting.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {InfiniEthenaStrategyManager} from "@InfiniCard/strategys/ethena/InfiniEthenaStrategyManager.sol";

contract BaseTest is Test {

    address public delegateSinger;
    uint256 public deployerPrivateKey;

    address public infiniTreasure = address(0x1D1e94634FBcB767ce8650269B2c4d33280f0130);
    address public shaneson = 0x790ac11183ddE23163b307E3F7440F2460526957;
    address public EthenaMintingAddress = 0xe3490297a08d6fC8Da46Edb7B6142E4F461b62D3;
    address public USDTAddress = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public USDEAddress = 0x4c9EDD5852cd905f086C759E8383e09bff1E68B3;
    address public minter = 0xb229D6dB056750E22499191156Bf4c3654DF3826;
    address public default_admin_role = 0x3B0AAf6e6fCd4a7cEEf8c92C32DFeA9E64dC1862;

    InfiniEthenaStrategyManager public infiniEthenaStrategyManager;
    InfiniEthenaStrategyVault public infiniEthenaStrategy;
    InfiniCardVault public infiniCardVault;
    

    function setUp() virtual public {
        deployerPrivateKey = vm.envUint("ADMIN_PRIVATE_KEY");
        delegateSinger = vm.addr(deployerPrivateKey);
        vm.createSelectFork("https://eth.llamarpc.com");

        infiniCardVault = new InfiniCardVault(shaneson, shaneson);

        infiniEthenaStrategy = new InfiniEthenaStrategyVault(
            shaneson,
            EthenaMintingAddress,
            address(infiniCardVault),
            USDTAddress,
            USDEAddress
        );

        infiniEthenaStrategyManager = new InfiniEthenaStrategyManager(
            address(infiniEthenaStrategy),
            infiniTreasure,
            shaneson
        );


        // only admin
        vm.startPrank(shaneson);
        infiniEthenaStrategy.setDelegateSigner(delegateSinger);
        infiniCardVault.addStrategy(address(infiniEthenaStrategy));
        vm.stopPrank();


        vm.startPrank(delegateSinger);
        IEthenaMinting(EthenaMintingAddress).confirmDelegatedSigner(address(infiniEthenaStrategy));
        vm.stopPrank();
    }

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

}