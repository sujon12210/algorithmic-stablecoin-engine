# Algorithmic Stablecoin Engine

This repository provides a robust framework for an algorithmic stablecoin system. Unlike collateralized stablecoins (like USDC or DAI), this system uses a multi-token model to regulate supply based on market demand.

## The Three-Token Model
* **Stablecoin (CASH):** The asset intended to be pegged to $1.00.
* **Share (SHARE):** Governance tokens that receive seigniorage (newly minted CASH) during expansion.
* **Bond (BOND):** Sold during contraction (when CASH < $1) to burn CASH and reduce supply, redeemable for CASH when the peg recovers.

## Mechanisms
### Expansion (Price > $1.00)
The Treasury mints new CASH. This new supply is distributed to SHARE holders who have staked their tokens in the Boardroom.

### Contraction (Price < $1.00)
The Treasury allows users to burn CASH in exchange for BONDs at a discount. This removes CASH from circulation, driving the price back up toward the peg.



## Security
* **Epoch-based logic:** Rebase and minting events only occur at fixed intervals (e.g., every 8 hours).
* **Oracle Integration:** Uses external price feeds to determine the current market peg.
