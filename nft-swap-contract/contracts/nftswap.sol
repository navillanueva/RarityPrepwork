// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Checker.sol";

contract nftswap {
    struct Swap {
        address initiatior;
        address collectionA;
        uint256 tokenA;
        address collectionB;
        uint256 tokenB;
        uint256 deadline;
        bool isComplete;
    }

    uint256 public swapCounter = 0;
    mapping(uint256 => Swap) public swaps;
    mapping(address => mapping(uint256 => address)) public deposits; // Mapping of contract address and token ID to the depositor's address

    event SwapCreated(
        uint256 indexed swapId,
        address indexed initiator,
        address collectionA,
        uint256 tokenA,
        address collectionB,
        uint256 tokenB,
        uint256 deadline
    );
    event NFTDeposited(
        uint256 indexed swapId,
        address indexed depositor,
        address collection,
        uint256 tokenId
    );
    event SwapExecuted(uint256 indexed swapId);
    event SwapCancelled(uint256 indexed swapId);

    function createSwap(
        address _collectionA,
        uint256 _tokenA,
        address _collectionB,
        uint256 _tokenB,
        uint256 _duration
    ) external {
        require(
            _collectionA.supportsInterface(type(IERC721).interfaceId),
            "Collection A must support ERC721"
        );
        require(
            _collectionB.supportsInterface(type(IERC721).interfaceId),
            "Collection B must support ERC721"
        );

        uint256 deadline = block.timestamp + _duration;
        Swap memory newSwap = Swap(
            msg.sender,
            _collectionA,
            _tokenA,
            _collectionB,
            _tokenB,
            deadline,
            false
        );
        swaps[++swapCounter] = newSwap;

        emit SwapCreated(
            swapCounter,
            msg.sender,
            _collectionA,
            _tokenA,
            _collectionB,
            _tokenB,
            deadline
        );
    }

    function depositNFT(
        uint256 swapId,
        address collection,
        uint256 tokenId
    ) external {
        Swap storage swap = swaps[swapId];
        require(block.timestamp <= swap.deadline, "Swap deadline has passed");
        require(!swap.isComplete, "Swap already completed");
        require(
            (collection == swap.collectionA && tokenId == swap.tokenA) ||
                (collection == swap.collectionB && tokenId == swap.tokenB),
            "NFT does not match any swap side"
        );

        IERC721(collection).transferFrom(msg.sender, address(this), tokenId);
        deposits[collection][tokenId] = swapId;

        emit NFTDeposited(swapId, msg.sender, collection, tokenId);
    }

    function executeSwap(uint256 swapId) external onlyParticipant(swapId) {
        Swap storage swap = swaps[swapId];
        require(block.timestamp <= swap.deadline, "Swap deadline has passed");
        require(!swap.isComplete, "Swap already completed");
        require(
            deposits[swap.collectionA][swap.tokenA] != 0 &&
                deposits[swap.collectionB][swap.tokenB] != 0,
            "Both NFTs must be deposited"
        );

        IERC721(swap.collectionA).transferFrom(
            address(this),
            swap.initiator == msg.sender
                ? deposits[swap.collectionB][swap.tokenB]
                : msg.sender,
            swap.tokenA
        );
        IERC721(swap.collectionB).transferFrom(
            address(this),
            swap.initiator == msg.sender
                ? msg.sender
                : deposits[swap.collectionA][swap.tokenA],
            swap.tokenB
        );
        swap.isComplete = true;

        emit SwapExecuted(swapId);
    }

    function cancelSwap(uint256 swapId) external onlyParticipant(swapId) {
        Swap storage swap = swaps[swapId];
        require(!swap.isComplete, "Swap already completed");

        if (deposits[swap.collectionA][swap.tokenA] != 0) {
            IERC721(swap.collectionA).transferFrom(
                address(this),
                deposits[swap.collectionA][swap.tokenA],
                swap.tokenA
            );
        }
        if (deposits[swap.collectionB][swap.tokenB] != 0) {
            IERC721(swap.collectionB).transferFrom(
                address(this),
                deposits[swap.collectionB][swap.tokenB],
                swap.tokenB
            );
        }
        swap.isComplete = true; // Prevents re-entry

        emit SwapCancelled(swapId);
    }
}
