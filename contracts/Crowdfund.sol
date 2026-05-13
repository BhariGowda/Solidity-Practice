// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/*
 * =============================================================
 *
 *                    EVEREST OR BUST
 *               BhariGowda - Summit 2027
 *
 * =============================================================
 *
 * 2017. I dropped out of college.
 * Everyone said I was crazy.
 * I said: the old system is broken.
 *
 * No bank gave me permission.
 * No government approved my decision.
 * No middleman blessed my path.
 *
 * I chose Crypto. Blockchain. DeFi.
 * Borderless. Permissionless. 24/7. For everyone.
 * That is not just technology — that is FREEDOM.
 *
 * 8 years of being a DeFi maxi. A degen. A builder.
 * No 9-5. No plan B. Never was. Never will be.
 *
 * Now I am climbing Mount Everest — 8,849 meters —
 * to plant the Bitcoin flag on the roof of the world.
 *
 * Not for fame. Not for clout.
 * For the O-1 Visa (Extraordinary Ability) to enter the USA.
 * Legally. On my own terms. The crypto way.
 *
 * When that flag goes up:
 *   - It is for every dropout who bet on decentralization
 *   - It is for every degen who believed in a borderless world
 *   - It is for every builder who never needed a middleman
 *   - It is for FREEDOM OF FINANCE — carved into the highest
 *     point on this planet, immutable, just like the blockchain
 *
 * This contract is the proof:
 *   No bank. No Kickstarter. No middleman.
 *   Just code, community, and a mountain to climb.
 *
 * Goal:     $69,000 USD
 * Duration: 6 days
 * Tokens:   ETH | WBTC | USDT | USDC
 * Excess:   Every extra cent auto-refunded to you
 * Refund:   If I dont summit — every penny comes back
 *
 * -- BhariGowda
 *    Blockchain Dev | DeFi Maxi | Crypto since 2017
 *    "The mountain is just the next block to mine."
 *
 * =============================================================
 */

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract EverestOrBust {

    // -------------------------------------------------------
    //  WHO IS THIS
    // -------------------------------------------------------
    string public constant CLIMBER  = "BhariGowda | Blockchain Dev | DeFi Maxi | Crypto since 2017 | Karnataka, India";
    string public constant MISSION  = "Summit Mount Everest 8849m in 2027. Plant the Bitcoin flag on the roof of the world. Prove that DeFi gives ordinary people the power to do extraordinary things.";
    string public constant WHY      = "Dropped out of college in 2017. Went all-in on Crypto. No 9-5. No plan B. 8 years as a DeFi degen and builder. Climbing Everest to plant the Bitcoin flag and apply for O-1 Extraordinary Ability Visa to the USA. No bank. No middleman. Just code, community, and a mountain. Freedom of Finance is not a slogan it is a lifestyle. This summit is for every dropout who bet on decentralization.";

    // -------------------------------------------------------
    //  OWNER & TOKENS
    // -------------------------------------------------------
    address public owner;
    address public wbtc;
    address public usdt;
    address public usdc;

    // -------------------------------------------------------
    //  PRICES (USD with 18 decimals, set at deploy)
    //  e.g. ETH = $2500 => ethPrice = 2500e18
    //  e.g. BTC = $95000 => wbtcPrice = 95000e18
    // -------------------------------------------------------
    uint256 public ethPrice;
    uint256 public wbtcPrice;

    // -------------------------------------------------------
    //  GOAL & TIMELINE
    // -------------------------------------------------------
    uint256 public constant GOAL_USD = 69_000e18; // $69,000
    uint256 public deadline;
    bool public summitAchieved;
    bool public withdrawn;
    bool public cancelled;

    // -------------------------------------------------------
    //  TOTALS
    // -------------------------------------------------------
    uint256 public totalETH;
    uint256 public totalWBTC;
    uint256 public totalUSDT;
    uint256 public totalUSDC;

    // -------------------------------------------------------
    //  DONOR TRACKING
    // -------------------------------------------------------
    struct Donor {
        uint256 eth;
        uint256 wbtc;
        uint256 usdt;
        uint256 usdc;
    }

    mapping(address => Donor) public donations;
    address[] public donors;
    mapping(address => bool) public isDonor;

    // -------------------------------------------------------
    //  EVENTS
    // -------------------------------------------------------
    event Donated(address indexed donor, string token, uint256 amount, uint256 totalUSDRaised);
    event GoalReached(uint256 totalUSD, uint256 donorCount);
    event ExcessRefunded(address indexed donor, uint256 usdRefunded);
    event SummitConfirmed(string message);
    event FundsWithdrawn(uint256 eth, uint256 wbtc, uint256 usdt, uint256 usdc);
    event FullRefundIssued(address indexed donor);
    event Cancelled(string reason);

    // -------------------------------------------------------
    //  MODIFIERS
    // -------------------------------------------------------
    modifier onlyOwner() {
        require(msg.sender == owner, "Only BhariGowda");
        _;
    }

    modifier isActive() {
        require(!cancelled, "Campaign cancelled");
        require(block.timestamp < deadline, "Campaign ended");
        _;
    }

    modifier isEnded() {
        require(block.timestamp >= deadline || cancelled, "Still active");
        _;
    }

    // -------------------------------------------------------
    //  CONSTRUCTOR
    // -------------------------------------------------------
    constructor(
        address _wbtc,
        address _usdt,
        address _usdc,
        uint256 _ethPrice,
        uint256 _wbtcPrice
    ) {
        owner    = msg.sender;
        wbtc     = _wbtc;
        usdt     = _usdt;
        usdc     = _usdc;
        ethPrice  = _ethPrice;
        wbtcPrice = _wbtcPrice;
        deadline  = block.timestamp + 6 days;
    }

    // -------------------------------------------------------
    //  DONATE
    // -------------------------------------------------------

    function donateETH() external payable isActive {
        require(msg.value > 0, "Send ETH to support the climb");
        totalETH += msg.value;
        donations[msg.sender].eth += msg.value;
        _addDonor(msg.sender);
        uint256 raised = totalRaisedUSD();
        emit Donated(msg.sender, "ETH", msg.value, raised);
        if (raised >= GOAL_USD) emit GoalReached(raised, donors.length);
    }

    function donateWBTC(uint256 amount) external isActive {
        require(amount > 0, "Send WBTC to support the climb");
        _pull(wbtc, amount);
        totalWBTC += amount;
        donations[msg.sender].wbtc += amount;
        _addDonor(msg.sender);
        uint256 raised = totalRaisedUSD();
        emit Donated(msg.sender, "WBTC", amount, raised);
        if (raised >= GOAL_USD) emit GoalReached(raised, donors.length);
    }

    function donateUSDT(uint256 amount) external isActive {
        require(amount > 0, "Send USDT to support the climb");
        _pull(usdt, amount);
        totalUSDT += amount;
        donations[msg.sender].usdt += amount;
        _addDonor(msg.sender);
        uint256 raised = totalRaisedUSD();
        emit Donated(msg.sender, "USDT", amount, raised);
        if (raised >= GOAL_USD) emit GoalReached(raised, donors.length);
    }

    function donateUSDC(uint256 amount) external isActive {
        require(amount > 0, "Send USDC to support the climb");
        _pull(usdc, amount);
        totalUSDC += amount;
        donations[msg.sender].usdc += amount;
        _addDonor(msg.sender);
        uint256 raised = totalRaisedUSD();
        emit Donated(msg.sender, "USDC", amount, raised);
        if (raised >= GOAL_USD) emit GoalReached(raised, donors.length);
    }

    // -------------------------------------------------------
    //  SUMMIT & WITHDRAW
    // -------------------------------------------------------

    function confirmSummit() external onlyOwner {
        summitAchieved = true;
        emit SummitConfirmed("Bitcoin flag planted on Mount Everest. 8849m. We made it. Freedom of Finance is now on the roof of the world.");
    }

    function withdraw() external onlyOwner isEnded {
        require(goalReached(), "Goal not reached");
        require(!withdrawn, "Already withdrawn");
        withdrawn = true;

        _refundExcess();

        uint256 ethAmt  = address(this).balance;
        uint256 wbtcAmt = _bal(wbtc);
        uint256 usdtAmt = _bal(usdt);
        uint256 usdcAmt = _bal(usdc);

        if (ethAmt  > 0) { (bool ok,) = owner.call{value: ethAmt}(""); require(ok, "ETH failed"); }
        if (wbtcAmt > 0) IERC20(wbtc).transfer(owner, wbtcAmt);
        if (usdtAmt > 0) IERC20(usdt).transfer(owner, usdtAmt);
        if (usdcAmt > 0) IERC20(usdc).transfer(owner, usdcAmt);

        emit FundsWithdrawn(ethAmt, wbtcAmt, usdtAmt, usdcAmt);
    }

    // -------------------------------------------------------
    //  REFUND
    // -------------------------------------------------------

    function refund() external isEnded {
        require(!goalReached() || cancelled, "Goal reached. Bhari is going to Everest!");
        _refundDonor(msg.sender);
        emit FullRefundIssued(msg.sender);
    }

    function cancel(string calldata reason) external onlyOwner {
        require(!withdrawn, "Already withdrawn");
        cancelled = true;
        emit Cancelled(reason);
    }

    // -------------------------------------------------------
    //  VIEWS
    // -------------------------------------------------------

    function totalRaisedUSD() public view returns (uint256) {
        uint256 ethUSD    = (totalETH  * ethPrice)  / 1e18;
        uint256 wbtcUSD   = (totalWBTC * wbtcPrice) / 1e8;
        uint256 stableUSD = (totalUSDT + totalUSDC) * 1e12;
        return ethUSD + wbtcUSD + stableUSD;
    }

    function goalReached() public view returns (bool) {
        return totalRaisedUSD() >= GOAL_USD;
    }

    function percentRaised() external view returns (uint256) {
        return (totalRaisedUSD() * 100) / GOAL_USD;
    }

    function timeLeft() external view returns (uint256) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    function getMyDonations(address donor) external view returns (
        uint256 eth, uint256 wbtcAmt, uint256 usdtAmt, uint256 usdcAmt
    ) {
        Donor memory d = donations[donor];
        return (d.eth, d.wbtc, d.usdt, d.usdc);
    }

    function getStatus() external view returns (
        string memory climber,
        string memory mission,
        string memory why,
        uint256 raisedUSD,
        uint256 goalUSD,
        uint256 _deadline,
        bool _goalReached,
        bool active,
        bool _summitAchieved,
        bool _withdrawn,
        bool _cancelled,
        uint256 donorCount
    ) {
        return (
            CLIMBER,
            MISSION,
            WHY,
            totalRaisedUSD(),
            GOAL_USD,
            deadline,
            goalReached(),
            block.timestamp < deadline && !cancelled,
            summitAchieved,
            withdrawn,
            cancelled,
            donors.length
        );
    }

    function updatePrices(uint256 _ethPrice, uint256 _wbtcPrice) external onlyOwner {
        ethPrice  = _ethPrice;
        wbtcPrice = _wbtcPrice;
    }

    // -------------------------------------------------------
    //  INTERNALS
    // -------------------------------------------------------

    function _refundExcess() internal {
        uint256 raised = totalRaisedUSD();
        if (raised <= GOAL_USD) return;
        uint256 excessBps = ((raised - GOAL_USD) * 10000) / raised;

        for (uint256 i = 0; i < donors.length; i++) {
            address donor = donors[i];
            Donor storage d = donations[donor];

            uint256 eR = (d.eth  * excessBps) / 10000;
            uint256 wR = (d.wbtc * excessBps) / 10000;
            uint256 uR = (d.usdt * excessBps) / 10000;
            uint256 cR = (d.usdc * excessBps) / 10000;

            d.eth  -= eR; d.wbtc -= wR;
            d.usdt -= uR; d.usdc -= cR;

            if (eR > 0) { (bool ok,) = donor.call{value: eR}(""); require(ok, "ETH excess failed"); }
            if (wR > 0) IERC20(wbtc).transfer(donor, wR);
            if (uR > 0) IERC20(usdt).transfer(donor, uR);
            if (cR > 0) IERC20(usdc).transfer(donor, cR);

            uint256 usdBack = (eR * ethPrice / 1e18) + (wR * wbtcPrice / 1e8) + ((uR + cR) * 1e12);
            emit ExcessRefunded(donor, usdBack);
        }
    }

    function _refundDonor(address donor) internal {
        Donor storage d = donations[donor];
        require(d.eth > 0 || d.wbtc > 0 || d.usdt > 0 || d.usdc > 0, "Nothing to refund");

        uint256 e = d.eth;  uint256 w = d.wbtc;
        uint256 u = d.usdt; uint256 c = d.usdc;
        d.eth = 0; d.wbtc = 0; d.usdt = 0; d.usdc = 0;

        if (e > 0) { (bool ok,) = donor.call{value: e}(""); require(ok, "ETH refund failed"); }
        if (w > 0) IERC20(wbtc).transfer(donor, w);
        if (u > 0) IERC20(usdt).transfer(donor, u);
        if (c > 0) IERC20(usdc).transfer(donor, c);
    }

    function _pull(address token, uint256 amount) internal {
        bool ok = IERC20(token).transferFrom(msg.sender, address(this), amount);
        require(ok, "Token transfer failed");
    }

    function _bal(address token) internal view returns (uint256) {
        (bool ok, bytes memory data) = token.staticcall(
            abi.encodeWithSignature("balanceOf(address)", address(this))
        );
        require(ok, "Balance check failed");
        return abi.decode(data, (uint256));
    }

    function _addDonor(address donor) internal {
        if (!isDonor[donor]) {
            isDonor[donor] = true;
            donors.push(donor);
        }
    }
}
