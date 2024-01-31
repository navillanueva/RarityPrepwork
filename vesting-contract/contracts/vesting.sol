// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol"

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);
}

contract vesting {
    IERC20 public token;
    address public payer;
    address public reciever;

    uint256 public startTime;
    uint256 public tottalAmount;
    uint256 public vestingDuration;
    uint256 public amountWithdrawm;

    constructor(address _token, address _receiver, uint256 _vestingDuration) {
        token = IERC20(_token);
        payer = msg.sender;
        reciever = _receiver;
        vestingDuration = _vestingDuration;
    }

    function deposit(uint256 amount) external {
        require(msg.sender == payer, "Only payer can deposit");
        require(startTime == 0, "Deposit already made");

        token.transferFrom(payer, address(this), amount);
        tottalAmount = amount;
        startTime = block.timestamp;
    }

    function withdraw() external {
        require(msg.sender == reciever, "Only receiver can withdraw");
        require(startTime > 0, "Vesting not started");

        uint256 elapsed = block.timestamp - startTime;
        uint256 availableAmount = (totalAmount * elapsed) / vestingDuration;
        uint256 withdrawable = availableAmount -  amountWithdrawm;

        require(withdrawable > 0, "No tokens available for withdrawal");

        amountWithdrawm += withdrawable;
        token.transfer(reciever, withdrawable);
    }
}
