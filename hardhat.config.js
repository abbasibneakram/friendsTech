require("ethereum-waffle");
require("dotenv").config();
// require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("@openzeppelin/hardhat-upgrades");

module.exports = {
  solidity: {
    version: "0.8.19",
    settings: {
      metadata: {
        bytecodeHash: "none",
      },
      optimizer: {
        enabled: true,
        runs: 800,
      },
    },
  },
  paths: {
    artifacts: "./artifacts",
  },
  networks: {
    avaxTestnet: {
      url: `https://api.avax-test.network/ext/C/rpc`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
    avaxMainnet: {
      url: `https://api.avax.network/ext/bc/C/rpc`,
      accounts: [`${process.env.PRIVATE_KEY}`],
    },
  },
  etherscan: {
    apiKey: `${process.env.ETHER_SCAN_KEY}`,
  },
};
