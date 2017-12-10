pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/StandardToken.sol';

contract Ico is StandardToken {

  address owner;
  address[] team;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint public decimals = 18;

  uint public constant HARD_CAP = 10000;
  
  uint public tokensIssued;
  uint public tokensFrozen;
  
  uint public tokensPerETH;

  uint public tokenSaleDeadline;


  function Ico() {
    owner = msg.sender;
  }


  /**
   * Modifiers
   */
  modifier onlyOwner() {
    require (msg.sender == owner);
    _;
  }

  modifier duringICO() {
    require (block.number <= tokenSaleDeadline);
    _;
  }

  modifier afterICO() {
    require (block.number > tokenSaleDeadline);
    _;
  }


  /**
   * 
   */
  function create(uint _tokensPerETH, address[] _team) onlyOwner returns (bool) {

    return true;
  }

  /**
   * Function allowing investors to participate in the ICO. 
   * Fund tokens will be distributed based on amount of ETH sent by investor, and calculated
   * using tokensPerETH value.
   */
  function participate() public payable duringICO returns (bool) {

    return true;
  }

  /**
   * Withdraw ICO funds from smart contract.
   */
  function withdraw() public onlyOwner returns (bool) afterICO {

    return true;
  }

  /**
   * Withdraw all funds and kill fund smart contract
   */
  function liquidate() returns (bool) {
    // self destruct
    return true;
  }
  
}
