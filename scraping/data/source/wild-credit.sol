{{
  "language": "Solidity",
  "sources": {
    "ERC20Mintable.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\nimport \"SafeOwnable.sol\";\n\ncontract ERC20Mintable is SafeOwnable {\n\n  event Transfer(address indexed from, address indexed to, uint value);\n  event Approval(address indexed owner, address indexed spender, uint value);\n\n  mapping (address => uint) public balanceOf;\n  mapping (address => mapping (address => uint)) public allowance;\n\n  string public name;\n  string public symbol;\n  uint8 public immutable decimals;\n  uint public totalSupply;\n\n  constructor(\n    string memory _name,\n    string memory _symbol,\n    uint8 _decimals\n  ) {\n    name = _name;\n    symbol = _symbol;\n    decimals = _decimals;\n    require(_decimals > 0, \"decimals\");\n  }\n\n  function transfer(address _recipient, uint _amount) external returns (bool) {\n    _transfer(msg.sender, _recipient, _amount);\n    return true;\n  }\n\n  function approve(address _spender, uint _amount) external returns (bool) {\n    _approve(msg.sender, _spender, _amount);\n    return true;\n  }\n\n  function increaseAllowance(address _spender, uint _amount) external returns (bool) {\n    _approve(msg.sender, _spender, allowance[msg.sender][_spender] + _amount);\n    return true;\n  }\n\n  function decreaseAllowance(address _spender, uint256 _amount) external returns (bool) {\n    _approve(msg.sender, _spender, allowance[msg.sender][_spender] - _amount);\n    return true;\n  }\n\n  function transferFrom(address _sender, address _recipient, uint _amount) external returns (bool) {\n    require(allowance[_sender][msg.sender] >= _amount, \"ERC20: insufficient approval\");\n    _transfer(_sender, _recipient, _amount);\n    _approve(_sender, msg.sender, allowance[_sender][msg.sender] - _amount);\n    return true;\n  }\n\n  function mint(address _account, uint _amount) external onlyOwner {\n    _mint(_account, _amount);\n  }\n\n  function burn(address _account, uint _amount) external onlyOwner {\n    _burn(_account, _amount);\n  }\n\n  function _transfer(address _sender, address _recipient, uint _amount) internal {\n    require(_sender != address(0), \"ERC20: transfer from the zero address\");\n    require(_recipient != address(0), \"ERC20: transfer to the zero address\");\n    require(balanceOf[_sender] >= _amount, \"ERC20: insufficient funds\");\n\n    balanceOf[_sender] -= _amount;\n    balanceOf[_recipient] += _amount;\n    emit Transfer(_sender, _recipient, _amount);\n  }\n\n  function _mint(address _account, uint _amount) internal {\n    require(_account != address(0), \"ERC20: mint to the zero address\");\n\n    totalSupply += _amount;\n    balanceOf[_account] += _amount;\n    emit Transfer(address(0), _account, _amount);\n  }\n\n  function _burn(address _account, uint _amount) internal {\n    require(_account != address(0), \"ERC20: burn from the zero address\");\n\n    balanceOf[_account] -= _amount;\n    totalSupply -= _amount;\n    emit Transfer(_account, address(0), _amount);\n  }\n\n  function _approve(address _owner, address _spender, uint _amount) internal {\n    require(_owner != address(0), \"ERC20: approve from the zero address\");\n    require(_spender != address(0), \"ERC20: approve to the zero address\");\n\n    allowance[_owner][_spender] = _amount;\n    emit Approval(_owner, _spender, _amount);\n  }\n}"
    },
    "SafeOwnable.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\nimport \"IOwnable.sol\";\n\ncontract SafeOwnable is IOwnable {\n\n  uint public constant RENOUNCE_TIMEOUT = 1 hours;\n\n  address public override owner;\n  address public pendingOwner;\n  uint public renouncedAt;\n\n  event OwnershipTransferInitiated(address indexed previousOwner, address indexed newOwner);\n  event OwnershipTransferConfirmed(address indexed previousOwner, address indexed newOwner);\n\n  constructor() {\n    owner = msg.sender;\n    emit OwnershipTransferConfirmed(address(0), msg.sender);\n  }\n\n  modifier onlyOwner() {\n    require(isOwner(), \"Ownable: caller is not the owner\");\n    _;\n  }\n\n  function isOwner() public view returns (bool) {\n    return msg.sender == owner;\n  }\n\n  function transferOwnership(address _newOwner) external override onlyOwner {\n    require(_newOwner != address(0), \"Ownable: new owner is the zero address\");\n    emit OwnershipTransferInitiated(owner, _newOwner);\n    pendingOwner = _newOwner;\n  }\n\n  function acceptOwnership() external override {\n    require(msg.sender == pendingOwner, \"Ownable: caller is not pending owner\");\n    emit OwnershipTransferConfirmed(msg.sender, pendingOwner);\n    owner = pendingOwner;\n    pendingOwner = address(0);\n  }\n\n  function initiateRenounceOwnership() external onlyOwner {\n    require(renouncedAt == 0, \"Ownable: already initiated\");\n    renouncedAt = block.timestamp;\n  }\n\n  function acceptRenounceOwnership() external onlyOwner {\n    require(renouncedAt > 0, \"Ownable: not initiated\");\n    require(block.timestamp - renouncedAt > RENOUNCE_TIMEOUT, \"Ownable: too early\");\n    owner = address(0);\n    pendingOwner = address(0);\n    renouncedAt = 0;\n  }\n\n  function cancelRenounceOwnership() external onlyOwner {\n    require(renouncedAt > 0, \"Ownable: not initiated\");\n    renouncedAt = 0;\n  }\n}"
    },
    "IOwnable.sol": {
      "content": "// SPDX-License-Identifier: UNLICENSED\n\npragma solidity 0.8.6;\n\ninterface IOwnable {\n  function owner() external view returns(address);\n  function transferOwnership(address _newOwner) external;\n  function acceptOwnership() external;\n}"
    }
  },
  "settings": {
    "evmVersion": "istanbul",
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "devdoc",
          "userdoc",
          "metadata",
          "abi"
        ]
      }
    }
  }
}}