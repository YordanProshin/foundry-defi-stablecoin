//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
 * @title OracleLib
 * @author @Yordan Proshin
 * @notice This library is used to check the Chainlink Oracle for state data.
 * If a price is stale, the function will revert, and render the DSCEngine unusable - this is by design.
 * We want the DSCEngine to freeze if price becomes stale.
 * 
 * So if the Chainlink network explodes and you have a lot of money locked in the protocol...
 */

/** Imports */
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library OracleLib 
{
    /** Errors */
    error OracleLib__StalePrice();

    /** Constants */
    uint256 private constant TIMEOUT = 3 hours;

    /** Functions */
    function staleCheckLatestRoundData(AggregatorV3Interface priceFeed) public view returns(uint80, int256, uint256, uint256, uint80)
    {
        (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )=priceFeed.latestRoundData();

        uint256 secondsSince = block.timestamp - updatedAt;
        if(secondsSince > TIMEOUT) revert OracleLib__StalePrice();
        return (roundId, answer, startedAt, updatedAt, answeredInRound);
    }
}