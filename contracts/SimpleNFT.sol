// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleNFT {
    string public name = "BhariNFT";
    string public symbol = "BNFT";
    uint256 public tokenCount;
    address public owner;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => string) public tokenURI;

    event Transfer(address indexed from, address indexed to, uint256 tokenId);
    event Mint(address indexed to, uint256 tokenId, string uri);

    constructor() {
        owner = msg.sender;
    }

    function mint(address to, string memory uri) external {
        require(msg.sender == owner, "Not owner");
        tokenCount++;
        ownerOf[tokenCount] = to;
        balanceOf[to]++;
        tokenURI[tokenCount] = uri;
        emit Mint(to, tokenCount, uri);
        emit Transfer(address(0), to, tokenCount);
    }

    function transfer(address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not your NFT");
        balanceOf[msg.sender]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;
        emit Transfer(msg.sender, to, tokenId);
    }
}