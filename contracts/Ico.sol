pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';

// NOTE: BasicToken only has partial ERC20 support
contract Ico is BasicToken {
  address owner;
  uint256 public teamNum;
  mapping(address => bool) team;

  // expose these for ERC20 tools
  string public constant name = "LUNA";
  string public constant symbol = "LUNA";
  uint8 public constant decimals = 18;

  // Significant digits tokenPrecision
  uint256 private constant tokenPrecision = 10e17;

  // TODO: set this final, this equates to an amount
  // in dollars.
  uint256 public constant hardCap = 32000 * tokenPrecision;

  // Tokens frozen supply
  uint256 public tokensFrozen = 0;

  uint256 public tokenValue = 1 * tokenPrecision;

  // struct representing a dividends snapshot
  struct DividendSnapshot {
    uint256 totalSupply;
    uint256 dividendsIssued;
    uint256 managementDividends;
  }
  // An array of all the DividendSnapshot so far
  DividendSnapshot[] dividendSnapshots;

  // Mapping of user to the index of the last dividend that was awarded to zhie
  mapping(address => uint256) lastDividend;

  // Management fees share express as 100/%: eg. 20% => 100/20 = 5
  uint256 public constant managementFees = 10;

  // Assets under management in USD
  uint256 public aum = 0;

  // drip percent in 100 / percentage
  uint256 public dripRate = 50;

  // current registred change address
  address public currentSaleAddress;

  // custom events
  event Freeze(address indexed from, uint256 value);
  event Reconcile(address indexed from, uint256 period, uint256 value);

  /**
   * ICO constructor
   * Define ICO details and contribution period
   */
  constructor(uint256 _icoStart, uint256 _icoEnd, address[] _team) public {
    owner = msg.sender;

    // initialize the team mapping with true when part of the team
    teamNum = _team.length;
    for (uint256 i = 0; i < teamNum; i++) {
      team[_team[i]] = true;
    }

    // as a safety measure tempory set the sale address to something else than 0x0
    currentSaleAddress = owner;
  }

  /**
   * Modifiers
   */
  modifier onlyOwner() {
    require (msg.sender == owner);
    _;
  }

  modifier onlyTeam() {
    require (team[msg.sender] == true);
    _;
  }

  modifier onlySaleAddress() {
    require (msg.sender == currentSaleAddress);
    _;
  }

  /**
   * Internal burn function, only callable by team
   *
   * @param _amount is the amount of tokens to burn.
   */
  function freeze(uint256 _amount) public onlySaleAddress returns (bool) {
    reconcileDividend(msg.sender);
    require(_amount <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    tokensFrozen = tokensFrozen.add(_amount);

    aum = aum.sub(tokenValue.mul(_amount).div(tokenPrecision));

    emit Freeze(msg.sender, _amount);
    emit Transfer(msg.sender, 0x0, _amount);
    return true;
  }

  /**
   * Calculate the divends for the current period given the AUM profit
   *
   * @param totalProfit is the amount of total profit in USD.
   */
  function reportProfit(int256 totalProfit, bool drip, address saleAddress) public onlyTeam returns (bool) {
    // first we new dividends if this period was profitable
    if (totalProfit > 0) {
      // We only care about 50% of this, as the rest is reinvested right away
      uint256 profit = uint256(totalProfit).mul(tokenPrecision).div(2);

      // this will throw if there are not enough tokens
      addNewDividends(profit);
    }

    if(drip) {
      // then we drip
      drip(saleAddress);
    }

    // adjust AUM
    if (totalProfit > 0) {
      aum = aum.add(uint256(totalProfit).mul(tokenPrecision));
    } else if (totalProfit < 0) {
      aum = aum.add(uint256(-totalProfit).mul(tokenPrecision));
    }

    // register the sale address
    currentSaleAddress = saleAddress;

    return true;
  }


  function drip(address saleAddress) internal {
    uint256 dripTokens = tokensFrozen.div(dripRate);

    tokensFrozen = tokensFrozen.sub(dripTokens);
    totalSupply = totalSupply.add(dripTokens);
    aum = aum.add(tokenValue.mul(dripTokens).div(tokenPrecision));

    reconcileDividend(saleAddress);
    balances[saleAddress] = balances[saleAddress].add(dripTokens);
    emit Transfer(0x0, saleAddress, dripTokens);
  }

  /**
   * Calculate the divends for the current period given the dividend
   * amounts (USD * tokenPrecision).
   */
  function addNewDividends(uint256 profit) internal {
    uint256 newAum = aum.add(profit); // 18 sig digits
    tokenValue = newAum.mul(tokenPrecision).div(totalSupply); // 18 sig digits
    uint256 totalDividends = profit.mul(tokenPrecision).div(tokenValue); // 18 sig digits
    uint256 managementDividends = totalDividends.div(managementFees); // 17 sig digits
    uint256 dividendsIssued = totalDividends.sub(managementDividends); // 18 sig digits

    // make sure we have enough in the frozen fund
    require(tokensFrozen >= totalDividends);

    dividendSnapshots.push(DividendSnapshot(totalSupply, dividendsIssued, managementDividends));

    // add the previous amount of given dividends to the totalSupply
    totalSupply = totalSupply.add(totalDividends);
    tokensFrozen = tokensFrozen.sub(totalDividends);
  }

  /**
   * Withdraw all funds and kill fund smart contract
   */
  function liquidate() public onlyTeam returns (bool) {
    selfdestruct(owner);
  }


  // getter to retrieve divident owed
  function getOwedDividend(address _owner) public view returns (uint256 total, uint256[]) {
    uint256[] memory noDividends = new uint256[](0);
    // And the address' current balance
    uint256 balance = BasicToken.balanceOf(_owner);
    // retrieve index of last dividend this address received
    // NOTE: the default return value of a mapping is 0 in this case
    uint idx = lastDividend[_owner];
    if (idx == dividendSnapshots.length) return (total, noDividends);
    if (balance == 0 && team[_owner] != true) return (total, noDividends);

    uint256[] memory dividends = new uint256[](dividendSnapshots.length - idx - i);
    uint256 currBalance = balance;
    for (uint i = idx; i < dividendSnapshots.length; i++) {
      // We should be able to remove the .mul(tokenPrecision) and .div(tokenPrecision) and apply them once
      // at the beginning and once at the end, but we need to math it out
      uint256 dividend = currBalance.mul(tokenPrecision).div(dividendSnapshots[i].totalSupply).mul(dividendSnapshots[i].dividendsIssued).div(tokenPrecision);

      // Add the management dividends in equal parts if the current address is part of the team
      if (team[_owner] == true) {
        dividend = dividend.add(dividendSnapshots[i].managementDividends.div(teamNum));
      }

      total = total.add(dividend);

      dividends[i - idx] = dividend;

      currBalance = currBalance.add(dividend);
    }

    return (total, dividends);
  }

  // monkey patches
  function balanceOf(address _owner) public view returns (uint256) {
    uint256 owedDividend;
    (owedDividend,) = getOwedDividend(_owner);
    return BasicToken.balanceOf(_owner).add(owedDividend);
  }


  // Reconcile all outstanding dividends for an address
  // into its balance.
  function reconcileDividend(address _owner) internal {
    uint256 owedDividend;
    uint256[] memory dividends;
    (owedDividend, dividends) = getOwedDividend(_owner);

    for (uint i = 0; i < dividends.length; i++) {
      if (dividends[i] > 0) {
        emit Reconcile(_owner, lastDividend[_owner] + i, dividends[i]);
        emit Transfer(0x0, _owner, dividends[i]);
      }
    }

    if(owedDividend > 0) {
      balances[_owner] = balances[_owner].add(owedDividend);
    }

    // register this user as being owed no further dividends
    lastDividend[_owner] = dividendSnapshots.length;
  }

  function transfer(address _to, uint256 _amount) public returns (bool) {
    reconcileDividend(msg.sender);
    reconcileDividend(_to);
    return BasicToken.transfer(_to, _amount);
  }

}