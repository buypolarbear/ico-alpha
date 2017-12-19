# Ploutos Capital ICO: LUNA

LUNA is a fund that provides a diversified exposure to the crypto market. On top of that we will use a part of the fund as liquidity for low risk automated trading (such as arbitrage, market making, peer-2-peer lending).

A detailed description of the inner workings of the fund can be found in this [Google Document](https://docs.google.com/document/d/1jeSXiOAseB7f980nNuey3_1b7SlJq0UknJzW--qYJWA/edit?usp=sharing).

Stake in the LUNA fund will be managed through an ERC20 token, the underlying governing smart contract is stored in this repo (github.com/ploutos-capital/ico-alpha) ([contracts/Ico.sol](https://github.com/ploutos-capital/ico-alpha/blob/master/contracts/Ico.sol)).

## Smart contract TODO

- [x] Setup ERC 20 token
  - [x] Patch balanceOf to include custom dividend logic
  - [x] Patch transfer to include custom dividend logic
- [x] Add ICO functionality
  - [x] Register limits (time frame, hard cap)
  - [x] Add participation function (+ fallback)
- [x] Add dividend functionality
  - [x] Calculate how much tokens to distribute as dividends
  - [x] Register new dividend period with added tokens + token supply (including burned tokens)
  - [x] Implement pure helper that traverses all divididend periods to figure out owed dividends
  - [x] Add drip
- [x] Add function to burn tokens (will only be used by us when the fund buys all remaning "on sale "tokens)
  - [x] Burn
  - [x] Subtract from global token supply, aum and user balance

## Deployment and testing

- [x] Test locally on a private blockchain
  - [x] Basic functionality
  - [x] Dividend calculations
  - [x] Security
- [x] Test on Ropsten (public Ethereum testnet)
  - [x] Basic functionality
  - [x] Dividend calculations
  - [x] Security
- [ ] Launch contract on main net

## Install development environment

    # cd into this cloned repo
    cd ico-alpha
    # install truffle
    npm i -g truffle
    # install project dependencies
    npm i
    # start truffle dev blockchain
    truffle develop
    # on the develop commandline, compile & run the contract
    migrate --reset
