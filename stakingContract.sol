
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";


contract StakeToken {
    
    string public name = "Staking";
    
    IERC20 public stakeableToken;
    
    IERC20 public rewardToken;
    
    struct stakeDetails{
        uint amount;
        uint stakingDate;
        uint unstakingDate;
    }
    
    mapping (address => stakeDetails[]) public stakingBalance;
    
    
    constructor(address _stakeableToken, address _rewardToken) public {
        stakeableToken = IERC20(_stakeableToken);
        rewardToken = IERC20(_rewardToken);
    }
    
    function stakeTokens(uint _amount) external{
        require(_amount > 0, "The amount must be bigger than 0");
        stakeableToken.transferFrom(msg.sender, address(this), _amount);
        stakingBalance[msg.sender].push(stakeDetails(_amount, block.timestamp, 0));
    }
    
    function unstakeTokens(uint index) external{
        uint stakingDate = stakingBalance[msg.sender][index].stakingDate;
        uint unstakeValidTime = stakingDate + 30 days;
        require(block.timestamp > unstakeValidTime, "Invalid unstake");
        uint balance = stakingBalance[msg.sender][index].amount;
        require(balance > 0, "Staking blanace must be > 0");
        stakeableToken.transfer(msg.sender, balance);
        stakingBalance[msg.sender][index].amount = 0;
        uint reward = rewardCalculation(balance, stakingDate, block.timestamp);
        if(reward > 0){
            rewardToken.transfer(msg.sender, reward);
        }
        stakingBalance[msg.sender][index].unstakingDate = block.timestamp;
    }
    
    function rewardCalculation(uint balance, uint startDate, uint endDate) internal pure returns(uint){
        uint _days = diffDays(startDate, endDate);
        if(balance >= 100 && balance <1000){
            return _days * 10;
        }else if(balance >= 1000 && balance <10000){
             return _days * 20;
        }else if(balance >= 10000){
             return _days * 30;
        }
        return 0;
    }
    
     function diffDays(uint startDate, uint endDate) internal pure returns (uint _days) {
        require(startDate <= endDate);
        uint secondsPerDay = 86400;
        _days = (endDate - startDate) / secondsPerDay;
    }
}