// SPDX-License-Identifier: MIT
pragma solidity <0.9.0;

interface IFastUpdater {
    function fetchCurrentFeeds(
        uint256[] calldata _feedIndexes
    )
        external
        view
        returns (
            uint256[] memory _feedValues,
            int8[] memory _decimals,
            uint64 _timestamp
        );
}

/**
 * THIS IS AN EXAMPLE CONTRACT.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */

contract FtsoV2ChangeQuoteFeed {
    IFastUpdater internal ftsoV2;

    /**
     * Network: Coston
     * Address: 0x9B931f5d3e24fc8C9064DB35bDc8FB4bE0E862f9
     */
    constructor() {
        ftsoV2 = IFastUpdater(0x9B931f5d3e24fc8C9064DB35bDc8FB4bE0E862f9);
    }

    function _scaleBaseFeedValue(
        uint256 _baseFeedValue,
        uint8 _baseFeedDecimals,
        uint8 _quoteDecimals
    ) internal pure returns (uint256) {
        uint _scaledBasedFeedValue;
        if (_baseFeedDecimals < _quoteDecimals) {
            // If base feed decimals are less than quote feed decimals, scale up
            _scaledBasedFeedValue =
                _baseFeedValue *
                10 ** uint256(_quoteDecimals - _baseFeedDecimals);
        } else if (_baseFeedDecimals > _quoteDecimals) {
            // If base feed decimals are more than quote feed decimals, scale down
            _scaledBasedFeedValue =
                _baseFeedValue /
                10 ** uint256(_baseFeedDecimals - _quoteDecimals);
        } else {
            // If base feed decimals are equal to quote feed decimals, return as is
            _scaledBasedFeedValue = _baseFeedValue;
        }
        return _scaledBasedFeedValue;
    }

    function getNewQuoteFeedValue(
        uint256[] calldata _baseAndQuoteFeedIndexes
    ) public view returns (uint256) {
        require(
            _baseAndQuoteFeedIndexes.length == 2,
            "invalid _baseAndQuoteFeedIndexes, should be of length 2"
        );
        // Fetch the current feed values and decimals of the base and quote feeds
        (
            uint256[] memory feedValues,
            int8[] memory decimals,
            /* uint64 timestamp */
        ) = ftsoV2.fetchCurrentFeeds(_baseAndQuoteFeedIndexes);

        // Set the new quote decimals to the quote feed decimals
        uint8 _newQuoteDecimals = uint8(decimals[1]);
        // Scale the base feed value to the new quote decimals
        uint256 scaledBaseFeedValue = _scaleBaseFeedValue(
            feedValues[0],
            uint8(decimals[0]),
            _newQuoteDecimals
        );
        // Calculate the new quote feed value
        uint256 newQuoteFeedValue = (scaledBaseFeedValue *
            10 ** uint256(_newQuoteDecimals)) / feedValues[1];
        return newQuoteFeedValue;
    }
}
