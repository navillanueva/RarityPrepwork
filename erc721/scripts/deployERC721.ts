import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();

  const MyNFT = await ethers.getContractFactory("MyNFT");
  const myNFT = await MyNFT.deploy(
    "0x5FbDB2315678afecb367f032d93F642f64180aa3" //address of newly minted token
  );
  const address = await myNFT.getAddress();
  console.log("MyNFT contract address:", address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
