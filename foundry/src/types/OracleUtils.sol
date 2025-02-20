// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.26;

import {Price} from "./Price.sol";

library OracleUtils {
    struct SetPricesParams {
        address[] tokens;
        address[] providers;
        bytes[] data;
    }

    struct SimulatePricesParams {
        address[] primaryTokens;
        Price.Props[] primaryPrices;
        uint256 minTimestamp;
        uint256 maxTimestamp;
    }

    struct ValidatedPrice {
        address token;
        // 1e12 = 1 USD
        uint256 min;
        // 1e12 = 1 USD
        uint256 max;
        uint256 timestamp;
        address provider;
    }
}
