// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IRoleStore} from "../src/interfaces/IRoleStore.sol";
import {IChainlinkDataStreamProvider} from
    "../src/interfaces/IChainlinkDataStreamProvider.sol";
import {IOracle} from "../src/interfaces/IOracle.sol";
import {IPriceFeed} from "../src/interfaces/IPriceFeed.sol";
import {OracleUtils} from "../src/types/OracleUtils.sol";
import {Price} from "../src/types/Price.sol";
import {
    ROLE_STORE,
    CHAINLINK_DATA_STREAM_PROVIDER,
    ORACLE
} from "../src/Constants.sol";
import "../src/lib/Errors.sol";

function add(uint256 x, int256 y) pure returns (uint256) {
    return y >= 0 ? x + uint256(y) : x - uint256(-y);
}

contract TestHelper is Test {
    IRoleStore constant roleStore = IRoleStore(ROLE_STORE);
    IOracle constant oracle = IOracle(ORACLE);
    IChainlinkDataStreamProvider constant provider =
        IChainlinkDataStreamProvider(CHAINLINK_DATA_STREAM_PROVIDER);

    mapping(string => uint256) public vals;

    function set(string memory key, uint256 val) public {
        vals[key] = val;
    }

    function get(string memory key) public view returns (uint256) {
        return vals[key];
    }

    function getRoleMember(bytes32 key) public view returns (address) {
        address[] memory addrs = roleStore.getRoleMembers(key, 0, 1);
        return addrs[0];
    }

    struct OracleParams {
        address chainlink;
        // Multiplier to make chainlink price x token amount have 30 decimals
        uint256 multiplier;
        int256 deltaPrice;
    }

    function mockOraclePrices(
        address[] memory tokens,
        address[] memory providers,
        bytes[] memory data,
        OracleParams[] memory oracles
    ) public returns (uint256[] memory prices) {
        uint256 n = tokens.length;

        prices = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            (, int256 answer,,,) =
                IPriceFeed(oracles[i].chainlink).latestRoundData();
            prices[i] = uint256(answer) * oracles[i].multiplier
                * add(100, oracles[i].deltaPrice) / 100;
        }

        for (uint256 i = 0; i < n; i++) {
            vm.mockCall(
                address(provider),
                abi.encodeCall(
                    IChainlinkDataStreamProvider.getOraclePrice,
                    (tokens[i], data[i])
                ),
                abi.encode(
                    OracleUtils.ValidatedPrice({
                        token: tokens[i],
                        min: prices[i] * 999 / 1000,
                        max: prices[i] * 1001 / 1000,
                        // NOTE: oracle timestamp must be >= order updated timestamp
                        timestamp: block.timestamp,
                        provider: providers[i]
                    })
                )
            );
        }
    }
}
