// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

contract AuctionPlatform {

    struct Auction {
        uint256 start;
        uint256 end;
        string itemName;
        string itemDescription;
        uint256 highestBid;
        bool finalized;
        address creator;
    }

    uint256 auctionId;

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => address) public auctionToHighestBidder;
    mapping(address => uint256) public availableToWithdraw;

    event NewAuction(Auction auction);
    event NewHighestBid(uint256 auctionId, uint256 newHishestBid);

    modifier onlyActiveAuction() {
        Auction memory auction = auctions[auctionId];
        require(auction.start <= block.timestamp, "Auction not yet started");
        require(auction.end > block.timestamp, "Auction already ended");
        _;
    }
 
    function createAuction(uint256 start, uint256 duration, string memory itemName, string memory itemDescription, uint256 startingPrice) public {
        // 1715001783 ~ 2024 6 May
        require(start > block.timestamp, "Start time must be in the future");
        require(duration > 0, "Duration must be greather than 0");

        auctionId++;

        // Not sure if this is a code smell 
        Auction memory auction = auctions[auctionId] = Auction({
            start: start,
            end: start + duration,
            itemName: itemName,
            itemDescription: itemDescription,
            highestBid: startingPrice,
            finalized: false,
            creator: msg.sender
        });    
        
        emit NewAuction(auction);
    }

    function placeBid(uint256 id) external payable onlyActiveAuction {
        require(auctions[id].finalized == false, "Auction does not exist or has finished");

        if(msg.value <= auctions[id].highestBid) {
            return;
        }

        Auction storage auction = auctions[id];

        address currentHighestBidder = auctionToHighestBidder[id];        
        availableToWithdraw[currentHighestBidder] = auction.highestBid;

        auction.highestBid = msg.value;
        auctionToHighestBidder[id] = msg.sender;

        emit NewHighestBid(id, auction.highestBid);
    }

    function finalizeBid(uint256 id) external {
        Auction storage auction = auctions[id];
        require(auction.end < block.timestamp, "Auction not yet ended");
        require(auction.finalized == false);

        auction.finalized = true;

        if(auction.highestBid > 0) {
            payable(auction.creator).transfer(auction.highestBid);
        }
    }

    function withdraw() external payable {
        require(availableToWithdraw[msg.sender] > 0, "No withdraw available");

        uint256 userBid = availableToWithdraw[msg.sender];
        availableToWithdraw[msg.sender] = 0;
        payable(msg.sender).transfer(userBid);

    }

    // For debug
    function currentTimestamp() external view returns (uint256) {
        return block.timestamp;
    }
}
