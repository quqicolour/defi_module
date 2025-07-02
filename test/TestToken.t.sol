// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TestToken} from "../src/TestToken.sol";

contract TestTokenTest is Test {
    TestToken public testToken;

    function setUp() public {
        testToken = new TestToken(6, "Testnet USDC Stablecoin", "USDC");
    }

    function test_Decimals() public {
        console.log("Decimals:", testToken.decimals());
        testToken.decimals();
    }

    // function testFuzz_Airdrop() public {
    //     uint256 beforeBalance = testToken.balanceOf(msg.sender);
    //     testToken.airdrop();
    //     uint256 afterBalance = testToken.balanceOf(msg.sender);
    //     assertEq(afterBalance - beforeBalance, 1000 * 10 ** testToken.decimals());
    // }

    function testFuzz_SuperMint() public {
        uint256 beforeBalance = testToken.balanceOf(msg.sender);
        testToken.superMint(msg.sender, 1000);
        uint256 afterBalance = testToken.balanceOf(msg.sender);
        assertEq(afterBalance - beforeBalance, 1000);
    }
}
