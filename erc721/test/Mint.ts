import { ethers } from "hardhat";
import { expect } from "chai";

describe("MyNFT Contract", function () {
  let myNFT: any;
  let Token: any;
  let owner: any;
  let addr1: any;
  let addr2: any;
  let NFTaddress: any;
  let address: any;

  this.beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    Token = await ethers.getContractFactory("TestTokenNFT");
    const token = await Token.deploy("100000000000000000000");
    address = await token.getAddress();
    console.log(address);

    const MyNFT = await ethers.getContractFactory("MyNFT");
    myNFT = await MyNFT.deploy(address);
    NFTaddress = await myNFT.getAddress();
    console.log(NFTaddress);

    // Transfer some ERC20 tokens to addr1 for testing
    const tx = await token.transfer(addr1.address, "500");
    console.log(tx.msg.sender.getBalance());
  });

  it("should fail to mint NFT using Ethereum", async function () {
    await expect(
      addr1.sendTransaction({
        to: NFTaddress,
        value: "100000000000000000000000000",
      })
    ).to.be.revertedWith("unsupported addressable value");
  });

  it("should successfully mint NFT with ERC20 tokee", async function () {
    const tokenId = 1;
    const tokenPrice = await myNFT.tokenPrice();

    await address.connect(addr1).approve(myNFT.address, tokenPrice);

    // Mint the NFT
    await expect(myNFT.connect(addr1).mint(tokenId))
      .to.emit(myNFT, "Transfer")
      .withArgs("0x", addr1.address, tokenId);

    // Verify ownership of the minted NFT
    expect(await myNFT.ownerOf(tokenId)).to.equal(addr1.address);
  });
});
