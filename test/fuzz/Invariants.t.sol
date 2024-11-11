// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18; 

import {Test, console} from "forge-std/Test.sol";
import {StdInvariant} from "forge-std/StdInvariant.sol";
import {DeployDSC} from "../../script/DeployDSC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {DSCEngine} from "../../src/DSCEngine.sol";
import {DecentralisedStableCoin} from "../../src/DecentralisedStableCoin.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Handler} from "./Handler.t.sol";

contract InvariantsTest is StdInvariant, Test{
    /** Variables */
    DeployDSC deployer;
    DSCEngine engine;
    HelperConfig config;
    DecentralisedStableCoin dsc;
    address weth;
    address wbtc;
    Handler handler;

    /** Functions */
    function setUp() external {
        deployer = new DeployDSC();
        (dsc, engine, config) = deployer.run();
        (,, weth, wbtc,) = config.activeNetworkConfig();

        handler = new Handler(engine, dsc);
        targetContract(address(handler));
    }

    /**
     * @notice This test will be called after all the functions from the handler are called and didn't revert.
     */
    function invariant_protocolMustHaveMoreValueThanTotalSupply() public view  {
        uint256 totalSupply = dsc.totalSupply();
        uint256 totalWethDeposited = IERC20(weth).balanceOf(address(engine));
        uint256 totalWbtcDeposited = IERC20(wbtc).balanceOf(address(engine));

        uint256 storedWethValue = engine.getUsdValue(weth, totalWethDeposited);
        uint256 storedWbtcValue = engine.getUsdValue(wbtc, totalWbtcDeposited);

        console.log("Stored WETH Value: ", storedWethValue);
        console.log("Stored WBTC Value: ", storedWbtcValue);
        console.log("Total Supply: ", totalSupply);
        console.log("Times mint is called: ", handler.timesMintIsCalled());

        assert(storedWethValue + storedWbtcValue >= totalSupply);
    }

    function invariant_gettersShouldNotRevert() public view
    {
        engine.getLiquidationBonus();
        engine.getPrecision();
    }
}