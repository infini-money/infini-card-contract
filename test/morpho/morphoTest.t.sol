
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/* solhint-disable private-vars-leading-underscore  */
/* solhint-disable func-name-mixedcase  */
/* solhint-disable var-name-mixedcase  */
import "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";
import "@openzeppelin/contracts/interfaces/IERC4626.sol";


contract MorphoTesting is Test {
    address market = 0xd63070114470f685b75B74D60EEc7c1113d33a3D;
    address christian = 0x0DB87155511f190034a2b73D98F699bFeBFbD85F;

    function test_checkbalance() public {
        vm.createSelectFork("https://rpc.mevblocker.io");

        uint256 shares = 1628206300286549776160233;
        uint256 previewRedeemVaule = IERC4626(market).previewRedeem(shares);
       
        vm.startPrank(christian);
        uint256 asset = IERC4626(market).redeem(shares, christian, christian);
        require(asset == previewRedeemVaule, "asset is ok");
        vm.stopPrank();

    }
}
