// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint) {
        (, int priceOneEthInUsd, , , ) = priceFeed.latestRoundData();

        // price is 1 ether in USD with priceFeedDecimals (currently 8) decimals
        uint priceFeedDecimals = priceFeed.decimals();

        // 1 ether = 10^18 wei = 1,000,000,000,000,000,000 wei
        // difference in precision is 18 - priceFeedDecimals (currently 10)
        uint differenceInPrecision = 18 - priceFeedDecimals;

        // price must be multiplied by 10^differenceInPrecision
        uint precisionCorrection = 10 ** differenceInPrecision;

        return uint(priceOneEthInUsd) * precisionCorrection;

        // less verbose version:
        // return uint(priceOneEthInUsd) * 10000000000);
    }

    function getConversionRate(uint ethAmountInWei, AggregatorV3Interface priceFeed) internal view returns (uint) {
        uint ethPriceInWei = getPrice(priceFeed);
        uint ethAmountInUsd = (ethAmountInWei * ethPriceInWei) / 1 ether;
        return ethAmountInUsd;
    }

}
