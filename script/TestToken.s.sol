// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {TestToken} from "../src/TestToken.sol";

contract TestTokenScript is Script {
    TestToken public testToken;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        testToken = new TestToken(6, "Testnet USDC Stablecoin", "USDC");

        vm.stopBroadcast();
    }

    function do_airdrop() public {
        testToken.airdrop();
    }
}
