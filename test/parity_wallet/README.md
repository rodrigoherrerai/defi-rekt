# Parity Wallet Hack

The parity wallet attack was the second largest hack back then, the attacker stole over 150,000 ETH. 


## The Attack 
The attack was possible because the 'initWallet' function wasn't protected. This allowed the attacker to call the function after the wallet was already in use. 

``` solidity
function initWallet(address[] _owners, uint _required, uint _daylimit) {    
  initDaylimit(_daylimit);    
  initMultiowned(_owners, _required);  
}
```

Here you can find the wallet code: https://github.com/openethereum/parity-ethereum/blob/4d08e7b0aec46443bf26547b17d10cb302672835/js/src/contracts/snippets/enhanced-wallet.sol#L216


## Attack Reproduction
- **Block:** 4043802
- **Tx:** https://etherscan.io/tx/0xeef10fc5170f669b86c4cd0444882a96087221325f8bf2f55d6188633aa7be7c
- **Date:** July-19-2017
- **Amount:** 82,189 Ether *This amount is for this particual wallet, the overall damage was over 150k eth
- **Chain:** Mainnet


## Mitigation
The init wallet function should always be protected. This means that it should only be possible to call it once. This can be done by using an initializer modifier or just check that the owners are empty.

## Open Zeppelin report: 
https://blog.openzeppelin.com/on-the-parity-wallet-multisig-hack-405a8c12e8f7/
