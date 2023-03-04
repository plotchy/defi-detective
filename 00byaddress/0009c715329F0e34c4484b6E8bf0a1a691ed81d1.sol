/**
 *Submitted for verification at Etherscan.io on 2021-05-14
*/

pragma solidity ^0.6.10;
 
interface tokenRecipient {
    function receiveApproval(address _from, uint256 _value, address _token, bytes memory _extraData) external;
}
 
contract TokenERC20 {
    string public name;
    string public symbol;
    uint8 public decimals = 18;  // 18 是建议的默认值
    uint256 public totalSupply;
 
    mapping (address => uint256) public balanceOf;  //
    mapping (address => mapping (address => uint256)) public allowance;
 
    //事件，用来通知客户端交易发生 ERC20标准
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    //事件，用来通知客户端代币被消费 ERC20标准
    event Burn(address indexed from, uint256 value);
 
    constructor(uint256 initialSupply, string memory tokenName, string memory tokenSymbol) public {
        totalSupply = initialSupply * 10 ** uint256(decimals); // 供应的份额，份额跟最小的代币单位有关，份额 = 币数 * 10 ** decimals。
        balanceOf[msg.sender] = totalSupply; // 创建者拥有所有的代币
        name = tokenName; // 代币名称
        symbol = tokenSymbol; // 代币符号
    }
 
 
    function _transfer(address _from, address _to, uint _value) internal {
        // 确保目标地址不为0x0，因为0x0地址代表销毁
        require(_to != address(0x0));
        
        // 检查发送者余额
        require(balanceOf[_from] >= _value);
        
        // 确保转移为正数个
        require(balanceOf[_to] + _value > balanceOf[_to]);
        
        // 以下用来检查交易，
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        
        // Subtract from the sender
        balanceOf[_from] -= _value;
        
        // Add the same to the recipient
        balanceOf[_to] += _value;
        
        emit Transfer(_from, _to, _value);
        
         // 用assert来检查代码逻辑。
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
 
 
     /**
     *  代币交易转移
     *  从自己（创建交易者）账号发送`_value`个代币到 `_to`账号
     * ERC20标准
     * @param _to 接收者地址
     * @param _value 转移数额
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
 
 
    /**
     * 账号之间代币交易转移
     * ERC20标准
     * @param _from 发送者地址
     * @param _to 接收者地址
     * @param _value 转移数额
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
 
    /**
     * 设置某个地址（合约）可以创建交易者名义花费的代币数。
     *
     * 允许发送者`_spender` 花费不多于 `_value` 个代币
     * ERC20标准
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
 
 
     /**
     * 设置允许一个地址（合约）以我（创建交易者）的名义可最多花费的代币数。
     *-非ERC20标准
     * @param _spender 被授权的地址（合约）
     * @param _value 最大可花费代币数
     * @param _extraData 发送给合约的附加数据
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            // 通知合约
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }
 
     /**
     * 销毁我（创建交易者）账户中指定个代币
     *-非ERC20标准
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);// Check if the sender has enough
        balanceOf[msg.sender] -= _value;// Subtract from the sender
        totalSupply -= _value;// Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
 
     /**
     * 销毁用户账户中指定个代币
     *-非ERC20标准
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }

}