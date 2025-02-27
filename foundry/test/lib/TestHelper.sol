// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {Test, console} from "forge-std/Test.sol";
import {IERC20} from "../../src/interfaces/IERC20.sol";
import {IRoleStore} from "../../src/interfaces/IRoleStore.sol";
import {IChainlinkDataStreamProvider} from
    "../../src/interfaces/IChainlinkDataStreamProvider.sol";
import {IOracle} from "../../src/interfaces/IOracle.sol";
import {IPriceFeed} from "../../src/interfaces/IPriceFeed.sol";
import {OracleUtils} from "../../src/types/OracleUtils.sol";
import {Price} from "../../src/types/Price.sol";
import {
    ROLE_STORE,
    CHAINLINK_DATA_STREAM_PROVIDER,
    ORACLE
} from "../../src/Constants.sol";
import "../../src/lib/Errors.sol";
import {Math} from "../../src/lib/Math.sol";

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
        // Multiplier to adjust decimals for index tokens which are EOA
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
            if (oracles[i].chainlink == address(0)) {
                prices[i] = 1e30;
                continue;
            }

            // (, int256 answer,,,) =
            //     IPriceFeed(oracles[i].chainlink).latestRoundData();
            int256 answer = 1e8;

            // Multiplier to make chainlink price x token amount have 30 decimals
            uint256 d = tokens[i].code.length > 0
                ? uint256(IERC20(tokens[i]).decimals())
                : 0;
            uint256 c = uint256(IPriceFeed(oracles[i].chainlink).decimals());
            uint256 multiplier = 10 ** (30 - c - d) * oracles[i].multiplier;

            prices[i] = uint256(answer) * multiplier
                * Math.add(100, oracles[i].deltaPrice) / 100;
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
