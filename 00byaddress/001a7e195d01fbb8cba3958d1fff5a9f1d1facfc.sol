// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.14;

import "EnumerableSet.sol";
import "GnosisSafe.sol";
import "Ownable.sol";

/// Interface of AclProtector
interface AclProtector {
    function check(bytes32 role, uint256 value, bytes calldata data) external returns (bool);
}

/// Interface of TransferProtector
interface TransferProtector {
    function check(bytes32[] memory roles, address receiver, uint256 value) external returns (bool);
}

/// @title A GnosisSafe module that implements Cobo's role based access control policy
/// @author Cobo Safe Dev Team ([email protected])
/// @notice Use this module to access Gnosis Safe with role based access control policy
/// @dev This contract implements the core data structure and its related features.
contract CoboSafeModule is Ownable {
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using EnumerableSet for EnumerableSet.AddressSet;

    string public constant NAME = "Cobo Safe Module";
    string public constant VERSION = "0.4.0";

    address public transferProtector;

    // Below are predefined roles: ROLE_HARVESTER
    //
    // Gnosis safe owners need to call to `grantRole(ROLE_XXX, delegate)` to grant permission to a delegate.

    // 'harvesters\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
    bytes32 public constant ROLE_HARVESTER =
        0x6861727665737465727300000000000000000000000000000000000000000000;

    /// @notice Event fired when a delegate is added
    /// @dev Event fired when a delegate is added via `grantRole` method
    /// @param delegate the delegate being added
    /// @param sender the owner who added the delegate
    event DelegateAdded(address indexed delegate, address indexed sender);

    /// @notice Event fired when a delegate is removed
    /// @dev Event fired when a delegate is remove via `revokeRole` method
    /// @param delegate the delegate being removed
    /// @param sender the owner who removed the delegate
    event DelegateRemoved(address indexed delegate, address indexed sender);

    /// @notice Event fired when a role is added
    /// @dev Event fired when a role is being added via `addRole` method
    /// @param role the role being added
    /// @param sender the owner who added the role
    event RoleAdded(bytes32 indexed role, address indexed sender);

    /// @notice Event fired when a role is grant to a delegate
    /// @dev Event fired when a role is grant to a delegate via `grantRole`
    /// @param role the role being granted
    /// @param delegate the delegate being granted the given role
    /// @param sender the owner who granted the role to the given delegate
    event RoleGranted(
        bytes32 indexed role,
        address indexed delegate,
        address indexed sender
    );

    /// @notice Event fired when a role is revoked from a delegate
    /// @dev Event fired when a role is revoked from a delegate via `revokeRole`
    /// @param role the role being revoked
    /// @param delegate the delegate being revoked the given role
    /// @param sender the owner who revoked the role from the given delegate
    event RoleRevoked(
        bytes32 indexed role,
        address indexed delegate,
        address indexed sender
    );

    /// @notice Event fired after a transaction is successfully executed by a delegate
    /// @dev Event fired after a transaction is successfully executed by a delegate via `execTransaction` method
    /// @param to the targate contract to execute the transaction
    /// @param value the ether value to be sent to the target contract when executing the transaction
    /// @param operation use `call` or `delegatecall` to execute the transaction on the contract
    /// @param data input data to execute the transaction on the given contract
    /// @param sender the delegate who execute the transaction
    event ExecTransaction(
        address indexed to,
        uint256 value,
        Enum.Operation operation,
        bytes data,
        address indexed sender
    );

    /// @notice Event fired when a role is associated with a contract and its function list
    /// @dev Event fired when a role is associated with a contract and its function list via `assocRoleWithContractFuncs`
    /// @param role the role to be associated with the given contract and function list
    /// @param _contract the target contract to be associated with the role
    /// @param funcList a list of function signatures of the given contract to be associated with the role
    /// @param sender the owner who associated the role with the contract and its function list
    event AssocContractFuncs(
        bytes32 indexed role,
        address indexed _contract,
        string[] funcList,
        address indexed sender
    );

    /// @notice Event fired when a role is disassociate from a contract and its function list
    /// @dev Event fired when a role is disassociate from a contract and its function list via `dissocRoleFromContractFuncs`
    /// @param role the role to be disassociated from the given contract and function list
    /// @param _contract the target contract to be disassociated from the role
    /// @param funcList a list of function signatures of the given contract to be disassociated from the role
    /// @param sender the owner who disassociated the role from the contract and its function list
    event DissocContractFuncs(
        bytes32 indexed role,
        address indexed _contract,
        string[] funcList,
        address indexed sender
    );

    /// @notice Event fired when a protector to a contract is changed
    /// @dev Event fired when a protector is changed to protect a contract via `installAclForContract`
    /// @param _contract the target contract to be protected
    /// @param oldProtector the protector contract to be uninstalled
    /// @param newProtector the protector contract to installed
    /// @param sender the owner who install the protector to the target contract
    event ProtectorChanged(
        address indexed _contract,
        address oldProtector,
        address indexed newProtector,
        address indexed sender
    );

    /// @notice Event fired when a call is checked by a protector
    /// @dev Event fired when the a call is checked via `_hasPermission`
    /// @param _contract the target contract to be execute
    /// @param contractFunc the target contract function to be execute
    /// @param protector the contract to check the access control
    /// @param role the role to check the access control
    /// @param value the ether value to be sent to the target contract
    /// @param data the original call data
    /// @param success the result of access control checking
    /// @param sender the user who trigger the execution
    event AclChecked(
        address indexed _contract,
        bytes4 contractFunc,
        address indexed protector,
        bytes32 role,
        uint256 value,
        bytes data,
        bool success,
        address indexed sender
    );

    /// @notice Event fired when a transfer is checked by a protector
    /// @dev Event fired when the a transfer is checked via `_isAllowedTransfer`
    /// @param protector the contract to check the access control
    /// @param receiver transfer receiver
    /// @param value ETH value
    /// @param success the result of access control checking
    /// @param sender the user who trigger the execution
    event TransferChecked(
        address indexed protector,
        address indexed receiver,
        uint256 value,
        bool success,
        address indexed sender
    );

    /// @dev Tracks the set of granted delegates. The set is dynamically added
    ///      to or removed from by  `grantRole` and `rokeRole`.  `isDelegate`
    ///      also uses it to test if a caller is a valid delegate or not
    EnumerableSet.AddressSet delegateSet;

    /// @dev Tracks what roles each delegate owns. The mapping is dynamically
    ///      added to or removed from by  `grantRole` and `rokeRole`. `hasRole`
    ///      also uses it to test if a delegate is granted a given role or not
    mapping(address => EnumerableSet.Bytes32Set) delegateToRoles;

    /// @dev Tracks the set of roles. The set keeps track of all defined roles.
    ///      It is updated by `addRole`, and possibly by `removeRole` if to be
    ///      supported. All role based access policy checks against the set for
    ///      role validity.
    EnumerableSet.Bytes32Set roleSet;

    /// @dev Tracks the set of contract address. The set keeps track of contracts
    ///      which have been associated with a role. It is updated by
    ///      `assocRoleWithContractFuncs` and `dissocRoleFromContractFuncs`
    EnumerableSet.AddressSet contractSet;

    /// @dev mapping from `contract address` => `function selectors`
    mapping(address => EnumerableSet.Bytes32Set) contractToFuncs;

    /// @dev mapping from `contract address` => `function selectors` => `list of roles`
    mapping(address => mapping(bytes32 => EnumerableSet.Bytes32Set)) funcToRoles;

    /// @dev mapping from `contract address` => `protector contract address`
    mapping(address => address) public contractToProtector;

    /// @dev modifier to assert only delegate is allow to proceed
    modifier onlyDelegate() {
        require(isDelegate(_msgSender()), "must be delegate");
        _;
    }

    /// @dev modifier to assert the given role must be predefined
    /// @param role the role to be checked
    modifier roleDefined(bytes32 role) {
        require(roleSet.contains(role), "unrecognized role");
        _;
    }

    /// @notice Contructor function for CoboSafeModule
    /// @dev When this module is deployed, its ownership will be automatically
    ///      transferred to the given Gnosis safe instance. The instance is
    ///      supposed to call `enableModule` on the constructed module instance
    ///      in order for it to function properly.
    /// @param _safe the Gnosis Safe (GnosisSafeProxy) instance's address
    constructor(address payable _safe) {
        require(_safe != address(0), "invalid safe address");

        // Add default role. Use `addRole` to make sure `RoleAdded` event is fired
        addRole(ROLE_HARVESTER);

        // make the given safe the owner of the current module.
        _transferOwnership(_safe);
    }

    /// @notice Checks if an address is a permitted delegate
    /// @dev the address must have been granted role via `grantRole` in order to become a delegate
    /// @param delegate the address to be checked
    /// @return true|false
    function isDelegate(address delegate) public view returns (bool) {
        return delegateSet.contains(delegate);
    }

    /// @notice Grant a role to a delegate
    /// @dev Granting a role to a delegate will give delegate permission to call
    ///      contract functions associated with the role. Only owner can grant
    ///      role and the must be predefined and not granted to the delegate
    ///      already. on success, `RoleGranted` event would be fired and
    ///      possibly `DelegateAdded` as well if this is the first role being
    ///      granted to the delegate.
    /// @param role the role to be granted
    /// @param delegate the delegate to be granted role
    function grantRole(bytes32 role, address delegate)
        external
        onlyOwner
        roleDefined(role)
    {
        require(!_hasRole(role, delegate), "role already granted");

        delegateToRoles[delegate].add(role);

        // We need to emit `DelegateAdded` before `RoleGranted` to allow
        // subgraph event handler to process in sensible order.
        if (delegateSet.add(delegate)) {
            emit DelegateAdded(delegate, _msgSender());
        }

        emit RoleGranted(role, delegate, _msgSender());
    }

    /// @notice Revoke a role from a delegate
    /// @dev Revoking a role from a delegate will remove the permission the
    ///      delegate has to call contract functions associated with the role.
    ///      Only owner can revoke the role.  The role has to be predefined and
    ///      granted to the delegate before revoking, otherwise the function
    ///      will be reverted. `RoleRevoked` event would be fired and possibly
    ///      `DelegateRemoved` as well if this is the last role the delegate
    ///      owns.
    /// @param role the role to be granted
    /// @param delegate the delegate to be granted role
    function revokeRole(bytes32 role, address delegate)
        external
        onlyOwner
        roleDefined(role)
    {
        require(_hasRole(role, delegate), "role has not been granted");

        delegateToRoles[delegate].remove(role);

        // We need to make sure `RoleRevoked` is fired before `DelegateRemoved`
        // to make sure the event handlers in subgraphs are triggered in the
        // right order.
        emit RoleRevoked(role, delegate, _msgSender());

        if (delegateToRoles[delegate].length() == 0) {
            delegateSet.remove(delegate);
            emit DelegateRemoved(delegate, _msgSender());
        }
    }

    /// @notice Test if a delegate has a role
    /// @dev The role has be predefined or the function will be reverted.
    /// @param role the role to be checked
    /// @param delegate the delegate to be checked
    /// @return true|false
    function hasRole(bytes32 role, address delegate)
        external
        view
        roleDefined(role)
        returns (bool)
    {
        return _hasRole(role, delegate);
    }

    /// @notice Test if a delegate has a role (internal version)
    /// @dev This does the same check as hasRole, but avoid the checks on if the
    ///      role is defined. Internal functions can call this to save gas consumptions
    /// @param role the role to be checked
    /// @param delegate the delegate to be checked
    /// @return true|false
    function _hasRole(bytes32 role, address delegate)
        internal
        view
        returns (bool)
    {
        return delegateToRoles[delegate].contains(role);
    }

    /// @notice Add a new role
    /// @dev only owner can call this function, the role has to be a new role.
    ///      On success, `RoleAdded` event will be fired
    /// @param role the role to be added
    function addRole(bytes32 role) public onlyOwner {
        require(!roleSet.contains(role), "role exists");

        roleSet.add(role);

        emit RoleAdded(role, _msgSender());
    }

    /// @notice Call Gnosis Safe to execute a transaction
    /// @dev Delegates can call this method to invoke gnosis safe to forward to
    ///      transaction to target contract method `to`::`func`, where `func`
    ///      is the function selector contained in first 4 bytes of `data`.
    ///      The function can only be called by delegates.
    /// @param to The target contract to be called by Gnosis Safe
    /// @param value The value data to be transferred by Gnosis Safe
    /// @param data The input data to be called by Gnosis Safe
    ///
    /// TODO: implement EIP712 signature.
    function execTransaction(address to, uint256 value, bytes calldata data)
        external
        onlyDelegate
    {
        _execTransaction(to, value, data);
    }

    /// @notice Batch execute multiple transaction via Gnosis Safe
    /// @dev This is batch version of the `execTransaction` function to allow
    ///      the delegates to bundle multiple calls into a single transaction and
    ///      sign only once. Batch execute the transactions, one failure cause the
    ///      batch reverted. Only delegates are allowed to call this.
    /// @param toList list of contract addresses to be called
    /// @param valueList list of value data associated with each contract call
    /// @param dataList list of input data associated with each contract call
    function batchExecTransactions(
        address[] calldata toList,
        uint256[] calldata valueList,
        bytes[] calldata dataList
    ) external onlyDelegate {
        require(
            toList.length > 0 && toList.length == valueList.length && toList.length == dataList.length,
            "invalid inputs"
        );

        for (uint256 i = 0; i < toList.length; i++) {
            _execTransaction(toList[i], valueList[i], dataList[i]);
        }
    }

    /// @dev The internal implementation of `execTransaction` and
    ///      `batchExecTransactions`, that invokes gnosis safe to forward to
    ///      transaction to target contract method `to`::`func`, where `func` is
    ///      the function selector contained in first 4 bytes of `data`.  The
    ///      function checks if the calling delegate has the required permission
    ///      to call the designated contract function before invoking Gnosis
    ///      Safe.
    /// @param to The target contract to be called by Gnosis Safe
    /// @param value The value data to be transferred by Gnosis Safe
    /// @param data The input data to be called by Gnosis Safe
    function _execTransaction(address to, uint256 value, bytes calldata data) internal {
        require(_hasPermission(_msgSender(), to, value, data), "permission denied");

        // execute the transaction from Gnosis Safe, note this call will bypass
        // safe owners confirmation.
        require(
            GnosisSafe(payable(owner())).execTransactionFromModule(
                to,
                value,
                data,
                Enum.Operation.Call
            ),
            "failed in execution in safe"
        );

        emit ExecTransaction(to, value, Enum.Operation.Call, data, _msgSender());
    }

    /// @dev Internal function to check if a delegate has the permission to call a given contract function
    /// @param delegate the delegate to be checked
    /// @param to the target contract
    /// @param value The value to be checked by protector
    /// @param data the calldata to be checked by protector
    /// @return true|false
    function _hasPermission(
        address delegate,
        address to,
        uint256 value,
        bytes calldata data
    ) internal returns (bool) {
        bytes32[] memory roles = getRolesByDelegate(delegate);
        require(roles.length > 0, "no role granted to delegate");

        // for ETH transfer
        if (data.length == 0) {
            require(transferProtector != address(0), "invalid transfer protector");
            return _checkByTransferProtector(roles, to, value);

        } else {
            require(data.length >=4, "invalid data length");

            bytes4 selector;
            assembly {
                selector := calldataload(data.offset)
            }

            EnumerableSet.Bytes32Set storage funcRoles = funcToRoles[to][selector];
            address aclProtector = contractToProtector[to];
            for (uint256 index = 0; index < roles.length; index++) {
                // check func and parameters
                if (funcRoles.contains(roles[index])) {
                    if (aclProtector != address(0)) {
                        if (_checkByAclProtector(aclProtector, roles[index], to, value, selector, data)) {
                            return true;
                        }
                    } else {
                        return true;
                    }
                }
            }
            return false;
        }
    }

    /// @dev Internal function to check if a role has the permission to transfer ETH
    /// @param roles the roles to check
    /// @param receiver ETH receiver
    /// @param value ETH value
    /// @return true|false
    function _checkByTransferProtector(
        bytes32[] memory roles,
        address receiver,
        uint256 value
    ) internal returns (bool) {
        bool success = TransferProtector(transferProtector).check(
            roles,
            receiver,
            value
        );
        emit TransferChecked(
            transferProtector,
            receiver,
            value,
            success,
            _msgSender()
        );
        return success;
    }

    /// @dev Internal function to check if a role has the permission to exec transaction
    /// @param aclProtector address of the protector contract
    /// @param role the role to check
    /// @param to the target contract
    /// @param value The value to be checked by protector
    /// @param selector the selector to be checked by protector
    /// @param data the calldata to be checked by protector
    /// @return true|false
    function _checkByAclProtector(
        address aclProtector,
        bytes32 role,
        address to,
        uint256 value,
        bytes4 selector,
        bytes calldata data
    ) internal returns (bool) {
        bool success = AclProtector(aclProtector).check(
            role,
            value,
            data
        );
        emit AclChecked(
            to,
            selector,
            aclProtector,
            role,
            value,
            data,
            success,
            _msgSender()
        );
        return success;
    }

    /// @dev Public function to check if a role has the permission to call a given contract function
    /// @param role the role to be checked
    /// @param to the target contract
    /// @param selector the function selector of the contract function to be called
    /// @return true|false
    function roleCanAccessContractFunc(
        bytes32 role,
        address to,
        bytes4 selector
    ) external view returns (bool) {
        return funcToRoles[to][selector].contains(role);
    }

    /// @notice Associate a role with given contract funcs
    /// @dev only owners are allowed to call this function, the given role has
    ///      to be predefined. On success, the role will be associated with the
    ///      given contract function, `AssocContractFuncs` event will be fired.
    /// @param role the role to be associated
    /// @param _contract the contract address to be associated with the role
    /// @param funcList the list of contract functions to be associated with the role
    function assocRoleWithContractFuncs(
        bytes32 role,
        address _contract,
        string[] calldata funcList
    ) external onlyOwner roleDefined(role) {
        require(funcList.length > 0, "empty funcList");

        for (uint256 index = 0; index < funcList.length; index++) {
            bytes4 funcSelector = bytes4(keccak256(bytes(funcList[index])));
            bytes32 funcSelector32 = bytes32(funcSelector);
            funcToRoles[_contract][funcSelector32].add(role);
            contractToFuncs[_contract].add(funcSelector32);
        }

        contractSet.add(_contract);

        emit AssocContractFuncs(role, _contract, funcList, _msgSender());
    }

    /// @notice Dissociate a role from given contract funcs
    /// @dev only owners are allowed to call this function, the given role has
    ///      to be predefined. On success, the role will be disassociated from
    ///      the given contract function, `DissocContractFuncs` event will be
    ///      fired.
    /// @param role the role to be disassociated
    /// @param _contract the contract address to be disassociated from the role
    /// @param funcList the list of contract functions to be disassociated from the role
    function dissocRoleFromContractFuncs(
        bytes32 role,
        address _contract,
        string[] calldata funcList
    ) external onlyOwner roleDefined(role) {
        require(funcList.length > 0, "empty funcList");

        for (uint256 index = 0; index < funcList.length; index++) {
            bytes4 funcSelector = bytes4(keccak256(bytes(funcList[index])));
            bytes32 funcSelector32 = bytes32(funcSelector);
            funcToRoles[_contract][funcSelector32].remove(role);

            if (funcToRoles[_contract][funcSelector32].length() <= 0) {
                contractToFuncs[_contract].remove(funcSelector32);
            }
        }

        if (contractToFuncs[_contract].length() <= 0) {
            contractSet.remove(_contract);
        }

        emit DissocContractFuncs(role, _contract, funcList, _msgSender());
    }

    /// @notice Install protector contract for given contract
    /// @dev only owners are allowed to call this function. On success, the contract will
    ///      protector with the selector mapping, `AclInstalled` event will be fired,
    ///      `AclUninstalled` event may be fired when old protector existed.
    /// @param _contract the contract to be protected(address(0) for transfer protector)
    /// @param newProtector the acl/transfer contract
    function installProtectorContract(address _contract, address newProtector)
        external
        onlyOwner
    {
        address oldProtector;
        if (address(_contract) == address(0)) {
            // transfer protector
            oldProtector = transferProtector;
            require(oldProtector != newProtector, "invalid transfer protector");
            transferProtector = newProtector;
        } else {
            // acl protector
            oldProtector = contractToProtector[_contract];
            require(oldProtector != newProtector, "invalid acl protector");
            contractToProtector[_contract] = newProtector;
        }

        emit ProtectorChanged(_contract, oldProtector, newProtector, _msgSender());
    }

    /// @notice Get all the delegates who are currently granted any role
    /// @return list of delegate addresses
    function getAllDelegates() public view returns (address[] memory) {
        bytes32[] memory store = delegateSet._inner._values;
        address[] memory result;
        assembly {
            result := store
        }
        return result;
    }

    /// @notice Given a delegate, return all the roles granted to the delegate
    /// @return list of roles
    function getRolesByDelegate(address delegate)
        public
        view
        returns (bytes32[] memory)
    {
        return delegateToRoles[delegate]._inner._values;
    }

    /// @notice Get all the roles defined in the module
    /// @return list of roles
    function getAllRoles() external view returns (bytes32[] memory) {
        return roleSet._inner._values;
    }

    /// @notice Get all the contracts ever associated with any role
    /// @return list of contract addresses
    function getAllContracts() public view returns (address[] memory) {
        bytes32[] memory store = contractSet._inner._values;
        address[] memory result;
        assembly {
            result := store
        }
        return result;
    }

    /// @notice Given a contract, list all the function selectors of this contract associated with a role
    /// @param _contract the contract
    /// @return list of function selectors in the contract ever associated with a role
    function getFuncsByContract(address _contract)
        public
        view
        returns (bytes4[] memory)
    {
        bytes32[] memory store = contractToFuncs[_contract]._inner._values;
        bytes4[] memory result;
        assembly {
            result := store
        }
        return result;
    }

    /// @notice Given a function, list all the roles that have permission to access to them
    /// @param _contract the contract address
    /// @param funcSelector the function selector
    /// @return list of roles
    function getRolesByContractFunction(address _contract, bytes4 funcSelector)
        public
        view
        returns (bytes32[] memory)
    {
        return funcToRoles[_contract][funcSelector]._inner._values;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/structs/EnumerableSet.sol)

pragma solidity ^0.8.0;

/**
 * @dev Library for managing
 * https://en.wikipedia.org/wiki/Set_(abstract_data_type)[sets] of primitive
 * types.
 *
 * Sets have the following properties:
 *
 * - Elements are added, removed, and checked for existence in constant time
 * (O(1)).
 * - Elements are enumerated in O(n). No guarantees are made on the ordering.
 *
 * ```
 * contract Example {
 *     // Add the library methods
 *     using EnumerableSet for EnumerableSet.AddressSet;
 *
 *     // Declare a set state variable
 *     EnumerableSet.AddressSet private mySet;
 * }
 * ```
 *
 * As of v3.3.0, sets of type `bytes32` (`Bytes32Set`), `address` (`AddressSet`)
 * and `uint256` (`UintSet`) are supported.
 */
library EnumerableSet {
    // To implement this library for multiple types with as little code
    // repetition as possible, we write it in terms of a generic Set type with
    // bytes32 values.
    // The Set implementation uses private functions, and user-facing
    // implementations (such as AddressSet) are just wrappers around the
    // underlying Set.
    // This means that we can only create new EnumerableSets for types that fit
    // in bytes32.

    struct Set {
        // Storage of set values
        bytes32[] _values;
        // Position of the value in the `values` array, plus 1 because index 0
        // means a value is not in the set.
        mapping(bytes32 => uint256) _indexes;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            // The value is stored at length-1, but we add 1 to all indexes
            // and use 0 as a sentinel value
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function _remove(Set storage set, bytes32 value) private returns (bool) {
        // We read and store the value's index to prevent multiple reads from the same storage slot
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            // Equivalent to contains(set, value)
            // To delete an element from the _values array in O(1), we swap the element to delete with the last one in
            // the array, and then remove the last element (sometimes called as 'swap and pop').
            // This modifies the order of the array, as noted in {at}.

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set._values[lastIndex];

                // Move the last value to the index where the value to delete is
                set._values[toDeleteIndex] = lastValue;
                // Update the index for the moved value
                set._indexes[lastValue] = valueIndex; // Replace lastValue's index to valueIndex
            }

            // Delete the slot where the moved value was stored
            set._values.pop();

            // Delete the index for the deleted slot
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function _contains(Set storage set, bytes32 value) private view returns (bool) {
        return set._indexes[value] != 0;
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function _at(Set storage set, uint256 index) private view returns (bytes32) {
        return set._values[index];
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function _values(Set storage set) private view returns (bytes32[] memory) {
        return set._values;
    }

    // Bytes32Set

    struct Bytes32Set {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _add(set._inner, value);
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {
        return _remove(set._inner, value);
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {
        return _contains(set._inner, value);
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {
        return _at(set._inner, index);
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {
        return _values(set._inner);
    }

    // AddressSet

    struct AddressSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(AddressSet storage set, address value) internal returns (bool) {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(AddressSet storage set, address value) internal returns (bool) {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(AddressSet storage set, address value) internal view returns (bool) {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    /**
     * @dev Returns the number of values in the set. O(1).
     */
    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(AddressSet storage set, uint256 index) internal view returns (address) {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(AddressSet storage set) internal view returns (address[] memory) {
        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }

    // UintSet

    struct UintSet {
        Set _inner;
    }

    /**
     * @dev Add a value to a set. O(1).
     *
     * Returns true if the value was added to the set, that is if it was not
     * already present.
     */
    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    /**
     * @dev Removes a value from a set. O(1).
     *
     * Returns true if the value was removed from the set, that is if it was
     * present.
     */
    function remove(UintSet storage set, uint256 value) internal returns (bool) {
        return _remove(set._inner, bytes32(value));
    }

    /**
     * @dev Returns true if the value is in the set. O(1).
     */
    function contains(UintSet storage set, uint256 value) internal view returns (bool) {
        return _contains(set._inner, bytes32(value));
    }

    /**
     * @dev Returns the number of values on the set. O(1).
     */
    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    /**
     * @dev Returns the value stored at position `index` in the set. O(1).
     *
     * Note that there are no guarantees on the ordering of values inside the
     * array, and it may change when more values are added or removed.
     *
     * Requirements:
     *
     * - `index` must be strictly less than {length}.
     */
    function at(UintSet storage set, uint256 index) internal view returns (uint256) {
        return uint256(_at(set._inner, index));
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function values(UintSet storage set) internal view returns (uint256[] memory) {
        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}

// SPDX-License-Identifier: LGPL-3.0-only
pragma solidity 0.8.14;

/// @title Enum - Collection of enums
/// @author Richard Meissner - <[email protected]>
contract Enum {
    enum Operation {
        Call,
        DelegateCall
    }
}

interface GnosisSafe {
    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation
    ) external returns (bool success);
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.14;

import "Context.sol";

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function _transferOwnership(address newOwner) internal virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract TransferOwnable is Ownable {
    function transferOwnership(address newOwner) public virtual onlyOwner {
        _transferOwnership(newOwner);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}