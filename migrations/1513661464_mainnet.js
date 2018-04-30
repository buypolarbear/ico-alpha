const moment = require('moment');
const Ico = artifacts.require('Ico')

module.exports = function(deployer) {

  const start = 1513663200; // Dec 19th 2017 6:00:00 GMT
  const end = 1513836000; // Dec 21th 2017 6:00:00 GMT

  const team = [
    '0xFE01b3b2E5693EdA712104555620742c87d6CA90', // Ante
    '0xf80f44febC9ee496Ad5c8266f1b567148Cd00F19', // Mike
    '0xBE2C2fA2347340298783eA69AD03eB4E70C1E970', // Ev
    '0xFF56D7fDEcD8BAF89518cB83492FF8257b0f50B2', // Ale
  ];

  // this should be USD/ETH rate
  const tokensPerEth = 800;

  deployer.deploy(Ico, start, end, team, tokensPerEth);
}