// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

interface IToken is IERC20 {
    function mint(address to, uint256 amount) external;
    function burnFrom(address from, uint256 amount) external;
}

contract Treasury is Ownable, ReentrancyGuard {
    address public cash;
    address public bond;
    address public share;
    
    uint256 public constant PERIOD = 8 hours;
    uint256 public lastEpochTime;
    uint256 public epoch = 0;

    event Migration(address indexed target);
    event TreasuryFunded(uint256 timestamp, uint256 seigniorage);

    constructor(address _cash, address _bond, address _share) Ownable(msg.sender) {
        cash = _cash;
        bond = _bond;
        share = _share;
        lastEpochTime = block.timestamp;
    }

    /**
     * @dev Core expansion/contraction logic triggered every epoch.
     * @param _price The current price from the Oracle.
     */
    function allocateSeigniorage(uint256 _price) external onlyOwner {
        require(block.timestamp >= lastEpochTime + PERIOD, "Epoch not reached");
        
        if (_price > 1e18) { // Price > $1.00
            uint256 percentage = (_price - 1e18);
            uint256 supply = IERC20(cash).totalSupply();
            uint256 amountToMint = (supply * percentage) / 1e18;
            
            IToken(cash).mint(address(this), amountToMint);
            // In a full implementation, distribute amountToMint to the Boardroom/Shareholders
            emit TreasuryFunded(block.timestamp, amountToMint);
        }
        
        lastEpochTime = block.timestamp;
        epoch++;
    }

    function buyBonds(uint256 _amount, uint256 _targetPrice) external nonReentrant {
        require(_targetPrice < 1e18, "Price must be below peg to buy bonds");
        IToken(cash).burnFrom(msg.sender, _amount);
        IToken(bond).mint(msg.sender, _amount);
    }
}
