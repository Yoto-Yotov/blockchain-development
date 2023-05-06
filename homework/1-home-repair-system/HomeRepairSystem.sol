// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

contract HomeRepairService {
    address payable owner;
    address payable client = payable(msg.sender); 

    mapping(uint256 => string) public repairRequests;
    mapping(uint256 => address) public repairRequestsAddress;
    mapping(uint256 => uint) public acceptedRepairRequest;

    mapping(uint256 => bool) public isPaid;

    mapping(address => bool) public isAuditor;
    mapping(uint256 => uint) public verified;
    mapping(uint256 => mapping(address => bool)) public auditorsVerified;


    constructor() {
        owner = payable(msg.sender);
    }

    // Task 1
    function addRepairRequest(uint256 id,  string calldata message) external {
        require(bytes(message).length > 0, "Message cannot be empty");
        require(bytes(repairRequests[id]).length == 0 , "Request with id already exists");
        repairRequests[id] = message; 
        repairRequestsAddress[id] = msg.sender;
    }

    // Task 2
    function acceptRepairRequest(uint256 id, uint taxWei) external {
        require(msg.sender == owner, "Only the owner can accept repair requests");
        require(repairRequestsAddress[id] != address(0), "Not valid request");

        acceptedRepairRequest[id] = taxWei;
    }

    // Task 3
    function addPayment(uint256 id) external payable {
        require(acceptedRepairRequest[id] != 0, "Request not yeat accepted");
        require(acceptedRepairRequest[id] == msg.value, "Amount not valid");

        isPaid[id] = true;

        (bool paidSuccessfully, ) = payable(msg.sender).call{value: msg.value}("");
        if (!paidSuccessfully) {
            revert("Failed to pay");
        }
    }

    // Task 4,5
    function confirmRepairRequest(uint256 id) external {
        require(isAuditor[msg.sender], "Not Auditor");
        require(isPaid[id], "Request not paid");

        require(auditorsVerified[id][msg.sender] == false);
        auditorsVerified[id][msg.sender] = true;

        verified[id]++;

        if(verified[id] > 2) {
            _executeRepairRequest(id);
        }
    }

    // Task 6
    function _executeRepairRequest(uint id) public payable {
        require(verified[id] > 2);
        owner.transfer(acceptedRepairRequest[id]);
    }

    // Task 7
    function moneyBack(uint id) public payable {
        client.transfer(acceptedRepairRequest[id]);
    }
}
