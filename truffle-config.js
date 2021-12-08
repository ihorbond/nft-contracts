require('dotenv').config()
const HDWalletProvider = require("@truffle/hdwallet-provider")
const config = require('./privatekey');

const projectId = process.env.PROJECT_ID;

module.exports = {
  contracts_directory: "./src/contracts",
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 8545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    avalanche: {
      provider: () => new HDWalletProvider(config.privateKey, config.avaxRPC),
      network_id: config.avaxId,
      skipDryRun: true
    },
    testnet: {
      provider: () => new HDWalletProvider(config.privateKey, config.avaxtestRPC),
      network_id: config.avaxtestId,
      confirmations: 1,
      gas: 20000000,
      gasPrice: 10000000000,
      timeoutBlocks: 200,
      skipDryRun: true
    },
  },
  compilers: {
    solc: {
      version: "0.8.0",   // Fetch exact version from solc-bin (default: truffle's version)
      docker: false,
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        libraries: {},
        outputSelection: {
          "*": {
            "*": [
              "evm.bytecode",
              "evm.deployedBytecode",
              "abi"
            ]
          }
        }
      },
    },
  },
};
