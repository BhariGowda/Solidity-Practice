// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Wallet {
    address public owner;
    
    event Deposited(address sender, uint256 amount);
    event Withdrawn(uint256 amount);
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
    function deposit() external payable {
        emit Deposited(msg.sender, msg.value);
    }
    
    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= address(this).balance, "Insufficient");
        payable(owner).transfer(amount);
        emit Withdrawn(amount);
    }
    
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
