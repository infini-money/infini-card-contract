

// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import {InfiniCardController} from "@InfiniCard/InfiniCardController.sol";

contract InfiniCardVault is InfiniCardController {

    constructor(address _admin_role, address _operator_role) InfiniCardController(_admin_role, _operator_role) {}
    
    function invest(
        address strategy,
        bytes memory moreInfo
    )   onlyRole(OPERATOR_ROLE) onlyValidStrategy(strategy) external {

    }

    function divest(
        address strategy,
        bytes memory moreInfo
    )  onlyRole(OPERATOR_ROLE) onlyValidStrategy(strategy) external {
        
    }

}