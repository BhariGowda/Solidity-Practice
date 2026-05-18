// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../contracts/Crowdfund.sol";

contract CrowdfundTest is Test {
    EverestOrBust public crowdfund;
    address public owner = address(1);
    address public donor = address(2);

    uint256 public ethPrice  = 2500e18;  // $2500
    uint256 public wbtcPrice = 95000e18; // $95000

    function setUp() public {
        vm.prank(owner);
        crowdfund = new EverestOrBust(
            address(0),  // no WBTC
            address(0),  // no USDT
            address(0),  // no USDC
            ethPrice,
            wbtcPrice
        );
    }

    function test_GoalIsCorrect() public view {
        assertEq(crowdfund.GOAL_USD(), 69_000e18);
    }

    function test_DonateETH() public {
        vm.deal(donor, 10 ether);
        vm.prank(donor);
        crowdfund.donateETH{value: 1 ether}();
        assertEq(crowdfund.totalETH(), 1 ether);
    }

    function test_GoalNotReachedInitially() public view {
        assertFalse(crowdfund.goalReached());
    }

    function test_OwnerCanConfirmSummit() public {
        vm.prank(owner);
        crowdfund.confirmSummit();
        assertTrue(crowdfund.summitAchieved());
    }

    function test_CannotDonateAfterDeadline() public {
        vm.warp(block.timestamp + 7 days);
        vm.deal(donor, 10 ether);
        vm.prank(donor);
        vm.expectRevert("Campaign ended");
        crowdfund.donateETH{value: 1 ether}();
    }
}
