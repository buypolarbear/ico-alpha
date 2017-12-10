pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract Dividends is StandardToken {
  address owner;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint public decimals = 18;


  uint public tokensIssued = 10000 ether;
  uint public tokensFrozen = tokensIssued * 3;

  function Dividends() public {
    owner = msg.sender;
  }

  function calculate(uint256 profit) public returns (uint256) {
    // profit in finney
    uint256 totalDividends = tokensIssued * (profit / 2);
    uint256 airdrop = totalDividends / ((tokensIssued + totalDividends) / totalDividends);
    return airdrop * 3;
  }
}