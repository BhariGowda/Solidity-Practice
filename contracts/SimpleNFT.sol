// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SimpleNFT {
    string public name = "BhariNFT";
    string public symbol = "BNFT";
    uint256 public totalSupply;
    address public owner;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => address) public getApproved;
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function mint(address to) external onlyOwner returns (uint256) {
        totalSupply++;
        uint256 tokenId = totalSupply;
        ownerOf[tokenId] = to;
        balanceOf[to]++;
        emit Transfer(address(0), to, tokenId);
        return tokenId;
    }

    function transfer(address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not token owner");
        require(to != address(0), "Invalid address");
        _transfer(msg.sender, to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == from, "Not token owner");
        require(to != address(0), "Invalid address");
        require(
            msg.sender == from ||
            msg.sender == getApproved[tokenId] ||
            isApprovedForAll[from][msg.sender],
            "Not approved"
        );
        _transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        require(ownerOf[tokenId] == msg.sender, "Not token owner");
        getApproved[tokenId] = to;
        emit Approval(msg.sender, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) external {
        isApprovedForAll[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        balanceOf[from]--;
        balanceOf[to]++;
        ownerOf[tokenId] = to;
        delete getApproved[tokenId];
        emit Transfer(from, to, tokenId);
    }
}
