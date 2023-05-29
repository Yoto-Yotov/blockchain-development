// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "./NFT.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract NFTMarketplace is NFT {
    // collection => id => price
    mapping(address => mapping(uint256 => Sale)) public nftSale;
    mapping(address => uint256) public profits;

    struct Sale {
        uint256 price;
        address seller;
    }

    event NFTListed(address indexed collection, uint256 indexed id, uint256 price);

    function listNFTForSale(
        address collection,
        uint256 id,
        uint256 price
    ) external {
        Sale memory sale = nftSale[collection][id];

        require(price != 0, "Price must be greater than 0");
        require(sale.price == 0, "NFT already listed for sale");

        nftSale[collection][id] = Sale({
            seller: msg.sender,
            price: price
        });

        emit NFTListed(collection, id, price);
        // Our contract implements IERC721 so we do not need safeTransferFrom
        IERC721(collection).transferFrom(msg.sender, address(this), id);
    }

    function unlistNFT(address collection, uint256 id, address to) external {
        Sale memory sale = nftSale[collection][id];
        require(sale.price != 0, "NFT not listed for sale");
        require(sale.seller == msg.sender, "Only owner can unlist NFT");

        delete nftSale[collection][id];
        IERC721(collection).safeTransferFrom(address(this), to, id);
    }

    function purchaseNFT(address collection, uint256 id, address to) external payable {
        Sale memory sale = nftSale[collection][id];
        require(sale.price != 0, "NFT not listed for sale");
        require(msg.value == sale.price, "Incorect price");

        nftSale[collection][id] = Sale({seller: address(0), price: 0});
        // OR
        // delete nftPrice[collection][id]

        profits[sale.seller] += msg.value;

        IERC721(collection).safeTransferFrom(address(this), to, id);
    }

    function claimProfit() external {
        uint256 profit = profits[msg.sender];
        require(profit != 0, "No profits");
        profits[msg.sender] = 0;

        (bool succes, ) = payable(msg.sender).call{value: profit}("");
        require(succes, "Unable to send value");
    }
}
