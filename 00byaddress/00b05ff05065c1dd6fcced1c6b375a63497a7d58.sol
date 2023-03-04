/**
 *Submitted for verification at Etherscan.io on 2022-11-18
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
//pragma experimental ABIEncoderV2;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
//-------------------------------------------------------------------------------------
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
abstract contract ERC20 {
    uint public totalSupply;
    function balanceOf(address who) public virtual view returns (uint);
    function allowance(address owner, address spender) public virtual view returns (uint);

    function transfer(address to, uint value) public virtual returns (bool ok);
    function transferFrom(address from, address to, uint value) public virtual returns (bool ok);
    function approve(address spender, uint value) public virtual returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
}

abstract contract ERC223 is ERC20 {
    function transfer(address to, uint value, bytes  memory data) public virtual returns (bool ok);
    function transferFrom(address from, address to, uint value, bytes  memory data) public virtual returns (bool ok);
}

/*
Base class contracts willing to accept ERC223 token transfers must conform to.

Sender: msg.sender to the token contract, the address originating the token transfer.
          - For user originated transfers sender will be equal to tx.origin
          - For contract originated transfers, tx.origin will be the user that made the tx that produced the transfer.
Origin: the origin address from whose balance the tokens are sent
          - For transfer(), origin = msg.sender
          - For transferFrom() origin = _from to token contract
Value is the amount of tokens sent
Data is arbitrary data sent with the token transfer. Simulates ether tx.data

From, origin and value shouldn't be trusted unless the token contract is trusted.
If sender == tx.origin, it is safe to trust it regardless of the token.
*/

abstract contract ERC223Receiver {
    function tokenFallback(address _sender, address _origin, uint _value, bytes  memory _data) public virtual returns (bool ok);
}

abstract contract Standard223Receiver is ERC223Receiver {
    function supportsToken(address token) public virtual view returns (bool);
}


//-------------------------------------------------------------------------------------
//Implementation

contract MetaMediaToken223Token_15 is ERC20, ERC223, Standard223Receiver, SafeMath {

    mapping(address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
  
    string public name;                   //fancy name: eg Simon Bucks
    uint8 public decimals;                //How many decimals to show.
    string public symbol;                 //An identifier: eg SBX

    address /*public*/ contrInitiator;
    address /*public*/ thisContract;
    bool /*public*/ isTokenSupport;
  
    mapping(address => bool) isSendingLocked;
    bool isAllTransfersLocked;
  
    uint oneTransferLimit;
    uint oneDayTransferLimit;
 

    struct TransferInfo {
        //address sender;    //maybe use in the future
        //address from;      //no need because all this is kept in transferInfo[_from]
        //address to;        //maybe use in the future
        uint256 value;
        uint time;
    }

    struct TransferInfos {
        mapping (uint => TransferInfo) ti;
        uint tc;
    }
  
    mapping (address => TransferInfos) transferInfo;
    
    event SetIsSendingLocked(address _from, bool _lock);
    event SetIsAllTransfersLocked(bool _lock);

//-------------------------------------------------------------------------------------
//from ExampleToken

    constructor(/*uint initialBalance*/) {
    
        decimals    = 18;                                // Amount of decimals for display purposes
        name        = "Meta Media Token";                     // Set the name for display purposes
        symbol      = 'MML';                            // Set the symbol for display purposes

        uint initialBalance  = (10 ** uint256(decimals)) * 1000*1000*1000;
    
        balances[msg.sender] = initialBalance;
        totalSupply = initialBalance;
    
        contrInitiator = msg.sender;
        thisContract =address(this);
        isTokenSupport = false;
    
        isAllTransfersLocked = true;
    
        oneTransferLimit    = (10 ** uint256(decimals)) * 50*1000*1001;   // to simulate no limit
        oneDayTransferLimit = (10 ** uint256(decimals)) * 50*1000*1001;   // to simulate no limit

    // Ideally call token fallback here too
    }

//-------------------------------------------------------------------------------------
//from StandardToken

    function super_transfer(address _to, uint _value) /*public*/ internal returns (bool success) {

        require(!isSendingLocked[msg.sender]);
        require(_value <= oneTransferLimit);
        require(balances[msg.sender] >= _value);

        if(msg.sender == contrInitiator) {
            //no restricton
        } else {
            require(!isAllTransfersLocked);  
            require(safeAdd(getLast24hSendingValue(msg.sender), _value) <= oneDayTransferLimit);
        }


        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
    
        uint tc=transferInfo[msg.sender].tc;
        transferInfo[msg.sender].ti[tc].value = _value;
        transferInfo[msg.sender].ti[tc].time = block.timestamp;
        transferInfo[msg.sender].tc = safeAdd(transferInfo[msg.sender].tc, 1);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function super_transferFrom(address _from, address _to, uint _value) /*public*/ internal returns (bool success) {
        
        require(!isSendingLocked[_from]);
        require(_value <= oneTransferLimit);
        require(balances[_from] >= _value);

        if(msg.sender == contrInitiator && _from == thisContract) {
            // no restriction
        } else {
            require(!isAllTransfersLocked);  
            require(safeAdd(getLast24hSendingValue(_from), _value) <= oneDayTransferLimit);
            uint loc_allowance = allowed[_from][msg.sender];
            require(loc_allowance >= _value);
            uint new_allowance = safeSub(loc_allowance, _value);
            allowed[_from][msg.sender] = new_allowance;
            emit Approval(_from, msg.sender, new_allowance);
        }

        balances[_from] = safeSub(balances[_from], _value);
        balances[_to] = safeAdd(balances[_to], _value);
    
        uint tc=transferInfo[_from].tc;
        transferInfo[_from].ti[tc].value = _value;
        transferInfo[_from].ti[tc].time = block.timestamp;
        transferInfo[_from].tc = safeAdd(transferInfo[_from].tc, 1);

        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public override view returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _value) public override returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public override view returns (uint remaining) {
        return allowed[_owner][_spender];
    }
  
//-------------------------------------------------------------------------------------
//from Standard223Token

    //function that is called when a user or another contract wants to transfer funds
    function transfer(address _to, uint _value, bytes  memory _data) public override returns (bool success) {
        //filtering if the target is a contract with bytecode inside it
        if (!super_transfer(_to, _value)) assert(false); // do a normal token transfer
        if (isContract(_to)) {
            if(!contractFallback(msg.sender, _to, _value, _data)) assert(false);
        }
        return true;
    }

    function transferFrom(address _from, address _to, uint _value, bytes  memory _data) public override returns (bool success) {
        if (!super_transferFrom(_from, _to, _value)) assert(false); // do a normal token transfer
        if (isContract(_to)) {
            if(!contractFallback(_from, _to, _value, _data)) assert(false);
        }
        return true;
    }

    function transfer(address _to, uint _value) public override returns (bool success) {
        return transfer(_to, _value, new bytes(0));
    }

    function transferFrom(address _from, address _to, uint _value) public override returns (bool success) {
        return transferFrom(_from, _to, _value, new bytes(0));
    }

    //function that is called when transaction target is a contract
    function contractFallback(address _origin, address _to, uint _value, bytes  memory _data) private returns (bool success) {
        ERC223Receiver reciever = ERC223Receiver(_to);
        return reciever.tokenFallback(msg.sender, _origin, _value, _data);
    }

    //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        // retrieve the size of the code on target address, this needs assembly
        uint length;
        assembly { length := extcodesize(_addr) }
        return length > 0;
    }

//-------------------------------------------------------------------------------------
//from Standard223Receiver

    Tkn tkn;

    struct Tkn {
        address addr;
        address sender;
        address origin;
        uint256 value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address _sender, address _origin, uint _value, bytes  memory _data) public override returns (bool ok) {
        if (!supportsToken(msg.sender)) return false;

        // Problem: This will do a sstore which is expensive gas wise. Find a way to keep it in memory.
        tkn = Tkn(msg.sender, _sender, _origin, _value, _data, getSig(_data));
        __isTokenFallback = true;

//        if (!address(this).delegatecall(_data)) return false;
        (bool success, bytes memory response) = address(this).delegatecall(_data);
        response = response; //!!!!! will it work?
        if(!success)  return false;


        // avoid doing an overwrite to .token, which would be more expensive
        // makes accessing .tkn values outside tokenPayable functions unsafe
        __isTokenFallback = false;

        return true;
    }

    function getSig(bytes  memory _data) private pure returns (bytes4 sig) {
        uint l = _data.length < 4 ? _data.length : 4;
        for (uint i = 0; i < l; i++) {
            sig = bytes4(uint32(uint32(sig) + uint8(_data[i]) * (2 ** (8 * (l - 1 - i)))));
        }
    }

    bool __isTokenFallback;

    modifier mod_tokenPayable() {
        if (!__isTokenFallback) assert(false);
        _;                                                              //_ is a special character used in modifiers
    }

    //function supportsToken(address token) public pure returns (bool);  //moved up

//-------------------------------------------------------------------------------------
//from ExampleReceiver

/*
//we do not use dedicated function to receive Token in contract associated account
    function foo(
        //uint i
        ) tokenPayable public {
        emit LogTokenPayable(1, tkn.addr, tkn.sender, tkn.value);
    }
*/

    function tokenPayable() external mod_tokenPayable() {
        emit LogTokenPayable(0, tkn.addr, tkn.sender, tkn.value);
    }

      function supportsToken(address token) public override view returns (bool) {
        //do not need to to anything with that token address?
        //if (token == 0) { //attila addition
        if (token != thisContract) { //attila addition, support only our own token, not others' token
            return false;
        }
        if(!isTokenSupport) {  //attila addition
            return false;
        }
        return true;
    }

    event LogTokenPayable(uint i, address token, address sender, uint value);
  
//-------------------------------------------------------------------------------------
// My extensions
/*
    function enableTokenSupport(bool _tokenSupport) public returns (bool success) {
        if(msg.sender == contrInitiator) {
            isTokenSupport = _tokenSupport;
            return true;
        } else {
            return false;  
        }
    }
*/
    function setIsAllTransfersLocked(bool _lock) public {
        require(msg.sender == contrInitiator);
        isAllTransfersLocked = _lock;
        emit SetIsAllTransfersLocked(_lock);
    }

    function setIsSendingLocked(address _from, bool _lock) public {
        require(msg.sender == contrInitiator);
        isSendingLocked[_from] = _lock;
        emit SetIsSendingLocked(_from, _lock);
    }

    function getIsAllTransfersLocked() public view returns (bool ok) {
        return isAllTransfersLocked;
    }

    function getIsSendingLocked(address _from ) public view returns (bool ok) {
        return isSendingLocked[_from];
    }
 
/*  
    function getTransferInfoCount(address _from) public view returns (uint count) {
        return transferInfo[_from].tc;
    }
*/    
/*
    // use experimental feature
    function getTransferInfo(address _from, uint index) public view returns (TransferInfo ti) {
        return transferInfo[_from].ti[index];
    }
*/ 
/*
    function getTransferInfoTime(address _from, uint index) public view returns (uint time) {
        return transferInfo[_from].ti[index].time;
    }
*/
/*
    function getTransferInfoValue(address _from, uint index) public view returns (uint value) {
        return transferInfo[_from].ti[index].value;
    }
*/
    function getLast24hSendingValue(address _from) public view returns (uint totVal) {
      
        totVal = 0;  //declared above;
        uint tc = transferInfo[_from].tc;

        for(uint i = tc ; i >= 1 ; i--) {

//          if(block.timestamp - transferInfo[_from].ti[i-1].time < 10 minutes) {
//          if(block.timestamp - transferInfo[_from].ti[i-1].time < 1 hours) {
            if(block.timestamp - transferInfo[_from].ti[i-1].time < 1 days) {
                totVal = safeAdd(totVal, transferInfo[_from].ti[i-1].value );
            } else {
                break;
            }

            require(tc - i < 99);     // to limit the number of loops to 99, it means durring 24 hours, max 100 transfers (99 previous ones and the current one) can be done from a given "_from"

        }
    }

    
    function airdropIndividual(address[]  memory _recipients, uint256[]  memory _values, uint256 _elemCount, uint _totalValue)  public returns (bool success) {
        
        require(_recipients.length == _elemCount);
        require(_values.length == _elemCount); 
        require(_elemCount <= 50); 
        
        uint256 totalValue = 0;
        for(uint i = 0; i< _recipients.length; i++) {
            totalValue = safeAdd(totalValue, _values[i]);
        }
        
        require(totalValue == _totalValue);
        
        for(uint i = 0; i< _recipients.length; i++) {
            transfer(_recipients[i], _values[i]);
        }
        return true;
    }


}