// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @title FlashLoanReceiver
/// @notice Example flash loan receiver implementing Aave V3 interface
/// @dev Educational contract showing how to receive and use flash loans
interface IFlashLoanSimpleReceiver {
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool);
}

interface IPool {
    function flashLoanSimple(
        address receiverAddress,
        address asset,
        uint256 amount,
        bytes calldata params,
        uint16 referralCode
    ) external;
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}

contract FlashLoanReceiver is IFlashLoanSimpleReceiver {
    address public immutable pool;
    address public immutable owner;

    error NotPool();
    error NotOwner();
    error InsufficientBalance();

    event FlashLoanExecuted(address asset, uint256 amount, uint256 premium);

    constructor(address _pool) {
        pool = _pool;
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert NotOwner();
        _;
    }

    /// @notice Request a flash loan from Aave
    function requestFlashLoan(address asset, uint256 amount) external onlyOwner {
        IPool(pool).flashLoanSimple(
            address(this),
            asset,
            amount,
            "",
            0
        );
    }

    /// @notice Called by Aave after sending flash loan funds
    /// @dev Must repay amount + premium before returning true
    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata /*params*/
    ) external override returns (bool) {
        if (msg.sender != pool) revert NotPool();

        // *** Your flash loan logic here ***
        // At this point you have `amount` of `asset` to use
        // You must repay amount + premium before this function returns

        uint256 repayAmount = amount + premium;
        if (IERC20(asset).balanceOf(address(this)) < repayAmount) {
            revert InsufficientBalance();
        }

        // Approve pool to pull repayment
        IERC20(asset).approve(pool, repayAmount);

        emit FlashLoanExecuted(asset, amount, premium);
        return true;
    }

    /// @notice Withdraw tokens from this contract
    function withdraw(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(owner, amount);
    }
}
