# Ploutos Capital ICO: LUNA

This repo holds the smart contract that governs the fund.

## TODO

- [x] Setup ERC 20 token
  - [x] Patch balanceOf to include custom dividend logic
  - [x] Patch transfer to include custom dividend logic
- [x] Add ICO functionality
  - [x] Register limits (time frame, hard cap)
  - [x] Add participation function
- [x] Add dividend functionality
  - [x] Calculate how much tokens to distribute as dividends
  - [x] Register new dividend period with added tokens + token supply (including burned tokens)
  - [x] Implement pure helper that traverses all divididend periods to figure out owed dividends
  - [ ] Add drip
- [x] Add function to burn tokens (will only be used by us when the fund buys all remaning "on sale "tokens)
  - [x] Burn
  - [x] Subtract from global token supply, aum and user balance