// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleStorage {
    uint256 private storedData;
    
    event DataStored(uint256 value);
    
    function set(uint256 data) external {
        storedData = data;
        emit DataStored(data);
    }
    
    function get() external view returns (uint256) {
        return storedData;
    }
} 