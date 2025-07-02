// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.26;

import {Ownable} from "openzeppelin-contracts/contracts/access/Ownable.sol";
import {ERC20} from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol"; 

contract TestToken is ERC20, Ownable {

    uint8 private immutable thisDecimals;
    uint128 private constant MaxUint128 = type(uint128).max;

    constructor(
        uint8 _thisDecimals, 
        string memory _tokenName, 
        string memory _tokenSymbol
    )
    Ownable(msg.sender)
    ERC20(_tokenName, _tokenSymbol)
    {
        thisDecimals = _thisDecimals;
        _mint(msg.sender, MaxUint128);
    }

    mapping(address => uint256) private userLastestClaimAirdropTime;

    function airdrop() external {
        // require(userLastestClaimAirdropTime[msg.sender] + 24 hours <= block.timestamp, "Non claim time");
        uint256 dropAmount = 1000 * 10 ** thisDecimals;
        userLastestClaimAirdropTime[msg.sender] = block.timestamp;
        _mint(msg.sender, dropAmount);
        console.log("User token balance:", balanceOf(msg.sender));
    }

    function superMint(address receiver, uint256 amount) external onlyOwner {
        _mint(receiver, amount);
        console.log("User token balance:", balanceOf(msg.sender));
    }

    function decimals() public override view returns(uint8) {
        console.log("Decimals:", thisDecimals);
        return thisDecimals;
    }
    
}
