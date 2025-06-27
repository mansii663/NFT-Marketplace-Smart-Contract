// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721URIStorage, Ownable {
    uint public nextTokenId;

    struct Listing {
        address seller;
        uint price;
    }

    mapping(uint => Listing) public listings;

    constructor() ERC721("JohnNFT", "MFT") Ownable(msg.sender) {}

    function minNFT(string memory tokenURI) public {
        uint tokenId = nextTokenId;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        nextTokenId;
    }

    function listNFT(uint tokenId, uint price) public {
        require(ownerOf(tokenId) == msg.sender, "NOT THE OWNER");
        require(price > 0, "PRICE MUST BE MORE THAN 0");
        approve(address(this), tokenId);
        listings[tokenId] = Listing(msg.sender, price);
    }

    function buyNFT(uint tokenId) public payable {
        Listing memory item = listings[tokenId];
        require(item.price > 0, "NOT FOR SALE");
        require(msg.value >= item.price, "INSUFFICIENT ETH");

        //Transfer NFT to buyer
        _transfer(item.seller, msg.sender, tokenId);

        //Transfer ETH to seller
        payable(item.seller).transfer(msg.value);

        //Remove listing
        delete listings[tokenId];
    }

    function getListing(uint tokenId) public view returns(address, uint) {
        Listing memory item = listings[tokenId];
        return(item.seller, item.price);
    }
}