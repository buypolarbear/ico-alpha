module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 9545,
      network_id: "*" // Match any network id
    },
    ropsten {
      host: "localhost",
      port: 8545,
      network_id: "*",
      from: "0x0034C0b4428081508A8E77B0d31da9Bf73Bb95a7"
    }
  }
};