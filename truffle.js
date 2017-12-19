module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    ropsten: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      from: "0x0034C0b4428081508A8E77B0d31da9Bf73Bb95a7",
      // from: "0xd6bB00fdf0557D07782cA55778a4f7DF07a77Dd7",
      gas: 4700036
    },
    mainnet: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      from: "0x00D2742eBa100cF29E1670A184f8F29A363c99f7", // Owner Account
      gas: 4700036,
      gasPrice: 30000000000
    }
  }
};