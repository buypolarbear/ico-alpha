pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';

contract Dividends is BasicToken {
  address owner;
  address[] team;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint8 public decimals = 18;

  uint256 public constant HARD_CAP = 10000 ether;

  uint256 public AUM = 6000 * 10e18;
  uint256 public tokensIssued = 3000 * 10e18;
  uint256 public tokensFrozen = 9000 * 10e18;
  uint256 public totalDividends = 0;

  uint256 public tokensPerEth;

  uint public tokenSaleOpen;
  uint public tokenSaleClose;

  struct Account {
    uint256 balance;
    uint256 prevDividends;
  }

  Account aleBal = Account(10 * 10e18, 0);

  function Dividends() public {
    owner = msg.sender;
  }

  function calculate(uint256 profit) public returns (uint256) {
    // profit in USD
    profit = profit * 10e18;
    uint256 newAUM = AUM + profit;
    uint256 newTokenValue = (newAUM * 10e18) / tokensIssued; // 8 sig digits
    uint256 dividends = (profit * 10e18) / newTokenValue; // 8 sig digits

    // make sure we have enough in the frozen fund
    require(tokensFrozen >= dividends);

    // update the tokensIssued with the previous amount of given dividends
    tokensIssued += totalDividends;
    totalDividends += dividends;
    tokensFrozen -= dividends;
    AUM = newAUM;

    return dividends;
  }

  function getBal() public returns (uint256) {
    uint256 newDividends = totalDividends - aleBal.prevDividends;
    if (newDividends > 0) {
      aleBal.prevDividends = totalDividends;
      aleBal.balance += ((((aleBal.balance * 10e18) / (tokensIssued)) * newDividends) / 10e18);
    }
    return aleBal.balance;
  }

}