pragma solidity ^0.4.17;

import 'zeppelin-solidity/contracts/token/BasicToken.sol';

// NOTE: BasicToken only has partial ERC20 support
contract Ico is BasicToken {

  address owner;

  // expose these for ERC20 tools
  string public name = "TODO";
  string public symbol = "TODO";
  uint public decimals = 18;

  uint public SUPPLY = 10000 ether;

  function Ico() {
    owner = msg.sender;

    uint mikesPremine = 16 ether;

    balances[owner] = SUPPLY - mikesPremine;
    balances[0x7412417A91af476C48516283B3CfA80BA6E489A8] = mikesPremine;
  }

  function sayHi() pure returns (string)  {
    return "hello 4";
  }

  // getter to retrieve divident owed
  function getOwedDividend(address _owner) public view returns (uint256 balance) {
    // todo @ale
    return 1 ether;
  }

  // helper function that makes sure we add dividend before any
  // type of ledger mutation.
  modifier addDividend() {
    uint owedDividend = getOwedDividend(msg.sender);
    if(owedDividend > 0) {
      balances[msg.sender] = balances[msg.sender].add(owedDividend);
    }
    _;
  }

  // monkey patches
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return BasicToken.balanceOf(_owner).add(getOwedDividend(_owner));
  }
  function transfer(address _to, uint256 _value) addDividend() public returns (bool) {
    return BasicToken.transfer(_to, _value);
  }

}