//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import {IAaveModuleCore} from "../interfaces/core/IAaveModuleCore.sol";

import {IPool} from "../interfaces/aave/IPool.sol";
import {IAaveProtocolDataProvider} from "../interfaces/aave/IAaveProtocolDataProvider.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract AaveModuleCore is Ownable, IAaveModuleCore {
    using SafeERC20 for IERC20;

    uint16 private referralCode;
    address public aaveProtocolDataProvider;
    constructor(
        address newOwner,
        address newAaveProtocolDataProvider
    ) Ownable(newOwner) {
        aaveProtocolDataProvider = newAaveProtocolDataProvider;
    }

    mapping(uint256 => AaveInfo) private aaveInfo;

    /**
     * @notice  .Administrators set the Aave information through id
     * @dev     .Obtain the corresponding AaveV3 information by passing in the id,
     * reduce the attacks caused by the passing in of external addresses, and optimize gas
     * @param   id  .
     * @param   pool  .
     * @param   asset  .
     * @param   aToken  .
     * @param   state  .
     */
    function setAaveInfo(
        uint256 id,
        address pool,
        address asset,
        address aToken,
        bool state
    ) external onlyOwner {
        aaveInfo[id] = AaveInfo({
            pool: pool,
            asset: asset,
            aToken: aToken,
            state: state
        });
        emit UpdateAaveInfo(id);
    }

    /**
     * @notice  .The administrator sets some other configuration information of Aave
     * @dev     .
     * @param   newReferralCode  .The current default configuration of Aavev3 is 0
     * @param   newAaveProtocolDataProvider  .AaveProtocolDataProvider contract address
     */
    function setAaveOtherInfo(
        uint16 newReferralCode,
        address newAaveProtocolDataProvider
    ) external onlyOwner {
        referralCode = newReferralCode;
        aaveProtocolDataProvider = newAaveProtocolDataProvider;
    }

    /**
     * @notice  .Deposit the corresponding tokens in the LP pool into AaveV3 to earn interest,
     * thereby enhancing the utilization rate of capital
     * @dev     .Deposit the Token into the corresponding pool of AaveV3
     * @param   id  .
     * @param   amount  .
     * @return  state  .
     */
    function _aaveSupply(
        uint256 id,
        uint256 amount
    ) internal returns (bool state) {
        require(aaveInfo[id].state, "Invalid aave state");
        address asset = aaveInfo[id].asset;
        require(getAavePoolPaused(asset) == false, "Aave pool paused");
        address aavePool = aaveInfo[id].pool;
        IERC20(asset).approve(aavePool, type(uint256).max);
        IPool(aavePool).deposit(asset, amount, address(this), referralCode);
        IERC20(asset).approve(aavePool, 0);
        state = true;
    }

    /**
     * @notice  .The internal extraction method of AaveV3 authorizes the maximum number of AToken to AavePool.
     *  After execution, the authorization is cancelled.
     * @dev     .Whatever assets are deposited, the corresponding assets will also be retrieved when withdrawn.
     * @param   id  .
     * @param   amount  .
     * @return  state  .
     */
    function _aaveWithdraw(
        uint256 id,
        uint256 amount
    ) internal returns (bool state) {
        require(aaveInfo[id].state, "Invalid aave state");
        address asset = aaveInfo[id].asset;
        require(getAavePoolPaused(asset) == false, "Aave pool paused");
        address aToken = aaveInfo[id].aToken;
        address aavePool = aaveInfo[id].pool;
        IERC20(aToken).approve(aavePool, type(uint256).max);
        IPool(aavePool).withdraw(asset, amount, address(this));
        IERC20(aToken).approve(aavePool, 0);
        state = true;
    }

    /**
     * @dev     .Obtain the corresponding AaveInfo structure information based on the id set by the administrator
     * @param   id  .
     * @return  AaveInfo  .
     */
    function getAaveInfo(uint256 id) external view returns (AaveInfo memory) {
        return aaveInfo[id];
    }

    /**
     * @notice  .Find out whether the Aave pool is in a suspended state. If true, it is suspended; if false, it is open
     * @dev     .It is used to determine whether the current pool is available.
     * When it is not available, it will inform the user on the front end that the current pool has been suspended
     * @param   asset  .
     * @return  isPaused  .
     */
    function getAavePoolPaused(
        address asset
    ) public view returns (bool isPaused) {
        isPaused = IAaveProtocolDataProvider(aaveProtocolDataProvider)
            .getPaused(asset);
    }

    // struct PackInputParams{
    //     address user;
    //     address asset;
    // }

    //  

    // /**
    //  * @notice  .Obtain the user's Token reserve information on AaveV3
    //  * @dev     .It is used for front-end UI display and back-end monitoring
    //  * @param   params  .Package the user address and token address into the structure PackInputParams
    //  * @return  currentATokenBalance  .
    //  * @return  currentStableDebt  .
    //  * @return  currentVariableDebt  .
    //  * @return  principalStableDebt  .
    //  * @return  scaledVariableDebt  .
    //  * @return  stableBorrowRate  .
    //  * @return  liquidityRate  .
    //  * @return  stableRateLastUpdated  .
    //  * @return  usageAsCollateralEnabled  .
    //  */
    // function getUserAaveReserveData(
    //     PackInputParams calldata params
    // )
    //     external
    //     view
    //     returns (
    //         uint256 currentATokenBalance,
    //         uint256 currentStableDebt,
    //         uint256 currentVariableDebt,
    //         uint256 principalStableDebt,
    //         uint256 scaledVariableDebt,
    //         uint256 stableBorrowRate,
    //         uint256 liquidityRate,
    //         uint40 stableRateLastUpdated,
    //         bool usageAsCollateralEnabled
    //     )
    // {
    //     (
    //         currentATokenBalance,
    //         currentStableDebt,
    //         currentVariableDebt,
    //         principalStableDebt,
    //         scaledVariableDebt,
    //         stableBorrowRate,
    //         liquidityRate,
    //         stableRateLastUpdated,
    //         usageAsCollateralEnabled
    //     ) = IAaveProtocolDataProvider(aaveProtocolDataProvider)
    //         .getUserReserveData(params.asset, params.user);
    // }
}
