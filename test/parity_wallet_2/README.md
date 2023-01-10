# Parity Wallet Hack 2 a.k.a "I accidentally killed it."

After the first Parity wallet hack, a new version of the contract was deployed, containing another critical vulnerability.


## The Attack 
The attack was possible because the 'initWallet' function wasn't protected from the master contract.

Some context: Every time a new wallet is deployed, a proxy contract is what actually gets created, that delegates all calls to a master copy.

The attack or rather accident occured because someone initialized the master copy (singleton) and then killed it (calling the 'selfdestruct' or to be more precise, 'suicide' opcode).

This left all the proxies with a master copy without code, therefore making all wallets unusable.

See the comment that "killed it": https://github.com/openethereum/parity-ethereum/issues/6995



## Attack Reproduction
- **Block:** 4501969 
- **Tx:** https://etherscan.io/tx/0x47f7cff7a5e671884629c93b368cb18f58a993f4b19c2a53a8662e3f1482f690
- **Date:** Nov-06-2017
- **Amount:** Around 513,000 ETH
- **Chain:** Mainnet


## Mitigation
Protect the init function within the base contract implementation.

## Blog report: 
https://hackernoon.com/parity-wallet-hack-2-electric-boogaloo-e493f2365303
