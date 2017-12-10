pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';

// NOTE: BasicToken only has partial ERC20 support
contract Ico is BasicToken {

  address owner;
  address[] team;

  // expose these for ERC20 tools
  string public constant name = "TODO";
  string public constant symbol = "TODO";
  uint8 public constant decimals = 18;

  // TODO: set this final, this equates to an amount
  // in dollars.
  uint256 public constant HARD_CAP = 10000 ether;
  
  // Tokens issued and frozen supply to date
  uint256 public tokensIssued = 0;
  uint256 public tokensFrozen = 0;
  
  // number of tokens investors will receive per eth invested
  uint256 public tokensPerEth;

  // Ico start/end timestamps, between which (inclusively) investments are accepted
  uint public icoStart;
  uint public icoEnd;


  /**
   * ICO constructor
   * Define ICO details and contribution period
   */
  function Ico(uint256 _icoStart, uint256 _icoEnd, address[] _team, uint256 _tokensPerEth) {
    require (_icoStart >= now);
    require (_icoEnd >= _icoStart);
    require (_tokensPerEth > 0);

    owner = msg.sender;
    
    icoStart = _icoStart;
    icoEnd = _icoEnd;
    tokensPerEth = _tokensPerEth;
    team = _team;
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
    require (now >= icoStart && now <= icoEnd);
    require (msg.value > 0);

    uint256 ethAmount = msg.value;
    uint256 numTokens = ethAmount.mul(tokensPerEth);

    require(numTokens.add(tokensIssued) <= HARD_CAP);

    balances[msg.sender] = balances[msg.sender].add(numTokens);
    tokensIssued = tokensIssued.add(numTokens);
    tokensFrozen = tokensIssued * 2;

    owner.transfer(ethAmount);

    return true;
  }

  /**
   * Withdraw all funds and kill fund smart contract
   */
  function liquidate() onlyOwner returns (bool) {
    selfdestruct(owner);
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
