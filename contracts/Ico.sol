pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract Ico is StandardToken {

  address owner;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint public decimals = 18;

  uint public SUPPLY = 10000 ether;

  function Ico() {
    owner = msg.sender;

    uint mikesPremine = 15 ether;

    totalSupply = SUPPLY;
    balances[owner] = SUPPLY - mikesPremine;
    balances[0x0d1d4e623D10F9FBA5Db95830F7d3839406C6AF2] = mikesPremine;
  }

  function sayHi() pure returns (string)  {
    return "hello";
  }
}