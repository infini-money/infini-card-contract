// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;

abstract contract CommonUtils {
    address public constant NATIVE_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint256 public constant _ADDRESS_MASK = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;

    uint256 public constant _REQUEST_MASK = uint256(1) << 255;
}
