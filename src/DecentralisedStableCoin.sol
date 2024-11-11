//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/** Imports */
import {ERC20Burnable, ERC20} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/** 
* @title DecentralisedStableCoin
* @author Yordan Proshin
* Collateral: Exogenous (ETH & BTC)
* Minting: Decentralised (Algorithmic)
* Relative Stability: Pegged to USD
*
* This is the contract meant to be governed by DSCEngine. This contract is just the ERC20 Implementation of our stablecoin system.
* 
*/

contract DecentralisedStableCoin is ERC20Burnable, Ownable
{
    /** Errors */
    error DecentralisedStableCoin__MustBeMoreThanZero();
    error DecentralisedStableCoin__BurnAmountExceedsBalance();
    error DecentralisedStableCoin__NotZeroAddress();

    constructor() ERC20("DecentralisedStableCoin", "DSC") Ownable(msg.sender) {}

    function burn(uint256 _amount) public override onlyOwner
    {
        uint256 balance = balanceOf(msg.sender);
        if(_amount<0)
        {
            revert DecentralisedStableCoin__MustBeMoreThanZero();
        }
        if(balance < _amount)
        {
            revert DecentralisedStableCoin__BurnAmountExceedsBalance();
        }
        super.burn(_amount);
    }

    function mint(address _to, uint256 _amount) external onlyOwner returns(bool)
    {
        if(_to==address(0))
        {
            revert DecentralisedStableCoin__NotZeroAddress();
        }
        if(_amount<=0)
        {
            revert DecentralisedStableCoin__MustBeMoreThanZero();
        }
        _mint(_to, _amount);
            return true;
    }
}