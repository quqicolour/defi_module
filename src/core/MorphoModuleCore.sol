//SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import {IMorpho, MarketParams, Position, Market, Authorization, Id} from "../interfaces/morpho/IMorpho.sol";
import {IMorphoReward} from "../interfaces/morpho/IMorphoReward.sol";
import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";

contract MorphoModuleCore is Ownable{
    using SafeERC20 for IERC20;

    address public morphoMarket;

    constructor(address newOwner, address newMorphoMarket) Ownable(newOwner) {
        morphoMarket = newMorphoMarket;
    }

    function setMorphoMarket(address newMorphoMarket) external onlyOwner {
        morphoMarket = newMorphoMarket;
    }

    /**
     * @notice  .The other Token incentives corresponding to the Morpho market selected for application
     * @param   morphoReward  .
     * @param   rewardProxyReceiver  .
     * @param   morphoRewardAddress  .
     * @param   claimable  .
     * @param   proof  .
     */
    function claimMorphoReward(
        address morphoReward,
        address rewardProxyReceiver,
        address morphoRewardAddress,
        uint256 claimable,
        bytes32[] calldata proof
    ) external onlyOwner {
        IMorphoReward(morphoReward).claim(
            rewardProxyReceiver,
            morphoRewardAddress,
            claimable,
            proof
        );
    }

    /**
     * @notice  .The user authorizes their assets to the current contract.
     * By default, the "shares" value is 0. These assets are then supplied to the Morpho market.
     * @dev     .Supplied to Morpho Market
     * @param   marketParams  .
     * @param   asset  .
     * @param   receiver  .
     * @param   amount  .
     * @param   shares  .
     * @return  state  .
     */
    function _morphoSupply(
        MarketParams calldata marketParams,
        address asset,
        address receiver,
        uint256 amount,
        uint256 shares
    ) internal returns (bool state) {
        IERC20(marketParams.loanToken).approve(morphoMarket, amount);
        IMorpho(morphoMarket).supply(
            marketParams,
            amount,
            shares,
            receiver,
            hex""
        );
        state = true;
    }

    /**
     * @notice  .Retrieve assets from Morpho market
     * @dev     .Obtain the position information through the getPosition() method
     * @param   marketParams  .
     * @param   onBehalf  .
     * @param   receiver  .
     * @param   amount  .
     * @param   shares  .
     * @return  state  .
     */
    function _morphoWithdraw(
        MarketParams calldata marketParams,
        address onBehalf,
        address receiver,
        uint256 amount,
        uint256 shares
    ) internal returns (bool state) {
        IMorpho(morphoMarket).withdraw(
            marketParams,
            amount,
            shares,
            onBehalf,
            receiver
        );
        state = true;
    }

    /**
     * @notice  .Obtain the parameters of the MarketParams structure from Id
     * @dev     .Morpho docs: https://docs.morpho.org/borrow/functions/position/#market-parameters
     * @param   morphoId  .
     * @return  MarketParams  .
     */
    function getIdToMarketParams(
        Id morphoId
    ) public view returns (MarketParams memory) {
        return IMorpho(morphoMarket).idToMarketParams(morphoId);
    }

    /**
     * @notice  .Obtain the position information of the user in the Morpho Market
     * @dev     .If the user has corresponding assets, the quantity of their collateral and share will be displayed.
     * @param   morphoId  .
     * @param   user  .
     * @return  Position  .
     */
    function getPosition(
        Id morphoId,
        address user
    ) external view returns (Position memory) {
        return IMorpho(morphoMarket).position(morphoId, user);
    }

    /**
     * @notice  .Obtain market information based on morpho id
     * @dev     .Morpho docs: https://docs.morpho.org/borrow/getting-started
     * @param   morphoId  .
     * @return  market  .
     */
    function getMarket(
        Id morphoId
    ) external view returns (Market memory market) {
        market = IMorpho(morphoMarket).market(morphoId);
    }
}
