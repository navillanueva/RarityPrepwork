// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyNFT is ERC721 {
    IERC20 public paymentToken;
    uint256 public tokenPrice;

    constructor(address _paymentToken) ERC721("MyNFT", "MNFT") {
        paymentToken = IERC20(_paymentToken);
        tokenPrice = 100 * (10 ** 18); // Price per NFT
    }

    function mint(uint256 tokenId) public {
        require(
            paymentToken.transferFrom(msg.sender, address(this), tokenPrice),
            "Payment failed"
        );
        _mint(msg.sender, tokenId);
    }
}
