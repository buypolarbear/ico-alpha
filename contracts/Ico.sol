pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';

// NOTE: BasicToken only has partial ERC20 support
contract Ico is BasicToken {

  address owner;
  address[] team;

  // expose these for ERC20 tools
  string public constant name = "LUNA";
  string public constant symbol = "LUNA";
  uint8 public constant decimals = 18;

  // Significant digits multiplier
  uint256 private multiplier = 10e18;

  // TODO: set this final, this equates to an amount
  // in dollars.
  uint256 public constant HARD_CAP = 10000 ether;

  // Tokens issued and frozen supply to date
  uint256 public tokensIssued = 3000 * multiplier;
  uint256 public tokensFrozen = 18000 * multiplier;

  // struct representing a dividends snapshot
  struct DividendSnapshot {
    uint256 tokensIssued;
    uint256 dividendsIssued;
  }
  // An array of all the DividendSnapshot so far
  DividendSnapshot[] dividendSnapshots;

  // Mapping of user to the index of the last dividend that was awarded to zhie
  mapping(address => uint) lastDividend;

  // Assets under management in USD
  uint256 private aum = 6000 * multiplier;

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

    balances[0x0d1d4e623D10F9FBA5Db95830F7d3839406C6AF2] = 100 * multiplier;

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
      lastDividend[msg.sender] = dividendSnapshots.length;
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
   * Calculate the divends for the current period given the AUM profit
   */
  function setDividends(uint256 profit) public onlyOwner {
    // profit in USD
    profit = profit.mul(multiplier);
    uint256 newAum = aum.add(profit);
    uint256 newTokenValue = newAum.mul(multiplier).div(tokensIssued); // 18 sig digits
    uint256 dividendsIssued = profit.mul(multiplier).div(newTokenValue); // 18 sig digits

    // make sure we have enough in the frozen fund
    require(tokensFrozen >= dividendsIssued);

    dividendSnapshots.push(DividendSnapshot(tokensIssued, dividendsIssued));

    // add the previous amount of given dividends to the tokensIssued
    tokensIssued = tokensIssued.add(dividendsIssued);
    tokensFrozen = tokensFrozen.sub(dividendsIssued);
    aum = newAum;

  }

  /**
   * Withdraw all funds and kill fund smart contract
   */
  function liquidate() public onlyOwner returns (bool) {
    selfdestruct(owner);
  }


  // getter to retrieve divident owed
  function getOwedDividend(address _owner) public view returns (uint256 dividend) {
    // And the address' current balance
    uint256 balance = BasicToken.balanceOf(_owner);
    // retrieve index of last dividend this address received
    // NOTE: the default return value of a mapping is 0 in this case
    uint idx = lastDividend[_owner];
    if (idx == dividendSnapshots.length) return 0;
    if (balance == 0) return 0;

    uint256 currBalance = balance;
    for (uint i = idx; i < dividendSnapshots.length; i++) {
      // We should be able to remove the .mul(multiplier) and .div(multiplier) and apply them once
      // at the beginning and once at the end, but we need to math it out
      dividend += currBalance.mul(multiplier).div(dividendSnapshots[i].tokensIssued).mul(dividendSnapshots[i].dividendsIssued).div(multiplier);
      currBalance = balance + dividend;
    }

    return dividend;
  }

  // monkey patches
  function balanceOf(address _owner) public view returns (uint256) {
    return BasicToken.balanceOf(_owner).add(getOwedDividend(_owner));
  }

  function transfer(address _to, uint256 _value) addDividend() public returns (bool) {
    return BasicToken.transfer(_to, _value);
  }

}
