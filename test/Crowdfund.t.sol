// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/Crowdfund.sol";

contract CrowdfundTest is Test {
    EverestOrBust public crowdfund;
    address public owner = address(1);
    address public donor1 = address(2);
    address public donor2 = address(3);
    address public stranger = address(4);

    uint256 public ethPrice  = 2500e18;
    uint256 public wbtcPrice = 95000e18;

    function setUp() public {
        vm.prank(owner);
        crowdfund = new EverestOrBust(
            address(0), address(0), address(0),
            ethPrice, wbtcPrice
        );
    }

    function test_GoalIsCorrect() public view {
        assertEq(crowdfund.GOAL_USD(), 69_000e18);
    }

    function test_GoalNotReachedInitially() public view {
        assertFalse(crowdfund.goalReached());
    }

    function test_OwnerIsSetCorrectly() public view {
        assertEq(crowdfund.owner(), owner);
    }

    function test_DeadlineIsSet() public view {
        assertGt(crowdfund.deadline(), block.timestamp);
    }

    function test_DonateETH() public {
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        crowdfund.donateETH{value: 1 ether}();
        assertEq(crowdfund.totalETH(), 1 ether);
    }

    function test_DonateETHTrackedPerDonor() public {
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        crowdfund.donateETH{value: 2 ether}();
        (uint256 eth,,,) = crowdfund.getMyDonations(donor1);
        assertEq(eth, 2 ether);
    }

    function test_MultipleDonors() public {
        vm.deal(donor1, 10 ether);
        vm.deal(donor2, 10 ether);
        vm.prank(donor1);
        crowdfund.donateETH{value: 1 ether}();
        vm.prank(donor2);
        crowdfund.donateETH{value: 2 ether}();
        assertEq(crowdfund.totalETH(), 3 ether);
    }

    function test_CannotDonateZeroETH() public {
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        vm.expectRevert("Send ETH to support the climb");
        crowdfund.donateETH{value: 0}();
    }

    function test_CannotDonateAfterDeadline() public {
        vm.warp(block.timestamp + 7 days);
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        vm.expectRevert("Campaign ended");
        crowdfund.donateETH{value: 1 ether}();
    }

    function test_TotalRaisedUSDCalculation() public {
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        crowdfund.donateETH{value: 1 ether}();
        assertEq(crowdfund.totalRaisedUSD(), 2500e18);
    }

    function test_PercentRaisedUpdates() public {
        vm.deal(donor1, 20 ether);
        vm.prank(donor1);
        crowdfund.donateETH{value: 13.8 ether}();
        assertGt(crowdfund.percentRaised(), 49);
    }

    function test_OwnerCanConfirmSummit() public {
        vm.prank(owner);
        crowdfund.confirmSummit();
        assertTrue(crowdfund.summitAchieved());
    }

    function test_StrangerCannotConfirmSummit() public {
        vm.prank(stranger);
        vm.expectRevert("Only BhariGowda");
        crowdfund.confirmSummit();
    }

    function test_OwnerCanUpdatePrices() public {
        vm.prank(owner);
        crowdfund.updatePrices(3000e18, 100000e18);
        assertEq(crowdfund.ethPrice(), 3000e18);
    }

    function test_StrangerCannotUpdatePrices() public {
        vm.prank(stranger);
        vm.expectRevert("Only BhariGowda");
        crowdfund.updatePrices(3000e18, 100000e18);
    }

    function test_OwnerCanCancel() public {
        vm.prank(owner);
        crowdfund.cancel("Changed plans");
        assertTrue(crowdfund.cancelled());
    }

    function test_StrangerCannotCancel() public {
        vm.prank(stranger);
        vm.expectRevert("Only BhariGowda");
        crowdfund.cancel("hack attempt");
    }

    function test_CannotDonateAfterCancel() public {
        vm.prank(owner);
        crowdfund.cancel("Changed plans");
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        vm.expectRevert("Campaign cancelled");
        crowdfund.donateETH{value: 1 ether}();
    }

    function test_RefundAfterCancel() public {
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        crowdfund.donateETH{value: 1 ether}();
        vm.prank(owner);
        crowdfund.cancel("Changed plans");
        uint256 balBefore = donor1.balance;
        vm.prank(donor1);
        crowdfund.refund();
        assertEq(donor1.balance, balBefore + 1 ether);
    }

    function test_RefundAfterDeadlineMissed() public {
        vm.deal(donor1, 10 ether);
        vm.prank(donor1);
        crowdfund.donateETH{value: 1 ether}();
        vm.warp(block.timestamp + 7 days);
        uint256 balBefore = donor1.balance;
        vm.prank(donor1);
        crowdfund.refund();
        assertEq(donor1.balance, balBefore + 1 ether);
    }

    function test_CannotRefundIfNothingDonated() public {
        vm.warp(block.timestamp + 7 days);
        vm.prank(stranger);
        vm.expectRevert("Nothing to refund");
        crowdfund.refund();
    }

    function test_TimeLeftDecreasesOverTime() public {
        uint256 t1 = crowdfund.timeLeft();
        vm.warp(block.timestamp + 1 days);
        uint256 t2 = crowdfund.timeLeft();
        assertLt(t2, t1);
    }

    function test_TimeLeftIsZeroAfterDeadline() public {
        vm.warp(block.timestamp + 7 days);
        assertEq(crowdfund.timeLeft(), 0);
    }
}
