// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract YourContract is ERC721URIStorage, Ownable {
    uint256 private _tokenIdCounter;

    // Structure to store NFT details for sale
    struct NFT {
        uint256 tokenId;
        address payable seller;
        uint256 price;
        bool isListed;
    }

    // Mapping from token ID to NFT details
    mapping(uint256 => NFT) public nfts;

    // Events
    event NFTMinted(uint256 indexed tokenId, address indexed owner, string tokenURI);
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed buyer, uint256 price);
    event NFTDelisted(uint256 indexed tokenId);

    constructor() ERC721("SimpleNFT", "SNFT") Ownable(msg.sender) {}

    /**
     * @notice Mint a new NFT
     * @param tokenURI The URI pointing to the metadata of the token
     */
    function mintNFT(string memory tokenURI) public {
        _tokenIdCounter++; // Increment token ID
        uint256 newTokenId = _tokenIdCounter;

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        emit NFTMinted(newTokenId, msg.sender, tokenURI);
    }

    /**
     * @notice List an NFT for sale
     * @param tokenId The ID of the token to list
     * @param price The price for which the NFT will be sold
     */
    function listNFT(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        require(price > 0, "Price must be greater than zero");

        nfts[tokenId] = NFT(tokenId, payable(msg.sender), price, true);

        // Transfer the NFT to the contract for custody
        _transfer(msg.sender, address(this), tokenId);

        emit NFTListed(tokenId, msg.sender, price);
    }

    /**
     * @notice Buy a listed NFT
     * @param tokenId The ID of the token to buy
     */
    function buyNFT(uint256 tokenId) public payable {
        NFT storage nft = nfts[tokenId];

        require(nft.isListed, "This NFT is not listed for sale");
        require(msg.value == nft.price, "Incorrect payment amount");

        address payable seller = nft.seller;

        // Transfer the payment to the seller
        seller.transfer(msg.value);

        // Transfer the NFT to the buyer
        _transfer(address(this), msg.sender, tokenId);

        // Mark as sold
        nft.isListed = false;

        emit NFTSold(tokenId, msg.sender, nft.price);
    }

    /**
     * @notice Delist an NFT
     * @param tokenId The ID of the token to delist
     */
    function delistNFT(uint256 tokenId) public {
        NFT storage nft = nfts[tokenId];

        require(nft.isListed, "This NFT is not listed");
        require(nft.seller == msg.sender, "You are not the seller");

        nft.isListed = false;

        // Return the NFT to the owner
        _transfer(address(this), msg.sender, tokenId);

        emit NFTDelisted(tokenId);
    }

    /**
     * @notice Get details of an NFT
     * @param tokenId The ID of the token
     * @return NFT details
     */
    function getNFT(uint256 tokenId) public view returns (NFT memory) {
        return nfts[tokenId];
    }

    /**
     * @notice Get all NFTs currently listed for sale
     * @return An array of NFTs that are currently listed
     */
    function getListedNFTs() public view returns (NFT[] memory) {
        uint256 totalNFTCount = _tokenIdCounter;
        uint256 listedCount = 0;

        // Count the number of listed NFTs
        for (uint256 i = 1; i <= totalNFTCount; i++) {
            if (nfts[i].isListed) {
                listedCount++;
            }
        }

        // Create an array to hold the listed NFTs
        NFT[] memory listedNFTs = new NFT[](listedCount);
        uint256 currentIndex = 0;

        // Populate the array with listed NFTs
        for (uint256 i = 1; i <= totalNFTCount; i++) {
            if (nfts[i].isListed) {
                listedNFTs[currentIndex] = nfts[i];
                currentIndex++;
            }
        }

        return listedNFTs;
    }
}
