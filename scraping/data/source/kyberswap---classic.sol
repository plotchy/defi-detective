{{
  "language": "Solidity",
  "sources": {
    "contracts/proxy/AdminUpgradeabilityProxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.6.0;\n\nimport './UpgradeabilityProxy.sol';\n\n/**\n * @title AdminUpgradeabilityProxy\n * @dev This contract combines an upgradeability proxy with an authorization\n * mechanism for administrative tasks.\n * All external functions in this contract must be guarded by the\n * `ifAdmin` modifier. See ethereum/solidity#3864 for a Solidity\n * feature proposal that would enable this to be done automatically.\n */\ncontract AdminUpgradeabilityProxy is UpgradeabilityProxy {\n  /**\n   * Contract constructor.\n   * @param _logic address of the initial implementation.\n   * @param _admin Address of the proxy administrator.\n   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.\n   * It should include the signature and the parameters of the function to be called, as described in\n   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.\n   */\n  constructor(address _logic, address _admin, bytes memory _data) UpgradeabilityProxy(_logic, _data) public payable {\n    assert(ADMIN_SLOT == bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1));\n    _setAdmin(_admin);\n  }\n\n  /**\n   * @dev Emitted when the administration has been transferred.\n   * @param previousAdmin Address of the previous admin.\n   * @param newAdmin Address of the new admin.\n   */\n  event AdminChanged(address previousAdmin, address newAdmin);\n\n  /**\n   * @dev Storage slot with the admin of the contract.\n   * This is the keccak-256 hash of \"eip1967.proxy.admin\" subtracted by 1, and is\n   * validated in the constructor.\n   */\n\n  bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;\n\n  /**\n   * @dev Modifier to check whether the `msg.sender` is the admin.\n   * If it is, it will run the function. Otherwise, it will delegate the call\n   * to the implementation.\n   */\n  modifier ifAdmin() {\n    if (msg.sender == _admin()) {\n      _;\n    } else {\n      _fallback();\n    }\n  }\n\n  /**\n   * @return The address of the proxy admin.\n   */\n  function admin() external ifAdmin returns (address) {\n    return _admin();\n  }\n\n  /**\n   * @return The address of the implementation.\n   */\n  function implementation() external ifAdmin returns (address) {\n    return _implementation();\n  }\n\n  /**\n   * @dev Changes the admin of the proxy.\n   * Only the current admin can call this function.\n   * @param newAdmin Address to transfer proxy administration to.\n   */\n  function changeAdmin(address newAdmin) external ifAdmin {\n    require(newAdmin != address(0), \"Cannot change the admin of a proxy to the zero address\");\n    emit AdminChanged(_admin(), newAdmin);\n    _setAdmin(newAdmin);\n  }\n\n  /**\n   * @dev Upgrade the backing implementation of the proxy.\n   * Only the admin can call this function.\n   * @param newImplementation Address of the new implementation.\n   */\n  function upgradeTo(address newImplementation) external ifAdmin {\n    _upgradeTo(newImplementation);\n  }\n\n  /**\n   * @dev Upgrade the backing implementation of the proxy and call a function\n   * on the new implementation.\n   * This is useful to initialize the proxied contract.\n   * @param newImplementation Address of the new implementation.\n   * @param data Data to send as msg.data in the low level call.\n   * It should include the signature and the parameters of the function to be called, as described in\n   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n   */\n  function upgradeToAndCall(address newImplementation, bytes calldata data) payable external ifAdmin {\n    _upgradeTo(newImplementation);\n    (bool success,) = newImplementation.delegatecall(data);\n    require(success);\n  }\n\n  /**\n   * @return adm The admin slot.\n   */\n  function _admin() internal view returns (address adm) {\n    bytes32 slot = ADMIN_SLOT;\n    assembly {\n      adm := sload(slot)\n    }\n  }\n\n  /**\n   * @dev Sets the address of the proxy admin.\n   * @param newAdmin Address of the new proxy admin.\n   */\n  function _setAdmin(address newAdmin) internal {\n    bytes32 slot = ADMIN_SLOT;\n\n    assembly {\n      sstore(slot, newAdmin)\n    }\n  }\n\n  /**\n   * @dev Only fall back when the sender is not the admin.\n   */\n  function _willFallback() internal override virtual {\n    require(msg.sender != _admin(), \"Cannot call fallback function from the proxy admin\");\n    super._willFallback();\n  }\n}\n"
    },
    "contracts/proxy/UpgradeabilityProxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.6.0;\n\nimport './Proxy.sol';\nimport '@openzeppelin/contracts/utils/Address.sol';\n\n/**\n * @title UpgradeabilityProxy\n * @dev This contract implements a proxy that allows to change the\n * implementation address to which it will delegate.\n * Such a change is called an implementation upgrade.\n */\ncontract UpgradeabilityProxy is Proxy {\n  /**\n   * @dev Contract constructor.\n   * @param _logic Address of the initial implementation.\n   * @param _data Data to send as msg.data to the implementation to initialize the proxied contract.\n   * It should include the signature and the parameters of the function to be called, as described in\n   * https://solidity.readthedocs.io/en/v0.4.24/abi-spec.html#function-selector-and-argument-encoding.\n   * This parameter is optional, if no data is given the initialization call to proxied contract will be skipped.\n   */\n  constructor(address _logic, bytes memory _data) public payable {\n    assert(IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));\n    _setImplementation(_logic);\n    if(_data.length > 0) {\n      (bool success,) = _logic.delegatecall(_data);\n      require(success);\n    }\n  }  \n\n  /**\n   * @dev Emitted when the implementation is upgraded.\n   * @param implementation Address of the new implementation.\n   */\n  event Upgraded(address indexed implementation);\n\n  /**\n   * @dev Storage slot with the address of the current implementation.\n   * This is the keccak-256 hash of \"eip1967.proxy.implementation\" subtracted by 1, and is\n   * validated in the constructor.\n   */\n  bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;\n\n  /**\n   * @dev Returns the current implementation.\n   * @return impl Address of the current implementation\n   */\n  function _implementation() internal override view returns (address impl) {\n    bytes32 slot = IMPLEMENTATION_SLOT;\n    assembly {\n      impl := sload(slot)\n    }\n  }\n\n  /**\n   * @dev Upgrades the proxy to a new implementation.\n   * @param newImplementation Address of the new implementation.\n   */\n  function _upgradeTo(address newImplementation) internal {\n    _setImplementation(newImplementation);\n    emit Upgraded(newImplementation);\n  }\n\n  /**\n   * @dev Sets the implementation address of the proxy.\n   * @param newImplementation Address of the new implementation.\n   */\n  function _setImplementation(address newImplementation) internal {\n    require(Address.isContract(newImplementation), \"Cannot set a proxy implementation to a non-contract address\");\n\n    bytes32 slot = IMPLEMENTATION_SLOT;\n\n    assembly {\n      sstore(slot, newImplementation)\n    }\n  }\n}\n"
    },
    "contracts/proxy/Proxy.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity ^0.6.0;\n\n/**\n * @title Proxy\n * @dev Implements delegation of calls to other contracts, with proper\n * forwarding of return values and bubbling of failures.\n * It defines a fallback function that delegates all calls to the address\n * returned by the abstract _implementation() internal function.\n */\nabstract contract Proxy {\n  /**\n   * @dev Fallback function.\n   * Implemented entirely in `_fallback`.\n   */\n  fallback () payable external {\n    _fallback();\n  }\n\n  /**\n   * @dev Receive function.\n   * Implemented entirely in `_fallback`.\n   */\n  receive () payable external {\n    _fallback();\n  }\n\n  /**\n   * @return The Address of the implementation.\n   */\n  function _implementation() internal virtual view returns (address);\n\n  /**\n   * @dev Delegates execution to an implementation contract.\n   * This is a low level function that doesn't return to its internal call site.\n   * It will return to the external caller whatever the implementation returns.\n   * @param implementation Address to delegate.\n   */\n  function _delegate(address implementation) internal {\n    assembly {\n      // Copy msg.data. We take full control of memory in this inline assembly\n      // block because it will not return to Solidity code. We overwrite the\n      // Solidity scratch pad at memory position 0.\n      calldatacopy(0, 0, calldatasize())\n\n      // Call the implementation.\n      // out and outsize are 0 because we don't know the size yet.\n      let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)\n\n      // Copy the returned data.\n      returndatacopy(0, 0, returndatasize())\n\n      switch result\n      // delegatecall returns 0 on error.\n      case 0 { revert(0, returndatasize()) }\n      default { return(0, returndatasize()) }\n    }\n  }\n\n  /**\n   * @dev Function that is run as the first thing in the fallback function.\n   * Can be redefined in derived contracts to add functionality.\n   * Redefinitions must call super._willFallback().\n   */\n  function _willFallback() internal virtual {\n  }\n\n  /**\n   * @dev fallback implementation.\n   * Extracted to enable manual triggering.\n   */\n  function _fallback() internal {\n    _willFallback();\n    _delegate(_implementation());\n  }\n}\n"
    },
    "@openzeppelin/contracts/utils/Address.sol": {
      "content": "// SPDX-License-Identifier: MIT\n\npragma solidity >=0.6.2 <0.8.0;\n\n/**\n * @dev Collection of functions related to the address type\n */\nlibrary Address {\n    /**\n     * @dev Returns true if `account` is a contract.\n     *\n     * [IMPORTANT]\n     * ====\n     * It is unsafe to assume that an address for which this function returns\n     * false is an externally-owned account (EOA) and not a contract.\n     *\n     * Among others, `isContract` will return false for the following\n     * types of addresses:\n     *\n     *  - an externally-owned account\n     *  - a contract in construction\n     *  - an address where a contract will be created\n     *  - an address where a contract lived, but was destroyed\n     * ====\n     */\n    function isContract(address account) internal view returns (bool) {\n        // This method relies on extcodesize, which returns 0 for contracts in\n        // construction, since the code is only stored at the end of the\n        // constructor execution.\n\n        uint256 size;\n        // solhint-disable-next-line no-inline-assembly\n        assembly { size := extcodesize(account) }\n        return size > 0;\n    }\n\n    /**\n     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to\n     * `recipient`, forwarding all available gas and reverting on errors.\n     *\n     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost\n     * of certain opcodes, possibly making contracts go over the 2300 gas limit\n     * imposed by `transfer`, making them unable to receive funds via\n     * `transfer`. {sendValue} removes this limitation.\n     *\n     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].\n     *\n     * IMPORTANT: because control is transferred to `recipient`, care must be\n     * taken to not create reentrancy vulnerabilities. Consider using\n     * {ReentrancyGuard} or the\n     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].\n     */\n    function sendValue(address payable recipient, uint256 amount) internal {\n        require(address(this).balance >= amount, \"Address: insufficient balance\");\n\n        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value\n        (bool success, ) = recipient.call{ value: amount }(\"\");\n        require(success, \"Address: unable to send value, recipient may have reverted\");\n    }\n\n    /**\n     * @dev Performs a Solidity function call using a low level `call`. A\n     * plain`call` is an unsafe replacement for a function call: use this\n     * function instead.\n     *\n     * If `target` reverts with a revert reason, it is bubbled up by this\n     * function (like regular Solidity function calls).\n     *\n     * Returns the raw returned data. To convert to the expected return value,\n     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].\n     *\n     * Requirements:\n     *\n     * - `target` must be a contract.\n     * - calling `target` with `data` must not revert.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data) internal returns (bytes memory) {\n      return functionCall(target, data, \"Address: low-level call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with\n     * `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, 0, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but also transferring `value` wei to `target`.\n     *\n     * Requirements:\n     *\n     * - the calling contract must have an ETH balance of at least `value`.\n     * - the called Solidity function must be `payable`.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {\n        return functionCallWithValue(target, data, value, \"Address: low-level call with value failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but\n     * with `errorMessage` as a fallback revert reason when `target` reverts.\n     *\n     * _Available since v3.1._\n     */\n    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {\n        require(address(this).balance >= value, \"Address: insufficient balance for call\");\n        require(isContract(target), \"Address: call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.call{ value: value }(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {\n        return functionStaticCall(target, data, \"Address: low-level static call failed\");\n    }\n\n    /**\n     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],\n     * but performing a static call.\n     *\n     * _Available since v3.3._\n     */\n    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {\n        require(isContract(target), \"Address: static call to non-contract\");\n\n        // solhint-disable-next-line avoid-low-level-calls\n        (bool success, bytes memory returndata) = target.staticcall(data);\n        return _verifyCallResult(success, returndata, errorMessage);\n    }\n\n    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {\n        if (success) {\n            return returndata;\n        } else {\n            // Look for revert reason and bubble it up if present\n            if (returndata.length > 0) {\n                // The easiest way to bubble the revert reason is using memory via assembly\n\n                // solhint-disable-next-line no-inline-assembly\n                assembly {\n                    let returndata_size := mload(returndata)\n                    revert(add(32, returndata), returndata_size)\n                }\n            } else {\n                revert(errorMessage);\n            }\n        }\n    }\n}\n"
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