import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract } from "ethers";

describe("TimeLockedERC20", function () {
  let timeLockedERC20: Contract;
  let token: Contract;
  let owner: any;
  let receiver: any;

  beforeEach(async function () {
    // Deploy the ERC20 token and the TimeLockedERC20 contract
    // Assume you have a function `deployContracts` that handles this
    ({ token, timeLockedERC20 } = await deployContracts());

    [owner, receiver] = await ethers.getSigners();
  });

  it("should revert if the user tries to withdraw more than the allowed amount in the set time", async function () {
    // Simulate deposit by the owner
    const depositAmount = ethers.utils.parseUnits("1000", 18);
    await token.connect(owner).approve(timeLockedERC20.address, depositAmount);
    await timeLockedERC20.connect(owner).deposit(depositAmount);

    // Try to withdraw before the time limit
    const tooEarlyWithdrawalAmount = ethers.utils.parseUnits("500", 18);
    await expect(
      timeLockedERC20.connect(receiver).withdraw(tooEarlyWithdrawalAmount)
    ).to.be.revertedWith("No tokens available for withdrawal");
  });
});

async function deployContracts(): Promise<{
  token: Contract;
  timeLockedERC20: Contract;
}> {
  // Add your deployment logic here
}
