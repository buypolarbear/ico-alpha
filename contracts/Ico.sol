pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract Fund is StandardToken {
  address owner;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint public decmials = 18;


  uint public SUPPLY = 10000;

  function Fund() {
    owner = msg.sender;

    totalSupply = SUPPLY;
    balances[owner] = SUPPLY;
  }
}