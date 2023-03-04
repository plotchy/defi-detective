/**
 *Submitted for verification at Etherscan.io on 2021-09-07
*/

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev   Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256){
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b,"Calculation error in multiplication");
        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256){
        // Solidity only automatically asserts when dividing by 0
        require(b > 0,"Calculation error in division");
        uint256 c = a / b;
        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256){
        require(b <= a,"Calculation error in subtraction");
        uint256 c = a - b;
        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256){
        uint256 c = a + b;
        require(c >= a,"Calculation error in addition");
        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256){
        require(b != 0,"Calculation error");
        return a % b;
    }
}

/**
 * @title IToken
 * @dev   Contract interface for token contract 
 */
contract IToken {
    function totalSupply() public pure returns (uint256);
    function balanceOf(address) public pure returns (uint256);
    function allowance(address, address) public pure returns (uint256);
    function transfer(address, uint256) public pure returns (bool);
    function transferFrom(address, address, uint256) public pure returns (bool);
    function approve(address, uint256) public pure returns (bool);
 }

 /**
 * @title CoretoStaking
 * @dev   Staking Contract for token staking
 */
contract CoretoStaking {
    
  using SafeMath for uint256;
  address private _owner;                                                      // variable for Owner of the Contract.
  uint256 private _withdrawTime;                                               // variable to manage withdraw time for token
  uint256 constant public PERIOD_SERENITY                     = 90;            // variable constant for time period management for serenity pool
  uint256 constant public PERIOD_EQUILIBRIUM                  = 180;           // variable constant for time period management for equilibrium pool
  uint256 constant public PERIOD_TRANQUILLITY                 = 270;           // variable constant for time period management for tranquillity pool
  uint256 constant public WITHDRAW_TIME_SERENITY              = 45 * 1 days;   // variable constant to manage withdraw time lock up for serenity
  uint256 constant public WITHDRAW_TIME_EQUILIBRIUM           = 90 * 1 days;   // variable constant to manage withdraw time lock up for equilibrium
  uint256 constant public WITHDRAW_TIME_TRANQUILLITY          = 135 * 1 days;  // variable constant to manage withdraw time lock up for tranquillity
  uint256 constant public TOKEN_REWARD_PERCENT_SERENITY       = 3555807;       // variable constant to manage token reward percentage for serenity
  uint256 constant public TOKEN_REWARD_PERCENT_EQUILIBRIUM    = 10905365;      // variable constant to manage token reward percentage for equilibrium
  uint256 constant public TOKEN_REWARD_PERCENT_TRANQUILLITY   = 26010053;      // variable constant to manage token reward percentage for tranquillity
  uint256 constant public TOKEN_PENALTY_PERCENT_SERENITY      = 2411368;       // variable constant to manage token penalty percentage for serenity
  uint256 constant public TOKEN_PENALTY_PERCENT_EQUILIBRIUM   = 7238052;       // variable constant to manage token penalty percentage for equilibrium
  uint256 constant public TOKEN_PENALTY_PERCENT_TRANQUILLITY  = 14692434;      // variable constant to manage token penalty percentage for tranquillity
  uint256 constant public TOKEN_POOL_CAP              = 25000000*(10**18);     // variable constant to store maximaum pool cap value
  
  // events to handle staking pause or unpause for token
  event Paused();
  event Unpaused();
  
  /*
  * ---------------------------------------------------------------------------------------------------------------------------
  * Functions for owner.
  * ---------------------------------------------------------------------------------------------------------------------------
  */

   /**
   * @dev get address of smart contract owner
   * @return address of owner
   */
   function getowner() public view returns (address) {
     return _owner;
   }

   /**
   * @dev modifier to check if the message sender is owner
   */
   modifier onlyOwner() {
     require(isOwner(),"You are not authenticate to make this transfer");
     _;
   }

   /**
   * @dev Internal function for modifier
   */
   function isOwner() internal view returns (bool) {
      return msg.sender == _owner;
   }

   /**
   * @dev Transfer ownership of the smart contract. For owner only
   * @return request status
   */
   function transferOwnership(address newOwner) public onlyOwner returns (bool){
      _owner = newOwner;
      return true;
   }
   
  /*
  * ---------------------------------------------------------------------------------------------------------------------------
  * Functionality of Constructor and Interface  
  * ---------------------------------------------------------------------------------------------------------------------------
  */
  
  // constructor to declare owner of the contract during time of deploy  
  constructor() public {
     _owner = msg.sender;
  }
  
  // Interface declaration for contract
  IToken itoken;
    
  // function to set Contract Address for Token Functions
  function setContractAddress(address tokenContractAddress) external onlyOwner returns(bool){
    itoken = IToken(tokenContractAddress);
    return true;
  }
  
   /*
  * ----------------------------------------------------------------------------------------------------------------------------
  * Owner functions of get value, set value and other Functionality
  * ----------------------------------------------------------------------------------------------------------------------------
  */
  
  // function to add token reward in contract
  function addTokenReward(uint256 token) external onlyOwner returns(bool){
    _ownerTokenAllowance = _ownerTokenAllowance.add(token);
    itoken.transferFrom(msg.sender, address(this), token);
    return true;
  }
  
  // function to withdraw added token reward in contract
  function withdrawAddedTokenReward(uint256 token) external onlyOwner returns(bool){
    require(token < _ownerTokenAllowance,"Value is not feasible, Please Try Again!!!");
    _ownerTokenAllowance = _ownerTokenAllowance.sub(token);
    itoken.transfer(msg.sender, token);
    return true;
  }
  
  // function to get token reward in contract
  function getTokenReward() public view returns(uint256){
    return _ownerTokenAllowance;
  }
  
  // function to pause Token Staking
  function pauseTokenStaking() public onlyOwner {
    tokenPaused = true;
    emit Paused();
  }

  // function to unpause Token Staking
  function unpauseTokenStaking() public onlyOwner {
    tokenPaused = false;
    emit Unpaused();
  }

  /*
  * ----------------------------------------------------------------------------------------------------------------------------
  * Variable, Mapping for Token Staking Functionality
  * ----------------------------------------------------------------------------------------------------------------------------
  */
  
  // mapping for users with id => address Staking Address
  mapping (uint256 => address) private _tokenStakingAddress;
  
  // mapping for users with address => id staking id
  mapping (address => uint256[]) private _tokenStakingId;

  // mapping for users with id => Staking Time
  mapping (uint256 => uint256) private _tokenStakingStartTime;
  
  // mapping for users with id => End Time
  mapping (uint256 => uint256) private _tokenStakingEndTime;

  // mapping for users with id => Tokens 
  mapping (uint256 => uint256) private _usersTokens;
  
  // mapping for users with id => Status
  mapping (uint256 => bool) private _TokenTransactionstatus;    
  
  // mapping to keep track of final withdraw value of staked token
  mapping(uint256=>uint256) private _finalTokenStakeWithdraw;
  
  // mapping to keep track total number of staking days
  mapping(uint256=>uint256) private _tokenTotalDays;
  
  // variable to keep count of Token Staking
  uint256 private _tokenStakingCount = 0;
  
  // variable to keep track on reward added by owner
  uint256 private _ownerTokenAllowance = 0;

  // variable for token time management
  uint256 private _tokentime;
  
  // variable for token staking pause and unpause mechanism
  bool public tokenPaused = false;
  
  // variable for total Token staked by user
  uint256 public totalStakedToken = 0;
  
  // variable for total stake token in contract
  uint256 public totalTokenStakesInContract = 0;
  
  // variable for total stake token in a pool
  uint256 public totalStakedTokenInSerenityPool = 0;
  
  // variable for total stake token in a pool
  uint256 public totalStakedTokenInEquilibriumPool = 0;
  
  // variable for total stake token in a pool
  uint256 public totalStakedTokenInTranquillityPool = 0;
  
  // modifier to check the user for staking || Re-enterance Guard
  modifier tokenStakeCheck(uint256 tokens, uint256 timePeriod){
    require(tokens > 0, "Invalid Token Amount, Please Try Again!!! ");
    require(timePeriod == PERIOD_SERENITY || timePeriod == PERIOD_EQUILIBRIUM || timePeriod == PERIOD_TRANQUILLITY, "Enter the Valid Time Period and Try Again !!!");
    _;
  }
  
  /*
  * ------------------------------------------------------------------------------------------------------------------------------
  * Functions for Token Staking Functionality
  * ------------------------------------------------------------------------------------------------------------------------------
  */

  // function to performs staking for user tokens for a specific period of time
  function stakeToken(uint256 tokens, uint256 time) public tokenStakeCheck(tokens, time) returns(bool){
    require(tokenPaused == false, "Staking is Paused, Please try after staking get unpaused!!!");
    if(time == PERIOD_SERENITY){
        require(totalStakedTokenInSerenityPool.add(tokens) <= TOKEN_POOL_CAP, "Serenity Pool Limit Reached");
        _tokentime = now + (time * 1 days);
        _tokenStakingCount = _tokenStakingCount +1;
        _tokenTotalDays[_tokenStakingCount] = time;
        _tokenStakingAddress[_tokenStakingCount] = msg.sender;
        _tokenStakingId[msg.sender].push(_tokenStakingCount);
        _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
        _tokenStakingStartTime[_tokenStakingCount] = now;
        _usersTokens[_tokenStakingCount] = tokens;
        _TokenTransactionstatus[_tokenStakingCount] = false;
        totalStakedToken = totalStakedToken.add(tokens);
        totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
        totalStakedTokenInSerenityPool = totalStakedTokenInSerenityPool.add(tokens);
        itoken.transferFrom(msg.sender, address(this), tokens);
    } else if (time == PERIOD_EQUILIBRIUM) {
        require(totalStakedTokenInEquilibriumPool.add(tokens) <= TOKEN_POOL_CAP, "Equilibrium Pool Limit Reached");
        _tokentime = now + (time * 1 days);
        _tokenStakingCount = _tokenStakingCount +1;
        _tokenTotalDays[_tokenStakingCount] = time;
        _tokenStakingAddress[_tokenStakingCount] = msg.sender;
        _tokenStakingId[msg.sender].push(_tokenStakingCount);
        _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
        _tokenStakingStartTime[_tokenStakingCount] = now;
        _usersTokens[_tokenStakingCount] = tokens;
        _TokenTransactionstatus[_tokenStakingCount] = false;
        totalStakedToken = totalStakedToken.add(tokens);
        totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
        totalStakedTokenInEquilibriumPool = totalStakedTokenInEquilibriumPool.add(tokens);
        itoken.transferFrom(msg.sender, address(this), tokens);
    } else if(time == PERIOD_TRANQUILLITY) {
        require(totalStakedTokenInTranquillityPool.add(tokens) <= TOKEN_POOL_CAP, "Tranquillity Pool Limit Reached");
        _tokentime = now + (time * 1 days);
        _tokenStakingCount = _tokenStakingCount +1;
        _tokenTotalDays[_tokenStakingCount] = time;
        _tokenStakingAddress[_tokenStakingCount] = msg.sender;
        _tokenStakingId[msg.sender].push(_tokenStakingCount);
        _tokenStakingEndTime[_tokenStakingCount] = _tokentime;
        _tokenStakingStartTime[_tokenStakingCount] = now;
        _usersTokens[_tokenStakingCount] = tokens;
        _TokenTransactionstatus[_tokenStakingCount] = false;
        totalStakedToken = totalStakedToken.add(tokens);
        totalTokenStakesInContract = totalTokenStakesInContract.add(tokens);
        totalStakedTokenInTranquillityPool = totalStakedTokenInTranquillityPool.add(tokens);
        itoken.transferFrom(msg.sender, address(this), tokens);
    } else {
        return false;
      }
    return true;
  }

  // function to get staking count for token
  function getTokenStakingCount() public view returns(uint256){
    return _tokenStakingCount;
  }
  
  // function to get total Staked tokens
  function getTotalStakedToken() public view returns(uint256){
    return totalStakedToken;
  }
  
  // function to calculate reward for the message sender for token
  function getTokenRewardDetailsByStakingId(uint256 id) public view returns(uint256){
    if(_tokenTotalDays[id] == PERIOD_SERENITY) {
        return (_usersTokens[id]*TOKEN_REWARD_PERCENT_SERENITY/100000000);
    } else if(_tokenTotalDays[id] == PERIOD_EQUILIBRIUM) {
               return (_usersTokens[id]*TOKEN_REWARD_PERCENT_EQUILIBRIUM/100000000);
      } else if(_tokenTotalDays[id] == PERIOD_TRANQUILLITY) { 
                 return (_usersTokens[id]*TOKEN_REWARD_PERCENT_TRANQUILLITY/100000000);
        } else{
              return 0;
          }
  }

  // function to calculate penalty for the message sender for token
  function getTokenPenaltyDetailByStakingId(uint256 id) public view returns(uint256){
    if(_tokenStakingEndTime[id] > now){
        if(_tokenTotalDays[id]==PERIOD_SERENITY){
            return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_SERENITY/100000000);
        } else if(_tokenTotalDays[id] == PERIOD_EQUILIBRIUM) {
              return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_EQUILIBRIUM/100000000);
          } else if(_tokenTotalDays[id] == PERIOD_TRANQUILLITY) { 
                return (_usersTokens[id]*TOKEN_PENALTY_PERCENT_TRANQUILLITY/100000000);
            } else {
                return 0;
              }
    } else{
       return 0;
     }
  }
 
  // function to withdraw staked tokens
  function withdrawStakedTokens(uint256 stakingId) public returns(bool) {
    require(_tokenStakingAddress[stakingId] == msg.sender,"No staked token found on this address and ID");
    require(_TokenTransactionstatus[stakingId] != true,"Either tokens are already withdrawn or blocked by admin");
    if(_tokenTotalDays[stakingId] == PERIOD_SERENITY){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_SERENITY, "Unable to Withdraw Staked token before 45 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInSerenityPool = totalStakedTokenInSerenityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInSerenityPool = totalStakedTokenInSerenityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_EQUILIBRIUM){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_EQUILIBRIUM, "Unable to Withdraw Staked token before 90 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInEquilibriumPool = totalStakedTokenInEquilibriumPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInEquilibriumPool = totalStakedTokenInEquilibriumPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else if(_tokenTotalDays[stakingId] == PERIOD_TRANQUILLITY){
          require(now >= _tokenStakingStartTime[stakingId] + WITHDRAW_TIME_TRANQUILLITY, "Unable to Withdraw Staked token before 135 days of staking start time, Please Try Again Later!!!");
          _TokenTransactionstatus[stakingId] = true;
          if(now >= _tokenStakingEndTime[stakingId]){
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenRewardDetailsByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInTranquillityPool = totalStakedTokenInTranquillityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenRewardDetailsByStakingId(stakingId));
          } else {
              _finalTokenStakeWithdraw[stakingId] = _usersTokens[stakingId].add(getTokenPenaltyDetailByStakingId(stakingId));
              itoken.transfer(msg.sender,_finalTokenStakeWithdraw[stakingId]);
              totalTokenStakesInContract = totalTokenStakesInContract.sub(_usersTokens[stakingId]);
              totalStakedTokenInTranquillityPool = totalStakedTokenInTranquillityPool.sub(_usersTokens[stakingId]);
              _ownerTokenAllowance = _ownerTokenAllowance.sub(getTokenPenaltyDetailByStakingId(stakingId));
            }
    } else {
        return false;
      }
    return true;
  }
  
  // function to get Final Withdraw Staked value for token
  function getFinalTokenStakeWithdraw(uint256 id) public view returns(uint256){
    return _finalTokenStakeWithdraw[id];
  }
  
  // function to get total token stake in contract
  function getTotalTokenStakesInContract() public view returns(uint256){
      return totalTokenStakesInContract;
  }
  
  /*
  * -------------------------------------------------------------------------------------------------------------------------------
  * Get Functions for Stake Token Functionality
  * -------------------------------------------------------------------------------------------------------------------------------
  */

  // function to get Token Staking address by id
  function getTokenStakingAddressById(uint256 id) external view returns (address){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingAddress[id];
  }
  
  // function to get Token staking id by address
  function getTokenStakingIdByAddress(address add) external view returns(uint256[]){
    require(add != address(0),"Invalid Address, Pleae Try Again!!!");
    return _tokenStakingId[add];
  }
  
  // function to get Token Staking Starting time by id
  function getTokenStakingStartTimeById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingStartTime[id];
  }
  
  // function to get Token Staking Ending time by id
  function getTokenStakingEndTimeById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenStakingEndTime[id];
  }
  
  // function to get Token Staking Total Days by Id
  function getTokenStakingTotalDaysById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _tokenTotalDays[id];
  }

  // function to get Staking tokens by id
  function getStakingTokenById(uint256 id) external view returns(uint256){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _usersTokens[id];
  }

  // function to get Token lockstatus by id
  function getTokenLockStatus(uint256 id) external view returns(bool){
    require(id <= _tokenStakingCount,"Unable to reterive data on specified id, Please try again!!");
    return _TokenTransactionstatus[id];
  }

}