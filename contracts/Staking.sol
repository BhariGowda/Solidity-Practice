// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Staking {
    address public owner;
    uint256 public constant APY = 10; // 10% per year
    uint256 public constant YEAR = 365 days;

    struct Stake {
        uint256 amount;
        uint256 stakedAt;
        bool isETH;
        address token; // address(0) if ETH
    }

    mapping(address => Stake) public stakes;

    event Staked(address indexed user, uint256 amount, bool isETH, address token);
    event Unstaked(address indexed user, uint256 amount, uint256 reward);
    event RewardsFunded(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier hasStake() {
        require(stakes[msg.sender].amount > 0, "No active stake");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Fund contract with ETH for rewards
    receive() external payable {
        emit RewardsFunded(msg.value);
    }

    // Stake ETH
    function stakeETH() external payable {
        require(msg.value > 0, "Must stake more than 0");
        require(stakes[msg.sender].amount == 0, "Already staking");

        stakes[msg.sender] = Stake({
            amount: msg.value,
            stakedAt: block.timestamp,
            isETH: true,
            token: address(0)
        });

        emit Staked(msg.sender, msg.value, true, address(0));
    }

    // Stake ERC20 token
    function stakeERC20(address token, uint256 amount) external {
        require(amount > 0, "Must stake more than 0");
        require(token != address(0), "Invalid token");
        require(stakes[msg.sender].amount == 0, "Already staking");

        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");

        stakes[msg.sender] = Stake({
            amount: amount,
            stakedAt: block.timestamp,
            isETH: false,
            token: token
        });

        emit Staked(msg.sender, amount, false, token);
    }

    // Unstake + claim rewards
    function unstake() external hasStake {
        Stake memory s = stakes[msg.sender];
        uint256 reward = calculateReward(msg.sender);
        uint256 total = s.amount + reward;

        delete stakes[msg.sender];

        if (s.isETH) {
            require(address(this).balance >= total, "Insufficient contract balance");
            (bool success, ) = msg.sender.call{value: total}("");
            require(success, "ETH transfer failed");
        } else {
            require(
                address(this).balance >= reward,
                "Insufficient ETH for rewards"
            );
            // Return staked tokens
            bool success = IERC20(s.token).transfer(msg.sender, s.amount);
            require(success, "Token transfer failed");
            // Pay ETH reward
            if (reward > 0) {
                (bool sent, ) = msg.sender.call{value: reward}("");
                require(sent, "Reward transfer failed");
            }
        }

        emit Unstaked(msg.sender, s.amount, reward);
    }

    // Calculate reward: amount * APY% * (timeStaked / YEAR)
    function calculateReward(address user) public view returns (uint256) {
        Stake memory s = stakes[user];
        if (s.amount == 0) return 0;
        uint256 timeStaked = block.timestamp - s.stakedAt;
        return (s.amount * APY * timeStaked) / (100 * YEAR);
    }

    function getStake(address user) external view returns (
        uint256 amount, uint256 stakedAt, bool isETH, address token, uint256 pendingReward
    ) {
        Stake memory s = stakes[user];
        return (s.amount, s.stakedAt, s.isETH, s.token, calculateReward(user));
    }

    // Owner can fund ERC20 rewards
    function fundERC20Rewards(address token, uint256 amount) external onlyOwner {
        bool success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(success, "Transfer failed");
    }
}
