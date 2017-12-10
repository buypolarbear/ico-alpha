pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';

// NOTE: BasicToken only has partial ERC20 support
contract Ico is BasicToken {

  address owner;
  address[] team;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint8 public decimals = 18;

  uint256 public constant HARD_CAP = 10000 ether;
  
  uint256 public tokensIssued;
  uint256 public tokensFrozen;
  
  uint256 public tokensPerEth;

  uint public icoStart;
  uint public icoEnd;


  /**
   * ICO constructor
   * Define ICO details and contribution period
   */
  function Ico(uint256 _icoStart, uint256 _icoEnd, address[] _team, uint256 _tokensPerEth) {
    require(_icoStart >= now);
    require(_icoEnd >= _icoStart);
    require(_tokensPerEth > 0);

    owner = msg.sender;
    
    icoStart = _icoStart;
    icoEnd = _icoEnd;
    tokensPerEth = _tokensPerEth;
    team = _team;

    tokensIssued = 0;
    tokensFrozen = 0;
  }


  /**
   * Modifiers
   */
  modifier onlyOwner() {
    require (msg.sender == owner);
    _;
  }

  // helper function that makes sure we add dividend before any
  // type of ledger mutation.
  modifier addDividend() {
    uint256 owedDividend = getOwedDividend(msg.sender);
    if(owedDividend > 0) {
      balances[msg.sender] = balances[msg.sender].add(owedDividend);
    }
    _;
  }


  /**
   * Function allowing investors to participate in the ICO. 
   * Fund tokens will be distributed based on amount of ETH sent by investor, and calculated
   * using tokensPerEth value.
   */
  function participate() public payable returns (bool) {
    require (now >= icoOpen && now <= icoClose);
    // todo
    return true;
  }

  /**
   * Withdraw ICO funds from smart contract.
   */
  function withdraw() public onlyOwner returns (bool) {
    require (now > icoEnd);
    // todo
    return true;
  }

  /**
   * Withdraw all funds and kill fund smart contract
   */
  function liquidate() returns (bool) {
    // todo: self destruct
    return true;
  }

  // getter to retrieve divident owed
  function getOwedDividend(address _owner) public view returns (uint256 balance) {
    // todo @ale
    return 1 ether;
  }

  // monkey patches
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return BasicToken.balanceOf(_owner).add(getOwedDividend(_owner));
  }
  function transfer(address _to, uint256 _value) addDividend() public returns (bool) {
    return BasicToken.transfer(_to, _value);
  }

}
