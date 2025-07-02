//SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "v4-periphery/src/utils/BaseHook.sol";
import {IPoolManager} from "v4-periphery/lib/v4-core/src/interfaces/IPoolManager.sol";
import {PoolId} from "v4-periphery/lib/v4-core/src/types/PoolId.sol";
import {PoolKey} from "v4-periphery/lib/v4-core/src/types/PoolKey.sol";
import {Hooks} from "v4-periphery/lib/v4-core/src/libraries/Hooks.sol";
import {SwapParams} from "v4-periphery/lib/v4-core/src/types/PoolOperation.sol";
import {BalanceDelta} from "v4-periphery/lib/v4-core/src/types/BalanceDelta.sol";
import {ERC1155} from "openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";

contract PointsHook is BaseHook, ERC1155, Ownable {

    uint16 private constant baseFee = 1000;
    uint16 private dynamicFee;

    
    constructor(IPoolManager _manager, address _thisOwner) BaseHook(_manager) ERC1155("") Ownable(_thisOwner) {}

    event ChangeFee(uint16 fee);

    function changeFee(uint16 _dynamicFee) external onlyOwner {
        dynamicFee = _dynamicFee;
        emit ChangeFee(dynamicFee);
    }

    function getHookPermissions()
        public
        pure
        override
        returns (Hooks.Permissions memory)
    {
        return
            Hooks.Permissions({
                beforeInitialize: false,
                afterInitialize: false,
                beforeAddLiquidity: true,
                afterAddLiquidity: true,
                beforeRemoveLiquidity: true,
                afterRemoveLiquidity: true,
                beforeSwap: false,
                afterSwap: true,
                beforeDonate: false,
                afterDonate: false,
                beforeSwapReturnDelta: false,
                afterSwapReturnDelta: false,
                afterAddLiquidityReturnDelta: false,
                afterRemoveLiquidityReturnDelta: false
            });
    }

    function uri(uint256) public override view returns (string memory) {
        return "";
    }

    function _afterSwap(
        address sender, 
        PoolKey calldata key, 
        SwapParams calldata params, 
        BalanceDelta delta, 
        bytes calldata hookData
    )
        internal
        override
        returns (bytes4, int128)
    {
        if(!key.currency0.isAddressZero()) return (this.afterSwap.selector, 0);
        if(!params.zeroForOne) return (this.afterSwap.selector, 0);
        uint256 amountOfETHSpent = uint256(int256(-delta.amount0()));
        uint256 pointsToGiveout = amountOfETHSpent / 5;
        _assgnPoints(key.toId(), hookData, pointsToGiveout);
        return (this.afterSwap.selector, 0);
    }

    function _beforeAddLiquidity(address, PoolKey calldata, ModifyLiquidityParams calldata, bytes calldata)
        internal
        virtual
        returns (bytes4)
    {
        revert HookNotImplemented();
    }

    function _afterAddLiquidity(
        address,
        PoolKey calldata,
        ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    ) internal virtual returns (bytes4, BalanceDelta) {
        revert HookNotImplemented();
    }

    function _beforeRemoveLiquidity(address, PoolKey calldata, ModifyLiquidityParams calldata, bytes calldata)
        internal
        virtual
        returns (bytes4)
    {
        revert HookNotImplemented();
    }

    function _afterRemoveLiquidity(
        address,
        PoolKey calldata,
        ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    ) internal virtual returns (bytes4, BalanceDelta) {
        revert HookNotImplemented();
    }

    function _assgnPoints(
        PoolId poolId,
        bytes calldata hookData,
        uint256 points
    ) internal {
        if (hookData.length == 0) return;
        address user = abi.decode(hookData, (address));
        if(user == address(0)) return;
        uint256 poolIdUint256 = uint256(PoolId.unwrap(poolId));
        _mint(user, poolIdUint256, points, "");
    }

    function _getFee() interal view returns(uint16 _fee){
        _fee = dynamicFee == 0 ? baseFee : dynamicFee;
    }
}
