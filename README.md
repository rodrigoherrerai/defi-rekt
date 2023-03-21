# DEFI-REKT 

### Reproduction of historical Defi and general  hacks on EVM chains using Foundry

</br>
</br>


## Acknowledgments
- This repo is inspired by [learn-evm-attacks](https://github.com/coinspect/learn-evm-attacks), although the main difference is that this repository focuses primarily on hacks that are historical (some of them very old "parity wallet").



## Reproduce 
1. Clone the repo
```bash
git clone https://github.com/rodrigoherrerai/defi-rekt.git
```
2. Build (inside the repo)
```bash
forge build
```
3. Reproduce an attack
```bash
forge test --match-path test/..
```



