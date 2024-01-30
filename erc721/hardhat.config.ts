import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.19",
};

module.exports = {
  typechain: {
    outDir: "typechain", // The directory where TypeChain typings are generated
    target: "ethers-v5", // The target can be ethers-v5, web3-v1, etc.
  },
  networks: {
    hardhat: {
      // Configuration options
    },
    // other network configurations
  },
  solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          /* ... */
        },
      },
      {
        version: "0.8.20",
        settings: {
          /* ... */
        },
      },
    ],
  },
};

export default config;
