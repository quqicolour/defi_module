//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

import {IPoolManager} from "v4-periphery/lib/v4-core/src/interfaces/IPoolManager.sol";
import {PoolId} from "v4-periphery/lib/v4-core/src/types/PoolId.sol";
import {Hooks} from "v4-periphery/lib/v4-core/src/libraries/Hooks.sol";
import {SqrtPriceMath} from "v4-periphery/lib/v4-core/src/libraries/SqrtPriceMath.sol";
import {TickMath} from "v4-periphery/lib/v4-core/src/libraries/TickMath.sol";
import {PoolManager} from "v4-periphery/lib/v4-core/src/PoolManager.sol";
import {SwapParams, ModifyLiquidityParams} from "v4-periphery/lib/v4-core/src/types/PoolOperation.sol";
import {Currency, CurrencyLibrary} from "v4-periphery/lib/v4-core/src/types/Currency.sol";

import {PoolSwapTest} from "v4-periphery/lib/v4-core/src/test/PoolSwapTest.sol";
import {Deployers} from "v4-periphery/lib/v4-core/test/utils/Deployers.sol";
import {LiquidityAmounts} from "v4-periphery/lib/v4-core/test/utils/LiquidityAmounts.sol";

import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {ERC1155TokenReceiver} from "solmate/src/tokens/ERC1155.sol";

import "forge-std/console.sol";
import "../src/core/PointsHook.sol";

contract TestPointsHook is Test, Deployers, ERC1155TokenReceiver {
    
    MockERC20 token;
    Currency tokenCurrency;
    Currency ethCurrency = Currency.wrap(address((0)));

    function setUp() public {
        deployFreshManagerAndRouters();
        token = new MockERC20("Mock Token", "MOCK", 18);
        tokenCurrency = Currency.wrap(address(token));
        token.mint(address(this), 10000e18);

        uint160 flags = uint160(Hooks.AFTER_SWAP_FLAG);
        address hookAddress = address(flags);
        deployCodeTo("PointsHook.sol:", abi.encode(manager), hookAddress);

        token.approve(address(swapRouter), type(uint256).max);
        token.approve(address(modifyLiquidityRouter),type(uint256).max);

        // (key, ) = initPool(ethCurrency, tokenCurrency, hookAddress, 3000, SQRT_PRICE_1_1);
    }
}