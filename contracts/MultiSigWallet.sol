// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract MultiSigWallet {
    address[3] public owners;
    uint256 public constant REQUIRED = 2;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        uint256 approvalCount;
        address token;
        uint256 tokenAmount;
    }

    Transaction[] public transactions;
    mapping(uint256 => mapping(address => bool)) public approved;

    event Deposit(address indexed sender, uint256 amount);
    event TransactionSubmitted(uint256 indexed txId, address indexed to, uint256 value);
    event TransactionApproved(uint256 indexed txId, address indexed owner);
    event TransactionExecuted(uint256 indexed txId);
    event ApprovalRevoked(uint256 indexed txId, address indexed owner);

    modifier onlyOwner() {
        require(_isOwner(msg.sender), "Not an owner");
        _;
    }

    modifier txExists(uint256 txId) {
        require(txId < transactions.length, "Tx does not exist");
        _;
    }

    modifier notExecuted(uint256 txId) {
        require(!transactions[txId].executed, "Already executed");
        _;
    }

    constructor(address[3] memory _owners) {
        for (uint256 i = 0; i < 3; i++) {
            require(_owners[i] != address(0), "Invalid owner");
            owners[i] = _owners[i];
        }
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function submitETH(address to, uint256 value) external onlyOwner returns (uint256) {
        require(address(this).balance >= value, "Insufficient ETH");
        transactions.push(Transaction(to, value, false, 0, address(0), 0));
        uint256 txId = transactions.length - 1;
        emit TransactionSubmitted(txId, to, value);
        return txId;
    }

    function submitERC20(address to, address token, uint256 amount) external onlyOwner returns (uint256) {
        transactions.push(Transaction(to, 0, false, 0, token, amount));
        uint256 txId = transactions.length - 1;
        emit TransactionSubmitted(txId, to, amount);
        return txId;
    }

    function approve(uint256 txId) external onlyOwner txExists(txId) notExecuted(txId) {
        require(!approved[txId][msg.sender], "Already approved");
        approved[txId][msg.sender] = true;
        transactions[txId].approvalCount++;
        emit TransactionApproved(txId, msg.sender);
        if (transactions[txId].approvalCount >= REQUIRED) {
            _execute(txId);
        }
    }

    function revokeApproval(uint256 txId) external onlyOwner txExists(txId) notExecuted(txId) {
        require(approved[txId][msg.sender], "Not approved yet");
        approved[txId][msg.sender] = false;
        transactions[txId].approvalCount--;
        emit ApprovalRevoked(txId, msg.sender);
    }

    function _execute(uint256 txId) internal {
        Transaction storage txn = transactions[txId];
        txn.executed = true;
        if (txn.token == address(0)) {
            (bool success, ) = txn.to.call{value: txn.value}("");
            require(success, "ETH transfer failed");
        } else {
            bool success = IERC20(txn.token).transfer(txn.to, txn.tokenAmount);
            require(success, "ERC20 transfer failed");
        }
        emit TransactionExecuted(txId);
    }

    function getTransaction(uint256 txId) external view returns (
        address to, uint256 value, bool executed, uint256 approvalCount, address token, uint256 tokenAmount
    ) {
        Transaction storage txn = transactions[txId];
        return (txn.to, txn.value, txn.executed, txn.approvalCount, txn.token, txn.tokenAmount);
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function _isOwner(address addr) internal view returns (bool) {
        for (uint256 i = 0; i < 3; i++) {
            if (owners[i] == addr) return true;
        }
        return false;
    }
}
