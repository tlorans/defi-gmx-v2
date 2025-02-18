// SPDX-License-Identifier: MIT
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
}
