# EverestOrBust Security Audit
**Date:** 2026-05-25  
**Contract:** contracts/Crowdfund.sol  
**Method:** Manual review + automated static analysis

## Findings Summary

| ID | Severity | Title | Status |
|---|---|---|---|
| C-1 | Critical | Griefing DoS in _refundExcess() push loop | ✅ Fixed |
| H-1 | High | summitAchieved not enforced in withdraw() | ✅ Fixed |
| H-2 | High | Unbounded donors loop gas DoS | ✅ Fixed (pull pattern) |
| M-1 | Medium | Owner-controlled price oracle | ⚠️ Acknowledged |
| M-2 | Medium | Unchecked ERC20 transfer() return values | ✅ Fixed |
| L-1 | Low | Accounting desync - totals never decremented | ✅ Fixed |
| I-1 | Info | Individual ETH-donor DoS in _refundDonor | ⚠️ Acknowledged |

## Fixes Applied
- C-1/H-2: Replaced push loop with pull pattern + claimExcess()
- H-1: Added require(summitAchieved) to withdraw()
- M-2: Added require(ok) on all ERC20 transfer() calls
- L-1: Decrement totalETH/WBTC/USDT/USDC in _refundDonor
