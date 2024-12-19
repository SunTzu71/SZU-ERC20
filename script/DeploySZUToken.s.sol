// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SZUToken} from "../src/SZUToken.sol";

contract DeploySZUToken is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external {
        vm.startBroadcast();
        new SZUToken(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
