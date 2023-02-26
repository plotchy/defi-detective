{{
  "language": "Solidity",
  "sources": {
    "contracts/TokenDelegator.sol": {
      "content": "pragma solidity ^0.7.0;\npragma experimental ABIEncoderV2;\n\nimport { TokenDelegatorStorage, TokenEvents } from \"./TokenInterfaces.sol\";\n\ncontract InstaToken is TokenDelegatorStorage, TokenEvents {\n    constructor(\n        address account,\n        address implementation_,\n        uint initialSupply_,\n        uint mintingAllowedAfter_,\n        bool transferPaused_\n    ) {\n        require(implementation_ != address(0), \"TokenDelegator::constructor invalid address\");\n        delegateTo(\n            implementation_,\n            abi.encodeWithSignature(\n                \"initialize(address,uint256,uint256,bool)\",\n                account,\n                initialSupply_,\n                mintingAllowedAfter_,\n                transferPaused_\n            )\n        );\n\n        implementation = implementation_;\n\n        emit NewImplementation(address(0), implementation);\n    }\n\n    /**\n     * @notice Called by the admin to update the implementation of the delegator\n     * @param implementation_ The address of the new implementation for delegation\n     */\n    function _setImplementation(address implementation_) external isMaster {\n        require(implementation_ != address(0), \"TokenDelegator::_setImplementation: invalid implementation address\");\n\n        address oldImplementation = implementation;\n        implementation = implementation_;\n\n        emit NewImplementation(oldImplementation, implementation);\n    }\n\n    /**\n     * @notice Internal method to delegate execution to another contract\n     * @dev It returns to the external caller whatever the implementation returns or forwards reverts\n     * @param callee The contract to delegatecall\n     * @param data The raw data to delegatecall\n     */\n    function delegateTo(address callee, bytes memory data) internal {\n        (bool success, bytes memory returnData) = callee.delegatecall(data);\n        assembly {\n            if eq(success, 0) {\n                revert(add(returnData, 0x20), returndatasize())\n            }\n        }\n    }\n\n    /**\n     * @dev Delegates execution to an implementation contract.\n     * It returns to the external caller whatever the implementation returns\n     * or forwards reverts.\n     */\n    fallback () external payable {\n        // delegate all other functions to current implementation\n        (bool success, ) = implementation.delegatecall(msg.data);\n\n        assembly {\n            let free_mem_ptr := mload(0x40)\n            returndatacopy(free_mem_ptr, 0, returndatasize())\n\n            switch success\n            case 0 { revert(free_mem_ptr, returndatasize()) }\n            default { return(free_mem_ptr, returndatasize()) }\n        }\n    }\n}\n"
    },
    "contracts/TokenInterfaces.sol": {
      "content": "pragma solidity ^0.7.0;\npragma experimental ABIEncoderV2;\n\ninterface IndexInterface {\n    function master() external view returns (address);\n}\n\ncontract TokenEvents {\n    \n    /// @notice An event thats emitted when an account changes its delegate\n    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);\n\n    /// @notice An event thats emitted when a delegate account's vote balance changes\n    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);\n\n    /// @notice An event thats emitted when the minter changes\n    event MinterChanged(address indexed oldMinter, address indexed newMinter);\n\n    /// @notice The standard EIP-20 transfer event\n    event Transfer(address indexed from, address indexed to, uint256 amount);\n\n    /// @notice The standard EIP-20 approval event\n    event Approval(address indexed owner, address indexed spender, uint256 amount);\n\n    /// @notice Emitted when implementation is changed\n    event NewImplementation(address oldImplementation, address newImplementation);\n\n    /// @notice An event thats emitted when the token transfered is paused\n    event TransferPaused(address indexed minter);\n\n    /// @notice An event thats emitted when the token transfered is unpaused\n    event TransferUnpaused(address indexed minter);\n\n    /// @notice An event thats emitted when the token symbol is changed\n    event ChangedSymbol(string oldSybmol, string newSybmol);\n\n    /// @notice An event thats emitted when the token name is changed\n    event ChangedName(string oldName, string newName);\n}\n\ncontract TokenDelegatorStorage {\n    /// @notice InstaIndex contract\n    IndexInterface constant public instaIndex = IndexInterface(0x2971AdFa57b20E5a416aE5a708A8655A9c74f723);\n\n    /// @notice Active brains of Token\n    address public implementation;\n\n    /// @notice EIP-20 token name for this token\n    string public name = \"Instadapp\";\n\n    /// @notice EIP-20 token symbol for this token\n    string public symbol = \"INST\";\n\n    /// @notice Total number of tokens in circulation\n    uint public totalSupply;\n\n    /// @notice EIP-20 token decimals for this token\n    uint8 public constant decimals = 18;\n\n    modifier isMaster() {\n        require(instaIndex.master() == msg.sender, \"Tkn::isMaster: msg.sender not master\");\n        _;\n    }\n}\n\n/**\n * @title Storage for Token Delegate\n * @notice For future upgrades, do not change TokenDelegateStorageV1. Create a new\n * contract which implements TokenDelegateStorageV1 and following the naming convention\n * TokenDelegateStorageVX.\n */\ncontract TokenDelegateStorageV1 is TokenDelegatorStorage {\n    /// @notice The timestamp after which minting may occur\n    uint public mintingAllowedAfter;\n\n    /// @notice token transfer pause state\n    bool public transferPaused;\n\n    // Allowance amounts on behalf of others\n    mapping (address => mapping (address => uint96)) internal allowances;\n\n    // Official record of token balances for each account\n    mapping (address => uint96) internal balances;\n\n    /// @notice A record of each accounts delegate\n    mapping (address => address) public delegates;\n\n    /// @notice A checkpoint for marking number of votes from a given block\n    struct Checkpoint {\n        uint32 fromBlock;\n        uint96 votes;\n    }\n\n    /// @notice A record of votes checkpoints for each account, by index\n    mapping (address => mapping (uint32 => Checkpoint)) public checkpoints;\n\n    /// @notice The number of checkpoints for each account\n    mapping (address => uint32) public numCheckpoints;\n\n    /// @notice A record of states for signing / validating signatures\n    mapping (address => uint) public nonces;\n}"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 200
    },
    "outputSelection": {
      "*": {
        "*": [
          "evm.bytecode",
          "evm.deployedBytecode",
          "abi"
        ]
      }
    },
    "libraries": {}
  }
}}