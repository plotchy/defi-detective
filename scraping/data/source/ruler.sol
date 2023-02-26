{{
  "language": "Solidity",
  "sources": {
    "contracts/RULER.sol": {
      "content": "// SPDX-License-Identifier: No License\n\npragma solidity ^0.8.0;\n\nimport \"./ERC20/ERC20Permit.sol\";\nimport \"./utils/Initializable.sol\";\nimport \"./utils/Ownable.sol\";\nimport \"./utils/Address.sol\";\n\n/**\n * @title Ruler Protocol Governance Token\n * @author crypto-pumpkin\n */\ncontract RULER is ERC20Permit, Ownable {\n  uint256 public constant CAP = 1000000 ether;\n\n  function initialize() external initializer {\n    initializeOwner();\n    initializeERC20(\"Ruler Protocol\", \"RULER\", 18);\n    initializeERC20Permit(\"Ruler Protocol\");\n    _mint(msg.sender, CAP);\n  }\n\n  // collect any tokens sent by mistake\n  function collect(address _token) external {\n    if (_token == address(0)) { // token address(0) = ETH\n      Address.sendValue(payable(owner()), address(this).balance);\n    } else {\n      uint256 balance = IERC20(_token).balanceOf(address(this));\n      IERC20(_token).transfer(owner(), balance);\n    }\n  }\n}"
    },
    "contracts/ERC20/ERC20Permit.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.0;\n\nimport \"./ERC20.sol\";\nimport \"./IERC20Permit.sol\";\nimport \"./ECDSA.sol\";\nimport \"./EIP712.sol\";\n\n/**\n * @dev Implementation of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in\n * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].\n *\n * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by\n * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't\n * need to send a transaction, and thus is not required to hold Ether at all.\n *\n * !!! crypto-pumpkin modified: use symbol instead of name to initiate EIP712, as symbol is unique and represent the token in Ruler Protocol\n */\nabstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {\n\n    mapping (address => uint256) private _nonces;\n\n    // solhint-disable-next-line var-name-mixedcase\n    bytes32 private immutable _PERMIT_TYPEHASH = keccak256(\"Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)\");\n\n    /**\n     * @dev Initializes the {EIP712} domain separator using the `name` parameter, and setting `version` to `\"1\"`.\n     *\n     * It's a good idea to use the same `name` that is defined as the ERC20 token name.\n     */\n    function initializeERC20Permit(string memory _name) internal {\n      initializeEIP712(_name, \"1\");\n    }\n\n    /**\n     * @dev See {IERC20Permit-permit}.\n     */\n    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public virtual override {\n        // solhint-disable-next-line not-rely-on-time\n        require(block.timestamp <= deadline, \"ERC20Permit: expired deadline\");\n\n        bytes32 structHash = keccak256(\n            abi.encode(\n                _PERMIT_TYPEHASH,\n                owner,\n                spender,\n                amount,\n                _nonces[owner],\n                deadline\n            )\n        );\n\n        bytes32 hash = _hashTypedDataV4(structHash);\n\n        address signer = ECDSA.recover(hash, v, r, s);\n        require(signer == owner, \"ERC20Permit: invalid signature\");\n\n        _nonces[owner]++;\n        _approve(owner, spender, amount);\n    }\n\n    /**\n     * @dev See {IERC20Permit-nonces}.\n     */\n    function nonces(address owner) public view override returns (uint256) {\n        return _nonces[owner];\n    }\n\n    /**\n     * @dev See {IERC20Permit-DOMAIN_SEPARATOR}.\n     */\n    // solhint-disable-next-line func-name-mixedcase\n    function DOMAIN_SEPARATOR() external view override returns (bytes32) {\n        return _domainSeparatorV4();\n    }\n}"
    },
    "contracts/utils/Initializable.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\n// solhint-disable-next-line compiler-version\npragma solidity ^0.8.0;\n\n\n/**\n * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed\n * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an\n * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer\n * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.\n * \n * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as\n * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.\n * \n * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure\n * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.\n */\nabstract contract Initializable {\n\n    /**\n     * @dev Indicates that the contract has been initialized.\n     */\n    bool private _initialized;\n\n    /**\n     * @dev Indicates that the contract is in the process of being initialized.\n     */\n    bool private _initializing;\n\n    /**\n     * @dev Modifier to protect an initializer function from being invoked twice.\n     */\n    modifier initializer() {\n        require(_initializing || _isConstructor() || !_initialized, \"Initializable: contract is already initialized\");\n\n        bool isTopLevelCall = !_initializing;\n        if (isTopLevelCall) {\n            _initializing = true;\n            _initialized = true;\n        }\n\n        _;\n\n        if (isTopLevelCall) {\n            _initializing = false;\n        }\n    }\n\n    /// @dev Returns true if and only if the function is running in the constructor\n    function _isConstructor() private view returns (bool) {\n        // extcodesize checks the size of the code stored in an address, and\n        // address returns the current address. Since the code is still not\n        // deployed when running a constructor, any checks on its code size will\n        // yield zero, making it an effective way to detect if a contract is\n        // under construction or not.\n        address self = address(this);\n        uint256 cs;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { cs := extcodesize(self) }\n        return cs == 0;\n    }\n}"
    },
    "contracts/utils/Ownable.sol": {
      "content": "// SPDX-License-Identifier: No License\n\npragma solidity ^0.8.0;\n\nimport \"./Initializable.sol\";\n\n/**\n * @dev Contract module which provides a basic access control mechanism, where\n * there is an account (an owner) that can be granted exclusive access to\n * specific functions.\n * @author crypto-pumpkin\n *\n * By initialization, the owner account will be the one that called initializeOwner. This\n * can later be changed with {transferOwnership}.\n *\n * This module is used through inheritance. It will make available the modifier\n * `onlyOwner`, which can be applied to your functions to restrict their use to\n * the owner.\n */\ncontract Ownable is Initializable {\n    address private _owner;\n\n    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);\n\n    /**\n     * @dev Ruler: Initializes the contract setting the deployer as the initial owner.\n     */\n    function initializeOwner() internal initializer {\n        _owner = msg.sender;\n        emit OwnershipTransferred(address(0), _owner);\n    }\n\n\n    /**\n     * @dev Returns the address of the current owner.\n     */\n    function owner() public view returns (address) {\n        return _owner;\n    }\n\n    /**\n     * @dev Throws if called by any account other than the owner.\n     */\n    modifier onlyOwner() {\n        require(_owner == msg.sender, \"Ownable: caller is not the owner\");\n        _;\n    }\n\n    /**\n     * @dev Leaves the contract without owner. It will not be possible to call\n     * `onlyOwner` functions anymore. Can only be called by the current owner.\n     *\n     * NOTE: Renouncing ownership will leave the contract without an owner,\n     * thereby removing any functionality that is only available to the owner.\n     */\n    function renounceOwnership() public virtual onlyOwner {\n        emit OwnershipTransferred(_owner, address(0));\n        _owner = address(0);\n    }\n\n    /**\n     * @dev Transfers ownership of the contract to a new account (`newOwner`).\n     * Can only be called by the current owner.\n     */\n    function transferOwnership(address newOwner) public virtual onlyOwner {\n        require(newOwner != address(0), \"Ownable: new owner is the zero address\");\n        emit OwnershipTransferred(_owner, newOwner);\n        _owner = newOwner;\n    }\n}"
    },
    "contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.8.0;\n\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts\n        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned\n        // for accounts without code, i.e. `keccak256('')`\n        bytes32 codehash;\n        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { codehash := extcodehash(account) }\n        return (codehash != accountHash && codehash != 0x0);\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\n        (bool success, ) = recipient.call{ value: amount }(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain`call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n      return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        return _functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        return _functionCallWithValue(target, data, value, errorMessage);\n    }\n\n    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {\n        require(isContract(target), \"Address: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                // solhint-disable-next-line no-inline-assembly\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}"
    },
    "contracts/ERC20/ERC20.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.0;\n\nimport \"./IERC20.sol\";\n\n/**\n * @dev Implementation of the {IERC20} interface.\n *\n * This implementation is agnostic to the way tokens are created. This means\n * that a supply mechanism has to be added in a derived contract using {_mint}.\n * For a generic mechanism see {ERC20PresetMinterPauser}.\n *\n * TIP: For a detailed writeup see our guide\n * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How\n * to implement supply mechanisms].\n *\n * We have followed general OpenZeppelin guidelines: functions revert instead\n * of returning `false` on failure. This behavior is nonetheless conventional\n * and does not conflict with the expectations of ERC20 applications.\n *\n * Additionally, an {Approval} event is emitted on calls to {transferFrom}.\n * This allows applications to reconstruct the allowance for all accounts just\n * by listening to said events. Other implementations of the EIP may not emit\n * these events, as it isn't required by the specification.\n *\n * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}\n * functions have been added to mitigate the well-known issues around setting\n * allowances. See {IERC20-approve}.\n * \n * !!! crypto-pumpkin modified: use initializeERC20 to replace constructor for proxy\n */\ncontract ERC20 is IERC20 {\n\n  mapping (address => uint256) private _balances;\n\n  mapping (address => mapping (address => uint256)) private _allowances;\n\n  uint256 internal _totalSupply;\n\n  string public override name;\n  uint8 public override decimals;\n  string public override symbol;\n\n  function initializeERC20(string memory name_, string memory symbol_, uint8 decimals_) internal {\n    name = name_;\n    symbol = symbol_;\n    decimals = decimals_;\n  }\n\n  function balanceOf(address account) external view override returns (uint256) {\n    return _balances[account];\n  }\n\n  function totalSupply() external view override returns (uint256) {\n    return _totalSupply;\n  }\n\n  function transfer(address recipient, uint256 amount) external virtual override returns (bool) {\n    _transfer(msg.sender, recipient, amount);\n    return true;\n  }\n\n  function allowance(address owner, address spender) external view virtual override returns (uint256) {\n    return _allowances[owner][spender];\n  }\n\n  function approve(address spender, uint256 amount) external virtual override returns (bool) {\n    _approve(msg.sender, spender, amount);\n    return true;\n  }\n\n  function transferFrom(address sender, address recipient, uint256 amount)\n    external virtual override returns (bool)\n  {\n    _transfer(sender, recipient, amount);\n    _approve(sender, msg.sender, _allowances[sender][msg.sender] - amount);\n    return true;\n  }\n\n  function increaseAllowance(address spender, uint256 addedValue) public virtual override returns (bool) {\n    _approve(msg.sender, spender, _allowances[msg.sender][spender] + addedValue);\n    return true;\n  }\n\n  function decreaseAllowance(address spender, uint256 subtractedValue) public virtual override returns (bool) {\n    _approve(msg.sender, spender, _allowances[msg.sender][spender] - subtractedValue);\n    return true;\n  }\n\n  function _mint(address _account, uint256 _amount) internal virtual {\n    require(_account != address(0), \"ERC20: mint to the zero address\");\n\n    _totalSupply = _totalSupply + _amount;\n    _balances[_account] = _balances[_account] + _amount;\n    emit Transfer(address(0), _account, _amount);\n  }\n\n  function _approve(address owner, address spender, uint256 amount) internal {\n    require(owner != address(0), \"ERC20: approve from the zero address\");\n    require(spender != address(0), \"ERC20: approve to the zero address\");\n\n    _allowances[owner][spender] = amount;\n    emit Approval(owner, spender, amount);\n  }\n\n  function _transfer(address sender, address recipient, uint256 amount) internal {\n    require(sender != address(0), \"ERC20: transfer from the zero address\");\n    require(recipient != address(0), \"ERC20: transfer to the zero address\");\n\n    _balances[sender] = _balances[sender] - amount;\n    _balances[recipient] = _balances[recipient] + amount;\n    emit Transfer(sender, recipient, amount);\n  }\n\n  function _burn(address account, uint256 amount) internal {\n    require(account != address(0), \"ERC20: burn from the zero address\");\n\n    _balances[account] = _balances[account] - amount;\n    _totalSupply = _totalSupply - amount;\n    emit Transfer(account, address(0), amount);\n  }\n}"
    },
    "contracts/ERC20/IERC20Permit.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.0;\n\n/**\n * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in\n * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].\n *\n * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by\n * presenting a message signed by the account. By not relying on `{IERC20-approve}`, the token holder account doesn't\n * need to send a transaction, and thus is not required to hold Ether at all.\n */\ninterface IERC20Permit {\n    /**\n     * @dev Sets `amount` as the allowance of `spender` over `owner`'s tokens,\n     * given `owner`'s signed approval.\n     *\n     * IMPORTANT: The same issues {IERC20-approve} has related to transaction\n     * ordering also apply here.\n     *\n     * Emits an {Approval} event.\n     *\n     * Requirements:\n     *\n     * - `spender` cannot be the zero address.\n     * - `deadline` must be a timestamp in the future.\n     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`\n     * over the EIP712-formatted function arguments.\n     * - the signature must use ``owner``'s current nonce (see {nonces}).\n     *\n     * For more information on the signature format, see the\n     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP\n     * section].\n     */\n    function permit(address owner, address spender, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) external;\n\n    /**\n     * @dev Returns the current nonce for `owner`. This value must be\n     * included whenever a signature is generated for {permit}.\n     *\n     * Every successful call to {permit} increases ``owner``'s nonce by one. This\n     * prevents a signature from being used multiple times.\n     */\n    function nonces(address owner) external view returns (uint256);\n\n    /**\n     * @dev Returns the domain separator used in the encoding of the signature for `permit`, as defined by {EIP712}.\n     */\n    // solhint-disable-next-line func-name-mixedcase\n    function DOMAIN_SEPARATOR() external view returns (bytes32);\n}"
    },
    "contracts/ERC20/ECDSA.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.0;\n\n/**\n * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.\n *\n * These functions can be used to verify that a message was signed by the holder\n * of the private keys of a given address.\n */\nlibrary ECDSA {\n    /**\n     * @dev Returns the address that signed a hashed message (`hash`) with\n     * `signature`. This address can then be used for verification purposes.\n     *\n     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:\n     * this function rejects them by requiring the `s` value to be in the lower\n     * half order, and the `v` value to be either 27 or 28.\n     *\n     * IMPORTANT: `hash` _must_ be the result of a hash operation for the\n     * verification to be secure: it is possible to craft signatures that\n     * recover to arbitrary addresses for non-hashed data. A safe way to ensure\n     * this is by receiving a hash of the original message (which may otherwise\n     * be too long), and then calling {toEthSignedMessageHash} on it.\n     */\n    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {\n        // Check the signature length\n        if (signature.length != 65) {\n            revert(\"ECDSA: invalid signature length\");\n        }\n\n        // Divide the signature in r, s and v variables\n        bytes32 r;\n        bytes32 s;\n        uint8 v;\n\n        // ecrecover takes the signature parameters, and the only way to get them\n        // currently is to use assembly.\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            r := mload(add(signature, 0x20))\n            s := mload(add(signature, 0x40))\n            v := byte(0, mload(add(signature, 0x60)))\n        }\n\n        return recover(hash, v, r, s);\n    }\n\n    /**\n     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,\n     * `r` and `s` signature fields separately.\n     */\n    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {\n        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature\n        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines\n        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most\n        // signatures from current libraries generate a unique signature with an s-value in the lower half order.\n        //\n        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value\n        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or\n        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept\n        // these malleable signatures as well.\n        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, \"ECDSA: invalid signature 's' value\");\n        require(v == 27 || v == 28, \"ECDSA: invalid signature 'v' value\");\n\n        // If the signature is valid (and not malleable), return the signer address\n        address signer = ecrecover(hash, v, r, s);\n        require(signer != address(0), \"ECDSA: invalid signature\");\n\n        return signer;\n    }\n\n    /**\n     * @dev Returns an Ethereum Signed Message, created from a `hash`. This\n     * replicates the behavior of the\n     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]\n     * JSON-RPC method.\n     *\n     * See {recover}.\n     */\n    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {\n        // 32 is the length in bytes of hash,\n        // enforced by the type signature above\n        return keccak256(abi.encodePacked(\"\\x19Ethereum Signed Message:\\n32\", hash));\n    }\n}"
    },
    "contracts/ERC20/EIP712.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity 0.8.0;\n\n/**\n * @dev https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.\n *\n * The encoding specified in the EIP is very generic, and such a generic implementation in Solidity is not feasible,\n * thus this contract does not implement the encoding itself. Protocols need to implement the type-specific encoding\n * they need in their contracts using a combination of `abi.encode` and `keccak256`.\n *\n * This contract implements the EIP 712 domain separator ({_domainSeparatorV4}) that is used as part of the encoding\n * scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA\n * ({_hashTypedDataV4}).\n *\n * The implementation of the domain separator was designed to be as efficient as possible while still properly updating\n * the chain id to protect against replay attacks on an eventual fork of the chain.\n *\n * NOTE: This contract implements the version of the encoding known as \"v4\", as implemented by the JSON RPC method\n * https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].\n *\n * !!! crypto-pumpkin modified: remove immutable for the 5 vars, since we cannot set them in constructor, should be safe as they are set once in initialize internally\n */\nabstract contract EIP712 {\n    /* solhint-disable var-name-mixedcase */\n    // Cache the domain separator as an immutable value, but also store the chain id that it corresponds to, in order to\n    // invalidate the cached domain separator if the chain id changes.\n    // crypto-pumpkin@: remove immutable to be initiated, it should only be set once in initialize\n    bytes32 private _CACHED_DOMAIN_SEPARATOR;\n    uint256 private _CACHED_CHAIN_ID;\n\n    bytes32 private _HASHED_NAME;\n    bytes32 private _HASHED_VERSION;\n    bytes32 private _TYPE_HASH;\n    /* solhint-enable var-name-mixedcase */\n\n    /**\n     * @dev Initializes the domain separator and parameter caches.\n     *\n     * The meaning of `name` and `version` is specified in\n     * https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:\n     *\n     * - `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.\n     * - `version`: the current major version of the signing domain.\n     *\n     * NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart\n     * contract upgrade].\n     */\n    function initializeEIP712 (string memory name, string memory version) internal {\n        bytes32 hashedName = keccak256(bytes(name));\n        bytes32 hashedVersion = keccak256(bytes(version));\n        bytes32 typeHash = keccak256(\"EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)\"); \n        _HASHED_NAME = hashedName;\n        _HASHED_VERSION = hashedVersion;\n        _CACHED_CHAIN_ID = _getChainId();\n        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(typeHash, hashedName, hashedVersion);\n        _TYPE_HASH = typeHash;\n    }\n\n    /**\n     * @dev Returns the domain separator for the current chain.\n     */\n    function _domainSeparatorV4() internal view returns (bytes32) {\n        if (_getChainId() == _CACHED_CHAIN_ID) {\n            return _CACHED_DOMAIN_SEPARATOR;\n        } else {\n            return _buildDomainSeparator(_TYPE_HASH, _HASHED_NAME, _HASHED_VERSION);\n        }\n    }\n\n    function _buildDomainSeparator(bytes32 typeHash, bytes32 name, bytes32 version) private view returns (bytes32) {\n        return keccak256(\n            abi.encode(\n                typeHash,\n                name,\n                version,\n                _getChainId(),\n                address(this)\n            )\n        );\n    }\n\n    /**\n     * @dev Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this\n     * function returns the hash of the fully encoded EIP712 message for this domain.\n     *\n     * This hash can be used together with {ECDSA-recover} to obtain the signer of a message. For example:\n     *\n     * ```solidity\n     * bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(\n     *     keccak256(\"Mail(address to,string contents)\"),\n     *     mailTo,\n     *     keccak256(bytes(mailContents))\n     * )));\n     * address signer = ECDSA.recover(digest, signature);\n     * ```\n     */\n    function _hashTypedDataV4(bytes32 structHash) internal view returns (bytes32) {\n        return keccak256(abi.encodePacked(\"\\x19\\x01\", _domainSeparatorV4(), structHash));\n    }\n\n    function _getChainId() private view returns (uint256 chainId) {\n        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691\n        // solhint-disable-next-line no-inline-assembly\n        assembly {\n            chainId := chainid()\n        }\n    }\n}"
    },
    "contracts/ERC20/IERC20.sol": {
      "content": "// SPDX-License-Identifier: No License\n\npragma solidity ^0.8.0;\n\n/**\n * @title Interface of the ERC20 standard as defined in the EIP.\n */\ninterface IERC20 {\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    function name() external view returns (string memory);\n    function symbol() external view returns (string memory);\n    function decimals() external view returns (uint8);\n    function balanceOf(address account) external view returns (uint256);\n    function transfer(address recipient, uint256 amount) external returns (bool);\n    function approve(address spender, uint256 amount) external returns (bool);\n    function allowance(address owner, address spender) external view returns (uint256);\n    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);\n    function totalSupply() external view returns (uint256);\n\n    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);\n    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);\n}"
    }
  },
  "settings": {
    "optimizer": {
      "enabled": true,
      "runs": 2000
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