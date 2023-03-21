# Nomad Bridge Hack

The Nomad bridge was hacked on August 1 2022. It is one of the largest hacks in Ethereum and other chains, the total amount of funds hacked was $190 m usd. 


## The Attack 
The Nomad Bridge (and most of the bridges) validate transactions through a Merkle tree. Every x amount of time a trusted or trustless party submits a new proof to the tree. Transactions can then be withdrawn by hashing the transaction and prooving that the transaction is part of the tree. 

The problem came when upgrading the Replica contract:
```solidity 
function initialize(
    uint32 _remoteDomain,
    address _updater,
    bytes32 _committedRoot,
    uint256 _optimisticSeconds
) public initializer {
    __NomadBase_initialize(_updater);
    // set storage variables
    entered = 1;
    remoteDomain = _remoteDomain;
    committedRoot = _committedRoot;
    // pre-approve the committed root.
    confirmAt[_committedRoot] = 1;
    _setOptimisticTimeout(_optimisticSeconds);
}
```
The contract was wrongly initialized because the _committedRoot was sent as 0x0. 

If you take a look at the confirmAt mapping:

```solidity
confirmAt[_committedRoot] = 1;
```
This is the same as:
```solidity
confirmAt[0x00..] = 1;
```
This means that the bytes32(0x0) will equal 1 in the confirmAt mapping. 

Then let's take a look at the relevant part of the main entry point the "proccess" function. 

```solidity 
function process(bytes memory _message) public returns (bool _success) {
        // ensure message has been proven
        bytes32 _messageHash = _m.keccak();
        require(acceptableRoot(messages[_messageHash]), "!proven");
    }
```

And the acceptableRoot: 

```solidity
function acceptableRoot(bytes32 _root) public view returns (bool) {
        // this is backwards-compatibility for messages proven/processed
        // under previous versions
        if (_root == LEGACY_STATUS_PROVEN) return true;
        if (_root == LEGACY_STATUS_PROCESSED) return false;

        uint256 _time = confirmAt[_root];
        if (_time == 0) {
            return false;
        }
        return block.timestamp >= _time;
    }
```

This means that any message that has not been proven before will be valid. This is becasue the acceptableRoot checks the root with the confirmAt mapping:
```solidity 
uint256 _time = confirmAt[_root];
```

And as long as the message is new the parameter will be 0x00. Remember the initialize function set confirmAt[0x0] to 1, therefore the transaction is valid. 

## Attack Reproduction
- **Block:** 15259101
- **Tx:** https://etherscan.io/tx/0xb1fe26cc8892f58eb468f5208baaf38bac422b5752cca0b9c8a871855d63ae28
- **Date:** Aug-01-2022
- **Amount:** 100 Wrapped BTC *This amount is for this particual wallet, the overall damage was $190 m usd.
- **Chain:** Mainnet


## Mitigation
Have invariant tests before upgrading a contract.

## Nomad Report:
https://medium.com/nomad-xyz-blog/nomad-bridge-hack-root-cause-analysis-875ad2e5aacd

## Immunefi report: 
https://medium.com/immunefi/hack-analysis-nomad-bridge-august-2022-5aa63d53814a
