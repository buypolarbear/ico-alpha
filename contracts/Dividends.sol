pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';

contract Dividends is BasicToken {
  address owner;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint256 public decimals = 18;


  uint256 public pointsMultiplier = 10e18;
  uint256 public tokensIssued = 3000;
  uint256 public AUM = 6000;
  uint256 public tokensFrozen = tokensIssued * 3;

  function Dividends() public {
    owner = msg.sender;
  }

  function calculate(uint256 profit) public returns (uint256) {
    // profit in USD
    uint256 newAUM = AUM + profit;
    uint256 newTokenValue = (newAUM * 10e10) / (tokensIssued * 10e2); // 8 sig digits
    uint256 dividends = (profit * 10e16) / newTokenValue; // 8 sig digits
    return dividends;
  }
}