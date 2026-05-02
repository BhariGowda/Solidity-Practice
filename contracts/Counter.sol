// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Counter {
    uint256 public count;
    
    function increment() external {
        count++;
    }
    
    function decrement() external {
        count--;
    }
    
    function getCount() external view returns (uint256) {
        return count;
    }
}