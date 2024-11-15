//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {ERC20Mock} from "../../test/mocks/ERC20Mock.sol";
import {MockV3Aggregator} from "test/mocks/MockV3Agregator.sol";

contract Handler is Test
    {
        /** Variables */
        DSCEngine dsce;
        DecentralisedStableCoin dsc;

        ERC20Mock weth;
        ERC20Mock wbtc;
        MockV3Aggregator ethUsdPriceFeed;
        address[] public usersWithCollateralDeposited;

        uint256 public timesMintIsCalled;

        uint256 MAX_DEPOSIT_SIZE = type(uint96).max;

        /** Functions */
        constructor(DSCEngine _dscEngine, DecentralisedStableCoin _decentralizedStableCoin) 
        {
        dsce = _dscEngine;
        dsc = _decentralizedStableCoin;

        address [] memory collateralTokens = dsce.getCollateralTokens();
        weth = ERC20Mock(collateralTokens[0]);
        wbtc = ERC20Mock(collateralTokens[1]);

        ethUsdPriceFeed=MockV3Aggregator(dsce.getCollateralTokenPriceFeed(address(weth)));
        }
        
        function mintDsc(uint256 amount, uint256 addressSeed) public
        {
            address sender=usersWithCollateralDeposited[addressSeed%usersWithCollateralDeposited.length];
            (uint256 totalDscMinted,uint256 collateralValueInUsd) = dsce.getAccountInformation(sender);

            uint256 maxDscToMint=((collateralValueInUsd/2))-totalDscMinted;
            
            if(maxDscToMint<0)
            {
                return;
            }
            
            amount=bound(amount, 0, uint256(maxDscToMint));
            if(amount == 0)
            {
                return;
            }

            vm.startPrank(msg.sender);
            dsc.mint(msg.sender, amount);
            vm.stopPrank();
            timesMintIsCalled++;
        }

        function depositCollateral(uint256 collateralSeed, uint256 amountCollateral) public
         {
            ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
            amountCollateral = bound(amountCollateral,1,MAX_DEPOSIT_SIZE);

            vm.startPrank(msg.sender);
            collateral.mint(msg.sender, amountCollateral);
            collateral.approve(address(dsce), amountCollateral);
            dsce.depositCollateral(address(collateral), amountCollateral);
            vm.stopPrank();
            usersWithCollateralDeposited.push(msg.sender);
         }

        function _getCollateralFromSeed(uint256 collateralSeed) private view returns(ERC20Mock)
         {
            if(collateralSeed % 2 == 0)
            {
                return weth;
            }
            else
            {
                return wbtc;
            }
        }

        function redeemCollateral(uint256 collateralSeed, uint256 amountCollateral) public
        {
            ERC20Mock collateral = _getCollateralFromSeed(collateralSeed);
            uint256 maxCollateralToRedeem= dsce.getCollateralBalanceOfUser(address(collateral), msg.sender);
            amountCollateral = bound(amountCollateral, 0 , maxCollateralToRedeem);
            if(amountCollateral == 0)
            {
                return;
            }
            dsce.redeemCollateral(address(collateral), amountCollateral);
        }
    }