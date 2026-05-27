# Changelog

## 2026-05-26
- Security audit completed — 7 findings identified
- Fixed C-1: Griefing DoS in _refundExcess() push loop
- Fixed H-1: summitAchieved not enforced in withdraw()
- Fixed M-2: Unchecked ERC20 transfer() return values
- Fixed L-1: Accounting desync in _refundDonor()
- 23 Foundry tests passing

## 2026-05-18
- Added Foundry setup with foundry.toml
- Added deployment script for EverestOrBust
- Added .gitignore

## 2026-05-14
- Added EverestOrBust crowdfunding contract
- Added MultiSigWallet, Staking contracts
