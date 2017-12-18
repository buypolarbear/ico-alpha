const moment = require('moment');
const Ico = artifacts.require('Ico')

module.exports = function(deployer) {

  const start = moment().unix();
  const end = moment().add(60, 'minute').unix();

  // first two accounts of mnemonic:
  // `candy maple cake sugar pudding cream honey rich smooth crumble sweet treat`
  const team = [
    '0xa9c3B060c668093eB0E07B2277BD821D8dC2086D', // Ante
    '0x63316f44221DF9494F2e7cFf3CbC428bdedd9907', // Mike
    '0x13A680C873705A3E1E0a2f701758B14A3f8303bB', // Ev
    '0xd6bB00fdf0557D07782cA55778a4f7DF07a77Dd7', // Ale
  ];

  // this should be USD/ETH rate
  const tokensPerEth = 1000;

  deployer.deploy(Ico, start, end, team, tokensPerEth);
}