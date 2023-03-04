// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorInterface {
  function latestAnswer() external view returns (int256);

  function latestTimestamp() external view returns (uint256);

  function latestRound() external view returns (uint256);

  function getAnswer(uint256 roundId) external view returns (int256);

  function getTimestamp(uint256 roundId) external view returns (uint256);

  event AnswerUpdated(int256 indexed current, uint256 indexed roundId, uint256 updatedAt);

  event NewRound(uint256 indexed roundId, address indexed startedBy, uint256 startedAt);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import { ABDKMath64x64 } from 'abdk-libraries-solidity/ABDKMath64x64.sol';

/**
 * @title SolidState token extensions for ABDKMath64x64 library
 */
library ABDKMath64x64Token {
    using ABDKMath64x64 for int128;

    /**
     * @notice convert 64x64 fixed point representation of token amount to decimal
     * @param value64x64 64x64 fixed point representation of token amount
     * @param decimals token display decimals
     * @return value decimal representation of token amount
     */
    function toDecimals(int128 value64x64, uint8 decimals)
        internal
        pure
        returns (uint256 value)
    {
        value = value64x64.mulu(10**decimals);
    }

    /**
     * @notice convert decimal representation of token amount to 64x64 fixed point
     * @param value decimal representation of token amount
     * @param decimals token display decimals
     * @return value64x64 64x64 fixed point representation of token amount
     */
    function fromDecimals(uint256 value, uint8 decimals)
        internal
        pure
        returns (int128 value64x64)
    {
        value64x64 = ABDKMath64x64.divu(value, 10**decimals);
    }

    /**
     * @notice convert 64x64 fixed point representation of token amount to wei (18 decimals)
     * @param value64x64 64x64 fixed point representation of token amount
     * @return value wei representation of token amount
     */
    function toWei(int128 value64x64) internal pure returns (uint256 value) {
        value = toDecimals(value64x64, 18);
    }

    /**
     * @notice convert wei representation (18 decimals) of token amount to 64x64 fixed point
     * @param value wei representation of token amount
     * @return value64x64 64x64 fixed point representation of token amount
     */
    function fromWei(uint256 value) internal pure returns (int128 value64x64) {
        value64x64 = fromDecimals(value, 18);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library OwnableStorage {
    struct Layout {
        address owner;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.Ownable');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function setOwner(Layout storage l, address owner) internal {
        l.owner = owner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Partial ERC1155 interface needed by internal functions
 */
interface IERC1155Internal {
    event TransferSingle(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(
        address indexed account,
        address indexed operator,
        bool approved
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC165 } from './IERC165.sol';

/**
 * @title ERC1155 transfer receiver interface
 */
interface IERC1155Receiver is IERC165 {
    /**
     * @notice validate receipt of ERC1155 transfer
     * @param operator executor of transfer
     * @param from sender of tokens
     * @param id token ID received
     * @param value quantity of tokens received
     * @param data data payload
     * @return function's own selector if transfer is accepted
     */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);

    /**
     * @notice validate receipt of ERC1155 batch transfer
     * @param operator executor of transfer
     * @param from sender of tokens
     * @param ids token IDs received
     * @param values quantities of tokens received
     * @param data data payload
     * @return function's own selector if transfer is accepted
     */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title ERC165 interface registration interface
 * @dev see https://eips.ethereum.org/EIPS/eip-165
 */
interface IERC165 {
    /**
     * @notice query whether contract has registered support for given interface
     * @param interfaceId interface id
     * @return bool whether interface is supported
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC173Internal } from './IERC173Internal.sol';

/**
 * @title Contract ownership standard interface
 * @dev see https://eips.ethereum.org/EIPS/eip-173
 */
interface IERC173 is IERC173Internal {
    /**
     * @notice get the ERC173 contract owner
     * @return conrtact owner
     */
    function owner() external view returns (address);

    /**
     * @notice transfer contract ownership to new account
     * @param account address of new owner
     */
    function transferOwnership(address account) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Partial ERC173 interface needed by internal functions
 */
interface IERC173Internal {
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20Internal } from './IERC20Internal.sol';

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 is IERC20Internal {
    /**
     * @notice query the total minted token supply
     * @return token supply
     */
    function totalSupply() external view returns (uint256);

    /**
     * @notice query the token balance of given account
     * @param account address to query
     * @return token balance
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @notice query the allowance granted from given holder to given spender
     * @param holder approver of allowance
     * @param spender recipient of allowance
     * @return token allowance
     */
    function allowance(address holder, address spender)
        external
        view
        returns (uint256);

    /**
     * @notice grant approval to spender to spend tokens
     * @dev prefer ERC20Extended functions to avoid transaction-ordering vulnerability (see https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729)
     * @param spender recipient of allowance
     * @param amount quantity of tokens approved for spending
     * @return success status (always true; otherwise function should revert)
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @notice transfer tokens to given recipient
     * @param recipient beneficiary of token transfer
     * @param amount quantity of tokens to transfer
     * @return success status (always true; otherwise function should revert)
     */
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    /**
     * @notice transfer tokens to given recipient on behalf of given holder
     * @param holder holder of tokens prior to transfer
     * @param recipient beneficiary of token transfer
     * @param amount quantity of tokens to transfer
     * @return success status (always true; otherwise function should revert)
     */
    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Partial ERC20 interface needed by internal functions
 */
interface IERC20Internal {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20Metadata } from '../token/ERC20/metadata/IERC20Metadata.sol';
import { IERC20 } from './IERC20.sol';

/**
 * @title WETH (Wrapped ETH) interface
 */
interface IWETH is IERC20, IERC20Metadata {
    /**
     * @notice convert ETH to WETH
     */
    function deposit() external payable;

    /**
     * @notice convert WETH to ETH
     * @dev if caller is a contract, it should have a fallback or receive function
     * @param amount quantity of WETH to convert, denominated in wei
     */
    function withdraw(uint256 amount) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC1155Receiver } from '../../../interfaces/IERC1155Receiver.sol';
import { AddressUtils } from '../../../utils/AddressUtils.sol';
import { IERC1155BaseInternal } from './IERC1155BaseInternal.sol';
import { ERC1155BaseStorage } from './ERC1155BaseStorage.sol';

/**
 * @title Base ERC1155 internal functions
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)
 */
abstract contract ERC1155BaseInternal is IERC1155BaseInternal {
    using AddressUtils for address;

    /**
     * @notice query the balance of given token held by given address
     * @param account address to query
     * @param id token to query
     * @return token balance
     */
    function _balanceOf(address account, uint256 id)
        internal
        view
        virtual
        returns (uint256)
    {
        if (account == address(0))
            revert ERC1155Base__BalanceQueryZeroAddress();
        return ERC1155BaseStorage.layout().balances[id][account];
    }

    /**
     * @notice mint given quantity of tokens for given address
     * @dev ERC1155Receiver implementation is not checked
     * @param account beneficiary of minting
     * @param id token ID
     * @param amount quantity of tokens to mint
     * @param data data payload
     */
    function _mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        if (account == address(0)) revert ERC1155Base__MintToZeroAddress();

        _beforeTokenTransfer(
            msg.sender,
            address(0),
            account,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        ERC1155BaseStorage.layout().balances[id][account] += amount;

        emit TransferSingle(msg.sender, address(0), account, id, amount);
    }

    /**
     * @notice mint given quantity of tokens for given address
     * @param account beneficiary of minting
     * @param id token ID
     * @param amount quantity of tokens to mint
     * @param data data payload
     */
    function _safeMint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        _mint(account, id, amount, data);

        _doSafeTransferAcceptanceCheck(
            msg.sender,
            address(0),
            account,
            id,
            amount,
            data
        );
    }

    /**
     * @notice mint batch of tokens for given address
     * @dev ERC1155Receiver implementation is not checked
     * @param account beneficiary of minting
     * @param ids list of token IDs
     * @param amounts list of quantities of tokens to mint
     * @param data data payload
     */
    function _mintBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        if (account == address(0)) revert ERC1155Base__MintToZeroAddress();
        if (ids.length != amounts.length)
            revert ERC1155Base__ArrayLengthMismatch();

        _beforeTokenTransfer(
            msg.sender,
            address(0),
            account,
            ids,
            amounts,
            data
        );

        mapping(uint256 => mapping(address => uint256))
            storage balances = ERC1155BaseStorage.layout().balances;

        for (uint256 i; i < ids.length; ) {
            balances[ids[i]][account] += amounts[i];
            unchecked {
                i++;
            }
        }

        emit TransferBatch(msg.sender, address(0), account, ids, amounts);
    }

    /**
     * @notice mint batch of tokens for given address
     * @param account beneficiary of minting
     * @param ids list of token IDs
     * @param amounts list of quantities of tokens to mint
     * @param data data payload
     */
    function _safeMintBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        _mintBatch(account, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(
            msg.sender,
            address(0),
            account,
            ids,
            amounts,
            data
        );
    }

    /**
     * @notice burn given quantity of tokens held by given address
     * @param account holder of tokens to burn
     * @param id token ID
     * @param amount quantity of tokens to burn
     */
    function _burn(
        address account,
        uint256 id,
        uint256 amount
    ) internal virtual {
        if (account == address(0)) revert ERC1155Base__BurnFromZeroAddress();

        _beforeTokenTransfer(
            msg.sender,
            account,
            address(0),
            _asSingletonArray(id),
            _asSingletonArray(amount),
            ''
        );

        mapping(address => uint256) storage balances = ERC1155BaseStorage
            .layout()
            .balances[id];

        unchecked {
            if (amount > balances[account])
                revert ERC1155Base__BurnExceedsBalance();
            balances[account] -= amount;
        }

        emit TransferSingle(msg.sender, account, address(0), id, amount);
    }

    /**
     * @notice burn given batch of tokens held by given address
     * @param account holder of tokens to burn
     * @param ids token IDs
     * @param amounts quantities of tokens to burn
     */
    function _burnBatch(
        address account,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {
        if (account == address(0)) revert ERC1155Base__BurnFromZeroAddress();
        if (ids.length != amounts.length)
            revert ERC1155Base__ArrayLengthMismatch();

        _beforeTokenTransfer(msg.sender, account, address(0), ids, amounts, '');

        mapping(uint256 => mapping(address => uint256))
            storage balances = ERC1155BaseStorage.layout().balances;

        unchecked {
            for (uint256 i; i < ids.length; i++) {
                uint256 id = ids[i];
                if (amounts[i] > balances[id][account])
                    revert ERC1155Base__BurnExceedsBalance();
                balances[id][account] -= amounts[i];
            }
        }

        emit TransferBatch(msg.sender, account, address(0), ids, amounts);
    }

    /**
     * @notice transfer tokens between given addresses
     * @dev ERC1155Receiver implementation is not checked
     * @param operator executor of transfer
     * @param sender sender of tokens
     * @param recipient receiver of tokens
     * @param id token ID
     * @param amount quantity of tokens to transfer
     * @param data data payload
     */
    function _transfer(
        address operator,
        address sender,
        address recipient,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        if (recipient == address(0))
            revert ERC1155Base__TransferToZeroAddress();

        _beforeTokenTransfer(
            operator,
            sender,
            recipient,
            _asSingletonArray(id),
            _asSingletonArray(amount),
            data
        );

        mapping(uint256 => mapping(address => uint256))
            storage balances = ERC1155BaseStorage.layout().balances;

        unchecked {
            uint256 senderBalance = balances[id][sender];
            if (amount > senderBalance)
                revert ERC1155Base__TransferExceedsBalance();
            balances[id][sender] = senderBalance - amount;
        }

        balances[id][recipient] += amount;

        emit TransferSingle(operator, sender, recipient, id, amount);
    }

    /**
     * @notice transfer tokens between given addresses
     * @param operator executor of transfer
     * @param sender sender of tokens
     * @param recipient receiver of tokens
     * @param id token ID
     * @param amount quantity of tokens to transfer
     * @param data data payload
     */
    function _safeTransfer(
        address operator,
        address sender,
        address recipient,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {
        _transfer(operator, sender, recipient, id, amount, data);

        _doSafeTransferAcceptanceCheck(
            operator,
            sender,
            recipient,
            id,
            amount,
            data
        );
    }

    /**
     * @notice transfer batch of tokens between given addresses
     * @dev ERC1155Receiver implementation is not checked
     * @param operator executor of transfer
     * @param sender sender of tokens
     * @param recipient receiver of tokens
     * @param ids token IDs
     * @param amounts quantities of tokens to transfer
     * @param data data payload
     */
    function _transferBatch(
        address operator,
        address sender,
        address recipient,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        if (recipient == address(0))
            revert ERC1155Base__TransferToZeroAddress();
        if (ids.length != amounts.length)
            revert ERC1155Base__ArrayLengthMismatch();

        _beforeTokenTransfer(operator, sender, recipient, ids, amounts, data);

        mapping(uint256 => mapping(address => uint256))
            storage balances = ERC1155BaseStorage.layout().balances;

        for (uint256 i; i < ids.length; ) {
            uint256 token = ids[i];
            uint256 amount = amounts[i];

            unchecked {
                uint256 senderBalance = balances[token][sender];

                if (amount > senderBalance)
                    revert ERC1155Base__TransferExceedsBalance();

                balances[token][sender] = senderBalance - amount;

                i++;
            }

            // balance increase cannot be unchecked because ERC1155Base neither tracks nor validates a totalSupply
            balances[token][recipient] += amount;
        }

        emit TransferBatch(operator, sender, recipient, ids, amounts);
    }

    /**
     * @notice transfer batch of tokens between given addresses
     * @param operator executor of transfer
     * @param sender sender of tokens
     * @param recipient receiver of tokens
     * @param ids token IDs
     * @param amounts quantities of tokens to transfer
     * @param data data payload
     */
    function _safeTransferBatch(
        address operator,
        address sender,
        address recipient,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {
        _transferBatch(operator, sender, recipient, ids, amounts, data);

        _doSafeBatchTransferAcceptanceCheck(
            operator,
            sender,
            recipient,
            ids,
            amounts,
            data
        );
    }

    /**
     * @notice wrap given element in array of length 1
     * @param element element to wrap
     * @return singleton array
     */
    function _asSingletonArray(uint256 element)
        private
        pure
        returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;
        return array;
    }

    /**
     * @notice revert if applicable transfer recipient is not valid ERC1155Receiver
     * @param operator executor of transfer
     * @param from sender of tokens
     * @param to receiver of tokens
     * @param id token ID
     * @param amount quantity of tokens to transfer
     * @param data data payload
     */
    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155Received(
                    operator,
                    from,
                    id,
                    amount,
                    data
                )
            returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector)
                    revert ERC1155Base__ERC1155ReceiverRejected();
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert ERC1155Base__ERC1155ReceiverNotImplemented();
            }
        }
    }

    /**
     * @notice revert if applicable transfer recipient is not valid ERC1155Receiver
     * @param operator executor of transfer
     * @param from sender of tokens
     * @param to receiver of tokens
     * @param ids token IDs
     * @param amounts quantities of tokens to transfer
     * @param data data payload
     */
    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {
        if (to.isContract()) {
            try
                IERC1155Receiver(to).onERC1155BatchReceived(
                    operator,
                    from,
                    ids,
                    amounts,
                    data
                )
            returns (bytes4 response) {
                if (
                    response != IERC1155Receiver.onERC1155BatchReceived.selector
                ) revert ERC1155Base__ERC1155ReceiverRejected();
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert ERC1155Base__ERC1155ReceiverNotImplemented();
            }
        }
    }

    /**
     * @notice ERC1155 hook, called before all transfers including mint and burn
     * @dev function should be overridden and new implementation must call super
     * @dev called for both single and batch transfers
     * @param operator executor of transfer
     * @param from sender of tokens
     * @param to receiver of tokens
     * @param ids token IDs
     * @param amounts quantities of tokens to transfer
     * @param data data payload
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

library ERC1155BaseStorage {
    struct Layout {
        mapping(uint256 => mapping(address => uint256)) balances;
        mapping(address => mapping(address => bool)) operatorApprovals;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.ERC1155Base');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC1155Internal } from '../../../interfaces/IERC1155Internal.sol';

/**
 * @title ERC1155 base interface
 */
interface IERC1155BaseInternal is IERC1155Internal {
    error ERC1155Base__ArrayLengthMismatch();
    error ERC1155Base__BalanceQueryZeroAddress();
    error ERC1155Base__NotOwnerOrApproved();
    error ERC1155Base__SelfApproval();
    error ERC1155Base__BurnExceedsBalance();
    error ERC1155Base__BurnFromZeroAddress();
    error ERC1155Base__ERC1155ReceiverRejected();
    error ERC1155Base__ERC1155ReceiverNotImplemented();
    error ERC1155Base__MintToZeroAddress();
    error ERC1155Base__TransferExceedsBalance();
    error ERC1155Base__TransferToZeroAddress();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { EnumerableSet } from '../../../utils/EnumerableSet.sol';
import { ERC1155BaseInternal } from '../base/ERC1155BaseInternal.sol';
import { IERC1155Enumerable } from './IERC1155Enumerable.sol';
import { ERC1155EnumerableInternal, ERC1155EnumerableStorage } from './ERC1155EnumerableInternal.sol';

/**
 * @title ERC1155 implementation including enumerable and aggregate functions
 */
abstract contract ERC1155Enumerable is
    IERC1155Enumerable,
    ERC1155EnumerableInternal
{
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    /**
     * @inheritdoc IERC1155Enumerable
     */
    function totalSupply(uint256 id) public view virtual returns (uint256) {
        return _totalSupply(id);
    }

    /**
     * @inheritdoc IERC1155Enumerable
     */
    function totalHolders(uint256 id) public view virtual returns (uint256) {
        return _totalHolders(id);
    }

    /**
     * @inheritdoc IERC1155Enumerable
     */
    function accountsByToken(uint256 id)
        public
        view
        virtual
        returns (address[] memory)
    {
        return _accountsByToken(id);
    }

    /**
     * @inheritdoc IERC1155Enumerable
     */
    function tokensByAccount(address account)
        public
        view
        virtual
        returns (uint256[] memory)
    {
        return _tokensByAccount(account);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { EnumerableSet } from '../../../utils/EnumerableSet.sol';
import { ERC1155BaseInternal, ERC1155BaseStorage } from '../base/ERC1155BaseInternal.sol';
import { ERC1155EnumerableStorage } from './ERC1155EnumerableStorage.sol';

/**
 * @title ERC1155Enumerable internal functions
 */
abstract contract ERC1155EnumerableInternal is ERC1155BaseInternal {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    /**
     * @notice query total minted supply of given token
     * @param id token id to query
     * @return token supply
     */
    function _totalSupply(uint256 id) internal view virtual returns (uint256) {
        return ERC1155EnumerableStorage.layout().totalSupply[id];
    }

    /**
     * @notice query total number of holders for given token
     * @param id token id to query
     * @return quantity of holders
     */
    function _totalHolders(uint256 id) internal view virtual returns (uint256) {
        return ERC1155EnumerableStorage.layout().accountsByToken[id].length();
    }

    /**
     * @notice query holders of given token
     * @param id token id to query
     * @return list of holder addresses
     */
    function _accountsByToken(uint256 id)
        internal
        view
        virtual
        returns (address[] memory)
    {
        EnumerableSet.AddressSet storage accounts = ERC1155EnumerableStorage
            .layout()
            .accountsByToken[id];

        address[] memory addresses = new address[](accounts.length());

        unchecked {
            for (uint256 i; i < accounts.length(); i++) {
                addresses[i] = accounts.at(i);
            }
        }

        return addresses;
    }

    /**
     * @notice query tokens held by given address
     * @param account address to query
     * @return list of token ids
     */
    function _tokensByAccount(address account)
        internal
        view
        virtual
        returns (uint256[] memory)
    {
        EnumerableSet.UintSet storage tokens = ERC1155EnumerableStorage
            .layout()
            .tokensByAccount[account];

        uint256[] memory ids = new uint256[](tokens.length());

        unchecked {
            for (uint256 i; i < tokens.length(); i++) {
                ids[i] = tokens.at(i);
            }
        }

        return ids;
    }

    /**
     * @notice ERC1155 hook: update aggregate values
     * @inheritdoc ERC1155BaseInternal
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        if (from != to) {
            ERC1155EnumerableStorage.Layout storage l = ERC1155EnumerableStorage
                .layout();
            mapping(uint256 => EnumerableSet.AddressSet)
                storage tokenAccounts = l.accountsByToken;
            EnumerableSet.UintSet storage fromTokens = l.tokensByAccount[from];
            EnumerableSet.UintSet storage toTokens = l.tokensByAccount[to];

            for (uint256 i; i < ids.length; ) {
                uint256 amount = amounts[i];

                if (amount > 0) {
                    uint256 id = ids[i];

                    if (from == address(0)) {
                        l.totalSupply[id] += amount;
                    } else if (_balanceOf(from, id) == amount) {
                        tokenAccounts[id].remove(from);
                        fromTokens.remove(id);
                    }

                    if (to == address(0)) {
                        l.totalSupply[id] -= amount;
                    } else if (_balanceOf(to, id) == 0) {
                        tokenAccounts[id].add(to);
                        toTokens.add(id);
                    }
                }

                unchecked {
                    i++;
                }
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { EnumerableSet } from '../../../utils/EnumerableSet.sol';

library ERC1155EnumerableStorage {
    struct Layout {
        mapping(uint256 => uint256) totalSupply;
        mapping(uint256 => EnumerableSet.AddressSet) accountsByToken;
        mapping(address => EnumerableSet.UintSet) tokensByAccount;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256('solidstate.contracts.storage.ERC1155Enumerable');

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC1155BaseInternal } from '../base/IERC1155BaseInternal.sol';

/**
 * @title ERC1155 enumerable and aggregate function interface
 */
interface IERC1155Enumerable is IERC1155BaseInternal {
    /**
     * @notice query total minted supply of given token
     * @param id token id to query
     * @return token supply
     */
    function totalSupply(uint256 id) external view returns (uint256);

    /**
     * @notice query total number of holders for given token
     * @param id token id to query
     * @return quantity of holders
     */
    function totalHolders(uint256 id) external view returns (uint256);

    /**
     * @notice query holders of given token
     * @param id token id to query
     * @return list of holder addresses
     */
    function accountsByToken(uint256 id)
        external
        view
        returns (address[] memory);

    /**
     * @notice query tokens held by given address
     * @param account address to query
     * @return list of token ids
     */
    function tokensByAccount(address account)
        external
        view
        returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20 } from '../../../interfaces/IERC20.sol';
import { IERC20BaseInternal } from './IERC20BaseInternal.sol';

/**
 * @title ERC20 base interface
 */
interface IERC20Base is IERC20BaseInternal, IERC20 {

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20Internal } from '../../../interfaces/IERC20Internal.sol';

/**
 * @title ERC20 base interface
 */
interface IERC20BaseInternal is IERC20Internal {
    error ERC20Base__ApproveFromZeroAddress();
    error ERC20Base__ApproveToZeroAddress();
    error ERC20Base__BurnExceedsBalance();
    error ERC20Base__BurnFromZeroAddress();
    error ERC20Base__InsufficientAllowance();
    error ERC20Base__MintToZeroAddress();
    error ERC20Base__TransferExceedsBalance();
    error ERC20Base__TransferFromZeroAddress();
    error ERC20Base__TransferToZeroAddress();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20ExtendedInternal } from './IERC20ExtendedInternal.sol';

/**
 * @title ERC20 extended interface
 */
interface IERC20Extended is IERC20ExtendedInternal {
    /**
     * @notice increase spend amount granted to spender
     * @param spender address whose allowance to increase
     * @param amount quantity by which to increase allowance
     * @return success status (always true; otherwise function will revert)
     */
    function increaseAllowance(address spender, uint256 amount)
        external
        returns (bool);

    /**
     * @notice decrease spend amount granted to spender
     * @param spender address whose allowance to decrease
     * @param amount quantity by which to decrease allowance
     * @return success status (always true; otherwise function will revert)
     */
    function decreaseAllowance(address spender, uint256 amount)
        external
        returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20BaseInternal } from '../base/IERC20BaseInternal.sol';

/**
 * @title ERC20 extended internal interface
 */
interface IERC20ExtendedInternal is IERC20BaseInternal {
    error ERC20Extended__ExcessiveAllowance();
    error ERC20Extended__InsufficientAllowance();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20Base } from './base/IERC20Base.sol';
import { IERC20Extended } from './extended/IERC20Extended.sol';
import { IERC20Metadata } from './metadata/IERC20Metadata.sol';
import { IERC20Permit } from './permit/IERC20Permit.sol';

interface ISolidStateERC20 is
    IERC20Base,
    IERC20Extended,
    IERC20Metadata,
    IERC20Permit
{}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20MetadataInternal } from './IERC20MetadataInternal.sol';

/**
 * @title ERC20 metadata interface
 */
interface IERC20Metadata is IERC20MetadataInternal {
    /**
     * @notice return token name
     * @return token name
     */
    function name() external view returns (string memory);

    /**
     * @notice return token symbol
     * @return token symbol
     */
    function symbol() external view returns (string memory);

    /**
     * @notice return token decimals, generally used only for display purposes
     * @return token decimals
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title ERC20 metadata internal interface
 */
interface IERC20MetadataInternal {

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20Metadata } from '../metadata/IERC20Metadata.sol';
import { IERC2612 } from './IERC2612.sol';
import { IERC20PermitInternal } from './IERC20PermitInternal.sol';

// TODO: note that IERC20Metadata is needed for eth-permit library

interface IERC20Permit is IERC20PermitInternal, IERC2612 {

}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC2612Internal } from './IERC2612Internal.sol';

interface IERC20PermitInternal is IERC2612Internal {
    error ERC20Permit__ExpiredDeadline();
    error ERC20Permit__InvalidSignature();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC2612Internal } from './IERC2612Internal.sol';

/**
 * @title ERC2612 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-2612.
 */
interface IERC2612 is IERC2612Internal {
    /**
     * @notice return the EIP-712 domain separator unique to contract and chain
     * @return domainSeparator domain separator
     */
    function DOMAIN_SEPARATOR() external view returns (bytes32 domainSeparator);

    /**
     * @notice get the current ERC2612 nonce for the given address
     * @return current nonce
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @notice approve spender to transfer tokens held by owner via signature
     * @dev this function may be vulnerable to approval replay attacks
     * @param owner holder of tokens and signer of permit
     * @param spender beneficiary of approval
     * @param amount quantity of tokens to approve
     * @param v secp256k1 'v' value
     * @param r secp256k1 'r' value
     * @param s secp256k1 's' value
     */
    function permit(
        address owner,
        address spender,
        uint256 amount,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

interface IERC2612Internal {}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { UintUtils } from './UintUtils.sol';

library AddressUtils {
    using UintUtils for uint256;

    error AddressUtils__InsufficientBalance();
    error AddressUtils__NotContract();
    error AddressUtils__SendValueFailed();

    function toString(address account) internal pure returns (string memory) {
        return uint256(uint160(account)).toHexString(20);
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable account, uint256 amount) internal {
        (bool success, ) = account.call{ value: amount }('');
        if (!success) revert AddressUtils__SendValueFailed();
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionCall(target, data, 'AddressUtils: failed low-level call');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory error
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, error);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                'AddressUtils: failed low-level call with value'
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) internal returns (bytes memory) {
        if (value > address(this).balance)
            revert AddressUtils__InsufficientBalance();
        return _functionCallWithValue(target, data, value, error);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory error
    ) private returns (bytes memory) {
        if (!isContract(target)) revert AddressUtils__NotContract();

        (bool success, bytes memory returnData) = target.call{ value: value }(
            data
        );

        if (success) {
            return returnData;
        } else if (returnData.length > 0) {
            assembly {
                let returnData_size := mload(returnData)
                revert(add(32, returnData), returnData_size)
            }
        } else {
            revert(error);
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title Set implementation with enumeration functions
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts (MIT license)
 */
library EnumerableSet {
    error EnumerableSet__IndexOutOfBounds();

    struct Set {
        bytes32[] _values;
        // 1-indexed to allow 0 to signify nonexistence
        mapping(bytes32 => uint256) _indexes;
    }

    struct Bytes32Set {
        Set _inner;
    }

    struct AddressSet {
        Set _inner;
    }

    struct UintSet {
        Set _inner;
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {
        return _at(set._inner, index);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {
        return address(uint160(uint256(_at(set._inner, index))));
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {
        return uint256(_at(set._inner, index));
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, value);
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {
        return _contains(set._inner, bytes32(value));
    }

    function indexOf(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (uint256)
    {
        return _indexOf(set._inner, value);
    }

    function indexOf(AddressSet storage set, address value)
        internal
        view
        returns (uint256)
    {
        return _indexOf(set._inner, bytes32(uint256(uint160(value))));
    }

    function indexOf(UintSet storage set, uint256 value)
        internal
        view
        returns (uint256)
    {
        return _indexOf(set._inner, bytes32(value));
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function length(AddressSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function length(UintSet storage set) internal view returns (uint256) {
        return _length(set._inner);
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _add(set._inner, value);
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {
        return _add(set._inner, bytes32(value));
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, value);
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {
        return _remove(set._inner, bytes32(value));
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {
        if (index >= set._values.length)
            revert EnumerableSet__IndexOutOfBounds();
        return set._values[index];
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {
        return set._indexes[value] != 0;
    }

    function _indexOf(Set storage set, bytes32 value)
        private
        view
        returns (uint256)
    {
        unchecked {
            return set._indexes[value] - 1;
        }
    }

    function _length(Set storage set) private view returns (uint256) {
        return set._values.length;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {
        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {
        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {
            unchecked {
                bytes32 last = set._values[set._values.length - 1];

                // move last value to now-vacant index

                set._values[valueIndex - 1] = last;
                set._indexes[last] = valueIndex;
            }
            // clear last index

            set._values.pop();
            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

import { IERC20 } from '../interfaces/IERC20.sol';
import { AddressUtils } from './AddressUtils.sol';

/**
 * @title Safe ERC20 interaction library
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)
 */
library SafeERC20 {
    using AddressUtils for address;

    error SafeERC20__ApproveFromNonZeroToNonZero();
    error SafeERC20__DecreaseAllowanceBelowZero();
    error SafeERC20__OperationFailed();

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev safeApprove (like approve) should only be called when setting an initial allowance or when resetting it to zero; otherwise prefer safeIncreaseAllowance and safeDecreaseAllowance
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        if ((value != 0) && (token.allowance(address(this), spender) != 0))
            revert SafeERC20__ApproveFromNonZeroToNonZero();

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            if (oldAllowance < value)
                revert SafeERC20__DecreaseAllowanceBelowZero();
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(
                token,
                abi.encodeWithSelector(
                    token.approve.selector,
                    spender,
                    newAllowance
                )
            );
        }
    }

    /**
     * @notice send transaction data and check validity of return value, if present
     * @param token ERC20 token interface
     * @param data transaction data
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(
            data,
            'SafeERC20: low-level call failed'
        );

        if (returndata.length > 0) {
            if (!abi.decode(returndata, (bool)))
                revert SafeERC20__OperationFailed();
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.8;

/**
 * @title utility functions for uint256 operations
 * @dev derived from https://github.com/OpenZeppelin/openzeppelin-contracts/ (MIT license)
 */
library UintUtils {
    error UintUtils__InsufficientHexLength();

    bytes16 private constant HEX_SYMBOLS = '0123456789abcdef';

    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0';
        }

        uint256 temp = value;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return '0x00';
        }

        uint256 length = 0;

        for (uint256 temp = value; temp != 0; temp >>= 8) {
            unchecked {
                length++;
            }
        }

        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = '0';
        buffer[1] = 'x';

        unchecked {
            for (uint256 i = 2 * length + 1; i > 1; --i) {
                buffer[i] = HEX_SYMBOLS[value & 0xf];
                value >>= 4;
            }
        }

        if (value != 0) revert UintUtils__InsufficientHexLength();

        return string(buffer);
    }
}

// SPDX-License-Identifier: BSD-4-Clause
/*
 * ABDK Math 64.64 Smart Contract Library.  Copyright © 2019 by ABDK Consulting.
 * Author: Mikhail Vladimirov <[email protected]>
 */
pragma solidity ^0.8.0;

/**
 * Smart contract library of mathematical functions operating with signed
 * 64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
 * basically a simple fraction whose numerator is signed 128-bit integer and
 * denominator is 2^64.  As long as denominator is always the same, there is no
 * need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
 * represented by int128 type holding only the numerator.
 */
library ABDKMath64x64 {
  /*
   * Minimum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;

  /*
   * Maximum value signed 64.64-bit fixed point number may have. 
   */
  int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Convert signed 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromInt (int256 x) internal pure returns (int128) {
    unchecked {
      require (x >= -0x8000000000000000 && x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (x << 64);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 64-bit integer number
   * rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64-bit integer number
   */
  function toInt (int128 x) internal pure returns (int64) {
    unchecked {
      return int64 (x >> 64);
    }
  }

  /**
   * Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
   * number.  Revert on overflow.
   *
   * @param x unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function fromUInt (uint256 x) internal pure returns (int128) {
    unchecked {
      require (x <= 0x7FFFFFFFFFFFFFFF);
      return int128 (int256 (x << 64));
    }
  }

  /**
   * Convert signed 64.64 fixed point number into unsigned 64-bit integer
   * number rounding down.  Revert on underflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return unsigned 64-bit integer number
   */
  function toUInt (int128 x) internal pure returns (uint64) {
    unchecked {
      require (x >= 0);
      return uint64 (uint128 (x >> 64));
    }
  }

  /**
   * Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
   * number rounding down.  Revert on overflow.
   *
   * @param x signed 128.128-bin fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function from128x128 (int256 x) internal pure returns (int128) {
    unchecked {
      int256 result = x >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Convert signed 64.64 fixed point number into signed 128.128 fixed point
   * number.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 128.128 fixed point number
   */
  function to128x128 (int128 x) internal pure returns (int256) {
    unchecked {
      return int256 (x) << 64;
    }
  }

  /**
   * Calculate x + y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function add (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) + y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x - y.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sub (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) - y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding down.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function mul (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 result = int256(x) * y >> 64;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
   * number and y is signed 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y signed 256-bit integer number
   * @return signed 256-bit integer number
   */
  function muli (int128 x, int256 y) internal pure returns (int256) {
    unchecked {
      if (x == MIN_64x64) {
        require (y >= -0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF &&
          y <= 0x1000000000000000000000000000000000000000000000000);
        return -y << 63;
      } else {
        bool negativeResult = false;
        if (x < 0) {
          x = -x;
          negativeResult = true;
        }
        if (y < 0) {
          y = -y; // We rely on overflow behavior here
          negativeResult = !negativeResult;
        }
        uint256 absoluteResult = mulu (x, uint256 (y));
        if (negativeResult) {
          require (absoluteResult <=
            0x8000000000000000000000000000000000000000000000000000000000000000);
          return -int256 (absoluteResult); // We rely on overflow behavior here
        } else {
          require (absoluteResult <=
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
          return int256 (absoluteResult);
        }
      }
    }
  }

  /**
   * Calculate x * y rounding down, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64 fixed point number
   * @param y unsigned 256-bit integer number
   * @return unsigned 256-bit integer number
   */
  function mulu (int128 x, uint256 y) internal pure returns (uint256) {
    unchecked {
      if (y == 0) return 0;

      require (x >= 0);

      uint256 lo = (uint256 (int256 (x)) * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) >> 64;
      uint256 hi = uint256 (int256 (x)) * (y >> 128);

      require (hi <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      hi <<= 64;

      require (hi <=
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF - lo);
      return hi + lo;
    }
  }

  /**
   * Calculate x / y rounding towards zero.  Revert on overflow or when y is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function div (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      int256 result = (int256 (x) << 64) / y;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are signed 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x signed 256-bit integer number
   * @param y signed 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divi (int256 x, int256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);

      bool negativeResult = false;
      if (x < 0) {
        x = -x; // We rely on overflow behavior here
        negativeResult = true;
      }
      if (y < 0) {
        y = -y; // We rely on overflow behavior here
        negativeResult = !negativeResult;
      }
      uint128 absoluteResult = divuu (uint256 (x), uint256 (y));
      if (negativeResult) {
        require (absoluteResult <= 0x80000000000000000000000000000000);
        return -int128 (absoluteResult); // We rely on overflow behavior here
      } else {
        require (absoluteResult <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return int128 (absoluteResult); // We rely on overflow behavior here
      }
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return signed 64.64-bit fixed point number
   */
  function divu (uint256 x, uint256 y) internal pure returns (int128) {
    unchecked {
      require (y != 0);
      uint128 result = divuu (x, y);
      require (result <= uint128 (MAX_64x64));
      return int128 (result);
    }
  }

  /**
   * Calculate -x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function neg (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return -x;
    }
  }

  /**
   * Calculate |x|.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function abs (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != MIN_64x64);
      return x < 0 ? -x : x;
    }
  }

  /**
   * Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
   * zero.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function inv (int128 x) internal pure returns (int128) {
    unchecked {
      require (x != 0);
      int256 result = int256 (0x100000000000000000000000000000000) / x;
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function avg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      return int128 ((int256 (x) + int256 (y)) >> 1);
    }
  }

  /**
   * Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
   * Revert on overflow or in case x * y is negative.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function gavg (int128 x, int128 y) internal pure returns (int128) {
    unchecked {
      int256 m = int256 (x) * int256 (y);
      require (m >= 0);
      require (m <
          0x4000000000000000000000000000000000000000000000000000000000000000);
      return int128 (sqrtu (uint256 (m)));
    }
  }

  /**
   * Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
   * and y is unsigned 256-bit integer number.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @param y uint256 value
   * @return signed 64.64-bit fixed point number
   */
  function pow (int128 x, uint256 y) internal pure returns (int128) {
    unchecked {
      bool negative = x < 0 && y & 1 == 1;

      uint256 absX = uint128 (x < 0 ? -x : x);
      uint256 absResult;
      absResult = 0x100000000000000000000000000000000;

      if (absX <= 0x10000000000000000) {
        absX <<= 63;
        while (y != 0) {
          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x2 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x4 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          if (y & 0x8 != 0) {
            absResult = absResult * absX >> 127;
          }
          absX = absX * absX >> 127;

          y >>= 4;
        }

        absResult >>= 64;
      } else {
        uint256 absXShift = 63;
        if (absX < 0x1000000000000000000000000) { absX <<= 32; absXShift -= 32; }
        if (absX < 0x10000000000000000000000000000) { absX <<= 16; absXShift -= 16; }
        if (absX < 0x1000000000000000000000000000000) { absX <<= 8; absXShift -= 8; }
        if (absX < 0x10000000000000000000000000000000) { absX <<= 4; absXShift -= 4; }
        if (absX < 0x40000000000000000000000000000000) { absX <<= 2; absXShift -= 2; }
        if (absX < 0x80000000000000000000000000000000) { absX <<= 1; absXShift -= 1; }

        uint256 resultShift = 0;
        while (y != 0) {
          require (absXShift < 64);

          if (y & 0x1 != 0) {
            absResult = absResult * absX >> 127;
            resultShift += absXShift;
            if (absResult > 0x100000000000000000000000000000000) {
              absResult >>= 1;
              resultShift += 1;
            }
          }
          absX = absX * absX >> 127;
          absXShift <<= 1;
          if (absX >= 0x100000000000000000000000000000000) {
              absX >>= 1;
              absXShift += 1;
          }

          y >>= 1;
        }

        require (resultShift < 64);
        absResult >>= 64 - resultShift;
      }
      int256 result = negative ? -int256 (absResult) : int256 (absResult);
      require (result >= MIN_64x64 && result <= MAX_64x64);
      return int128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down.  Revert if x < 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function sqrt (int128 x) internal pure returns (int128) {
    unchecked {
      require (x >= 0);
      return int128 (sqrtu (uint256 (int256 (x)) << 64));
    }
  }

  /**
   * Calculate binary logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function log_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      int256 msb = 0;
      int256 xc = x;
      if (xc >= 0x10000000000000000) { xc >>= 64; msb += 64; }
      if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
      if (xc >= 0x10000) { xc >>= 16; msb += 16; }
      if (xc >= 0x100) { xc >>= 8; msb += 8; }
      if (xc >= 0x10) { xc >>= 4; msb += 4; }
      if (xc >= 0x4) { xc >>= 2; msb += 2; }
      if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

      int256 result = msb - 64 << 64;
      uint256 ux = uint256 (int256 (x)) << uint256 (127 - msb);
      for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
        ux *= ux;
        uint256 b = ux >> 255;
        ux >>= 127 + b;
        result += bit * int256 (b);
      }

      return int128 (result);
    }
  }

  /**
   * Calculate natural logarithm of x.  Revert if x <= 0.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function ln (int128 x) internal pure returns (int128) {
    unchecked {
      require (x > 0);

      return int128 (int256 (
          uint256 (int256 (log_2 (x))) * 0xB17217F7D1CF79ABC9E3B39803F2F6AF >> 128));
    }
  }

  /**
   * Calculate binary exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp_2 (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      uint256 result = 0x80000000000000000000000000000000;

      if (x & 0x8000000000000000 > 0)
        result = result * 0x16A09E667F3BCC908B2FB1366EA957D3E >> 128;
      if (x & 0x4000000000000000 > 0)
        result = result * 0x1306FE0A31B7152DE8D5A46305C85EDEC >> 128;
      if (x & 0x2000000000000000 > 0)
        result = result * 0x1172B83C7D517ADCDF7C8C50EB14A791F >> 128;
      if (x & 0x1000000000000000 > 0)
        result = result * 0x10B5586CF9890F6298B92B71842A98363 >> 128;
      if (x & 0x800000000000000 > 0)
        result = result * 0x1059B0D31585743AE7C548EB68CA417FD >> 128;
      if (x & 0x400000000000000 > 0)
        result = result * 0x102C9A3E778060EE6F7CACA4F7A29BDE8 >> 128;
      if (x & 0x200000000000000 > 0)
        result = result * 0x10163DA9FB33356D84A66AE336DCDFA3F >> 128;
      if (x & 0x100000000000000 > 0)
        result = result * 0x100B1AFA5ABCBED6129AB13EC11DC9543 >> 128;
      if (x & 0x80000000000000 > 0)
        result = result * 0x10058C86DA1C09EA1FF19D294CF2F679B >> 128;
      if (x & 0x40000000000000 > 0)
        result = result * 0x1002C605E2E8CEC506D21BFC89A23A00F >> 128;
      if (x & 0x20000000000000 > 0)
        result = result * 0x100162F3904051FA128BCA9C55C31E5DF >> 128;
      if (x & 0x10000000000000 > 0)
        result = result * 0x1000B175EFFDC76BA38E31671CA939725 >> 128;
      if (x & 0x8000000000000 > 0)
        result = result * 0x100058BA01FB9F96D6CACD4B180917C3D >> 128;
      if (x & 0x4000000000000 > 0)
        result = result * 0x10002C5CC37DA9491D0985C348C68E7B3 >> 128;
      if (x & 0x2000000000000 > 0)
        result = result * 0x1000162E525EE054754457D5995292026 >> 128;
      if (x & 0x1000000000000 > 0)
        result = result * 0x10000B17255775C040618BF4A4ADE83FC >> 128;
      if (x & 0x800000000000 > 0)
        result = result * 0x1000058B91B5BC9AE2EED81E9B7D4CFAB >> 128;
      if (x & 0x400000000000 > 0)
        result = result * 0x100002C5C89D5EC6CA4D7C8ACC017B7C9 >> 128;
      if (x & 0x200000000000 > 0)
        result = result * 0x10000162E43F4F831060E02D839A9D16D >> 128;
      if (x & 0x100000000000 > 0)
        result = result * 0x100000B1721BCFC99D9F890EA06911763 >> 128;
      if (x & 0x80000000000 > 0)
        result = result * 0x10000058B90CF1E6D97F9CA14DBCC1628 >> 128;
      if (x & 0x40000000000 > 0)
        result = result * 0x1000002C5C863B73F016468F6BAC5CA2B >> 128;
      if (x & 0x20000000000 > 0)
        result = result * 0x100000162E430E5A18F6119E3C02282A5 >> 128;
      if (x & 0x10000000000 > 0)
        result = result * 0x1000000B1721835514B86E6D96EFD1BFE >> 128;
      if (x & 0x8000000000 > 0)
        result = result * 0x100000058B90C0B48C6BE5DF846C5B2EF >> 128;
      if (x & 0x4000000000 > 0)
        result = result * 0x10000002C5C8601CC6B9E94213C72737A >> 128;
      if (x & 0x2000000000 > 0)
        result = result * 0x1000000162E42FFF037DF38AA2B219F06 >> 128;
      if (x & 0x1000000000 > 0)
        result = result * 0x10000000B17217FBA9C739AA5819F44F9 >> 128;
      if (x & 0x800000000 > 0)
        result = result * 0x1000000058B90BFCDEE5ACD3C1CEDC823 >> 128;
      if (x & 0x400000000 > 0)
        result = result * 0x100000002C5C85FE31F35A6A30DA1BE50 >> 128;
      if (x & 0x200000000 > 0)
        result = result * 0x10000000162E42FF0999CE3541B9FFFCF >> 128;
      if (x & 0x100000000 > 0)
        result = result * 0x100000000B17217F80F4EF5AADDA45554 >> 128;
      if (x & 0x80000000 > 0)
        result = result * 0x10000000058B90BFBF8479BD5A81B51AD >> 128;
      if (x & 0x40000000 > 0)
        result = result * 0x1000000002C5C85FDF84BD62AE30A74CC >> 128;
      if (x & 0x20000000 > 0)
        result = result * 0x100000000162E42FEFB2FED257559BDAA >> 128;
      if (x & 0x10000000 > 0)
        result = result * 0x1000000000B17217F7D5A7716BBA4A9AE >> 128;
      if (x & 0x8000000 > 0)
        result = result * 0x100000000058B90BFBE9DDBAC5E109CCE >> 128;
      if (x & 0x4000000 > 0)
        result = result * 0x10000000002C5C85FDF4B15DE6F17EB0D >> 128;
      if (x & 0x2000000 > 0)
        result = result * 0x1000000000162E42FEFA494F1478FDE05 >> 128;
      if (x & 0x1000000 > 0)
        result = result * 0x10000000000B17217F7D20CF927C8E94C >> 128;
      if (x & 0x800000 > 0)
        result = result * 0x1000000000058B90BFBE8F71CB4E4B33D >> 128;
      if (x & 0x400000 > 0)
        result = result * 0x100000000002C5C85FDF477B662B26945 >> 128;
      if (x & 0x200000 > 0)
        result = result * 0x10000000000162E42FEFA3AE53369388C >> 128;
      if (x & 0x100000 > 0)
        result = result * 0x100000000000B17217F7D1D351A389D40 >> 128;
      if (x & 0x80000 > 0)
        result = result * 0x10000000000058B90BFBE8E8B2D3D4EDE >> 128;
      if (x & 0x40000 > 0)
        result = result * 0x1000000000002C5C85FDF4741BEA6E77E >> 128;
      if (x & 0x20000 > 0)
        result = result * 0x100000000000162E42FEFA39FE95583C2 >> 128;
      if (x & 0x10000 > 0)
        result = result * 0x1000000000000B17217F7D1CFB72B45E1 >> 128;
      if (x & 0x8000 > 0)
        result = result * 0x100000000000058B90BFBE8E7CC35C3F0 >> 128;
      if (x & 0x4000 > 0)
        result = result * 0x10000000000002C5C85FDF473E242EA38 >> 128;
      if (x & 0x2000 > 0)
        result = result * 0x1000000000000162E42FEFA39F02B772C >> 128;
      if (x & 0x1000 > 0)
        result = result * 0x10000000000000B17217F7D1CF7D83C1A >> 128;
      if (x & 0x800 > 0)
        result = result * 0x1000000000000058B90BFBE8E7BDCBE2E >> 128;
      if (x & 0x400 > 0)
        result = result * 0x100000000000002C5C85FDF473DEA871F >> 128;
      if (x & 0x200 > 0)
        result = result * 0x10000000000000162E42FEFA39EF44D91 >> 128;
      if (x & 0x100 > 0)
        result = result * 0x100000000000000B17217F7D1CF79E949 >> 128;
      if (x & 0x80 > 0)
        result = result * 0x10000000000000058B90BFBE8E7BCE544 >> 128;
      if (x & 0x40 > 0)
        result = result * 0x1000000000000002C5C85FDF473DE6ECA >> 128;
      if (x & 0x20 > 0)
        result = result * 0x100000000000000162E42FEFA39EF366F >> 128;
      if (x & 0x10 > 0)
        result = result * 0x1000000000000000B17217F7D1CF79AFA >> 128;
      if (x & 0x8 > 0)
        result = result * 0x100000000000000058B90BFBE8E7BCD6D >> 128;
      if (x & 0x4 > 0)
        result = result * 0x10000000000000002C5C85FDF473DE6B2 >> 128;
      if (x & 0x2 > 0)
        result = result * 0x1000000000000000162E42FEFA39EF358 >> 128;
      if (x & 0x1 > 0)
        result = result * 0x10000000000000000B17217F7D1CF79AB >> 128;

      result >>= uint256 (int256 (63 - (x >> 64)));
      require (result <= uint256 (int256 (MAX_64x64)));

      return int128 (int256 (result));
    }
  }

  /**
   * Calculate natural exponent of x.  Revert on overflow.
   *
   * @param x signed 64.64-bit fixed point number
   * @return signed 64.64-bit fixed point number
   */
  function exp (int128 x) internal pure returns (int128) {
    unchecked {
      require (x < 0x400000000000000000); // Overflow

      if (x < -0x400000000000000000) return 0; // Underflow

      return exp_2 (
          int128 (int256 (x) * 0x171547652B82FE1777D0FFDA0D23A7D12 >> 128));
    }
  }

  /**
   * Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
   * integer numbers.  Revert on overflow or when y is zero.
   *
   * @param x unsigned 256-bit integer number
   * @param y unsigned 256-bit integer number
   * @return unsigned 64.64-bit fixed point number
   */
  function divuu (uint256 x, uint256 y) private pure returns (uint128) {
    unchecked {
      require (y != 0);

      uint256 result;

      if (x <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)
        result = (x << 64) / y;
      else {
        uint256 msb = 192;
        uint256 xc = x >> 192;
        if (xc >= 0x100000000) { xc >>= 32; msb += 32; }
        if (xc >= 0x10000) { xc >>= 16; msb += 16; }
        if (xc >= 0x100) { xc >>= 8; msb += 8; }
        if (xc >= 0x10) { xc >>= 4; msb += 4; }
        if (xc >= 0x4) { xc >>= 2; msb += 2; }
        if (xc >= 0x2) msb += 1;  // No need to shift xc anymore

        result = (x << 255 - msb) / ((y - 1 >> msb - 191) + 1);
        require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 hi = result * (y >> 128);
        uint256 lo = result * (y & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);

        uint256 xh = x >> 192;
        uint256 xl = x << 64;

        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here
        lo = hi << 128;
        if (xl < lo) xh -= 1;
        xl -= lo; // We rely on overflow behavior here

        assert (xh == hi >> 128);

        result += xl / y;
      }

      require (result <= 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
      return uint128 (result);
    }
  }

  /**
   * Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
   * number.
   *
   * @param x unsigned 256-bit integer number
   * @return unsigned 128-bit integer number
   */
  function sqrtu (uint256 x) private pure returns (uint128) {
    unchecked {
      if (x == 0) return 0;
      else {
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) { xx >>= 128; r <<= 64; }
        if (xx >= 0x10000000000000000) { xx >>= 64; r <<= 32; }
        if (xx >= 0x100000000) { xx >>= 32; r <<= 16; }
        if (xx >= 0x10000) { xx >>= 16; r <<= 8; }
        if (xx >= 0x100) { xx >>= 8; r <<= 4; }
        if (xx >= 0x10) { xx >>= 4; r <<= 2; }
        if (xx >= 0x4) { r <<= 1; }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1; // Seven iterations should be enough
        uint256 r1 = x / r;
        return uint128 (r < r1 ? r : r1);
      }
    }
  }
}

// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.0;

/**
 * @title Premia Exchange Helper
 * @dev deployed standalone and referenced by internal functions
 * @dev do NOT set approval to this contract!
 */
interface IExchangeHelper {
    /**
     * @notice perform arbitrary swap transaction
     * @param sourceToken source token to pull into this address
     * @param targetToken target token to buy
     * @param sourceTokenAmount amount of source token to start the trade
     * @param callee exchange address to call to execute the trade.
     * @param allowanceTarget address for which to set allowance for the trade
     * @param data calldata to execute the trade
     * @param refundAddress address that un-used source token goes to
     * @return amountOut quantity of targetToken yielded by swap
     */
    function swapWithToken(
        address sourceToken,
        address targetToken,
        uint256 sourceTokenAmount,
        address callee,
        address allowanceTarget,
        bytes calldata data,
        address refundAddress
    ) external returns (uint256 amountOut);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IOFTCore} from "./IOFTCore.sol";
import {ISolidStateERC20} from "@solidstate/contracts/token/ERC20/ISolidStateERC20.sol";

/**
 * @dev Interface of the OFT standard
 */
interface IOFT is IOFTCore, ISolidStateERC20 {
    error OFT_InsufficientAllowance();
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import {IERC20} from "@solidstate/contracts/interfaces/IERC20.sol";
import {IERC165} from "@solidstate/contracts/interfaces/IERC165.sol";

/**
 * @dev Interface of the IOFT core standard
 */
interface IOFTCore is IERC165 {
    /**
     * @dev estimate send token `tokenId` to (`dstChainId`, `toAddress`)
     * dstChainId - L0 defined chain id to send tokens too
     * toAddress - dynamic bytes array which contains the address to whom you are sending tokens to on the dstChain
     * amount - amount of the tokens to transfer
     * useZro - indicates to use zro to pay L0 fees
     * adapterParam - flexible bytes array to indicate messaging adapter services in L0
     */
    function estimateSendFee(
        uint16 dstChainId,
        bytes calldata toAddress,
        uint256 amount,
        bool useZro,
        bytes calldata adapterParams
    ) external view returns (uint256 nativeFee, uint256 zroFee);

    /**
     * @dev send `amount` amount of token to (`dstChainId`, `toAddress`) from `from`
     * `from` the owner of token
     * `dstChainId` the destination chain identifier
     * `toAddress` can be any size depending on the `dstChainId`.
     * `amount` the quantity of tokens in wei
     * `refundAddress` the address LayerZero refunds if too much message fee is sent
     * `zroPaymentAddress` set to address(0x0) if not paying in ZRO (LayerZero Token)
     * `adapterParams` is a flexible bytes array to indicate messaging adapter services
     */
    function sendFrom(
        address from,
        uint16 dstChainId,
        bytes calldata toAddress,
        uint256 amount,
        address payable refundAddress,
        address zroPaymentAddress,
        bytes calldata adapterParams
    ) external payable;

    /**
     * @dev returns the circulating amount of tokens on current chain
     */
    function circulatingSupply() external view returns (uint256);

    /**
     * @dev Emitted when `amount` tokens are moved from the `sender` to (`dstChainId`, `toAddress`)
     * `nonce` is the outbound nonce
     */
    event SendToChain(
        address indexed sender,
        uint16 indexed dstChainId,
        bytes indexed toAddress,
        uint256 amount
    );

    /**
     * @dev Emitted when `amount` tokens are received from `srcChainId` into the `toAddress` on the local chain.
     * `nonce` is the inbound nonce.
     */
    event ReceiveFromChain(
        uint16 indexed srcChainId,
        bytes indexed srcAddress,
        address indexed toAddress,
        uint256 amount
    );

    event SetUseCustomAdapterParams(bool _useCustomAdapterParams);
}

// SPDX-License-Identifier: BUSL-1.1
// For further clarification please see https://license.premia.legal

pragma solidity ^0.8.0;

import {ABDKMath64x64} from "abdk-libraries-solidity/ABDKMath64x64.sol";

library OptionMath {
    using ABDKMath64x64 for int128;

    struct QuoteArgs {
        int128 varianceAnnualized64x64; // 64x64 fixed point representation of annualized variance
        int128 strike64x64; // 64x64 fixed point representation of strike price
        int128 spot64x64; // 64x64 fixed point representation of spot price
        int128 timeToMaturity64x64; // 64x64 fixed point representation of duration of option contract (in years)
        int128 oldCLevel64x64; // 64x64 fixed point representation of C-Level of Pool before purchase
        int128 oldPoolState; // 64x64 fixed point representation of current state of the pool
        int128 newPoolState; // 64x64 fixed point representation of state of the pool after trade
        int128 steepness64x64; // 64x64 fixed point representation of Pool state delta multiplier
        int128 minAPY64x64; // 64x64 fixed point representation of minimum APY for capital locked up to underwrite options
        bool isCall; // whether to price "call" or "put" option
    }

    struct CalculateCLevelDecayArgs {
        int128 timeIntervalsElapsed64x64; // 64x64 fixed point representation of quantity of discrete arbitrary intervals elapsed since last update
        int128 oldCLevel64x64; // 64x64 fixed point representation of C-Level prior to accounting for decay
        int128 utilization64x64; // 64x64 fixed point representation of pool capital utilization rate
        int128 utilizationLowerBound64x64;
        int128 utilizationUpperBound64x64;
        int128 cLevelLowerBound64x64;
        int128 cLevelUpperBound64x64;
        int128 cConvergenceULowerBound64x64;
        int128 cConvergenceUUpperBound64x64;
    }

    // 64x64 fixed point integer constants
    int128 internal constant ONE_64x64 = 0x10000000000000000;
    int128 internal constant THREE_64x64 = 0x30000000000000000;

    // 64x64 fixed point constants used in Choudhury’s approximation of the Black-Scholes CDF
    int128 private constant CDF_CONST_0 = 0x09109f285df452394; // 2260 / 3989
    int128 private constant CDF_CONST_1 = 0x19abac0ea1da65036; // 6400 / 3989
    int128 private constant CDF_CONST_2 = 0x0d3c84b78b749bd6b; // 3300 / 3989

    /**
     * @notice recalculate C-Level based on change in liquidity
     * @param initialCLevel64x64 64x64 fixed point representation of C-Level of Pool before update
     * @param oldPoolState64x64 64x64 fixed point representation of liquidity in pool before update
     * @param newPoolState64x64 64x64 fixed point representation of liquidity in pool after update
     * @param steepness64x64 64x64 fixed point representation of steepness coefficient
     * @return 64x64 fixed point representation of new C-Level
     */
    function calculateCLevel(
        int128 initialCLevel64x64,
        int128 oldPoolState64x64,
        int128 newPoolState64x64,
        int128 steepness64x64
    ) external pure returns (int128) {
        return
            newPoolState64x64
                .sub(oldPoolState64x64)
                .div(
                    oldPoolState64x64 > newPoolState64x64
                        ? oldPoolState64x64
                        : newPoolState64x64
                )
                .mul(steepness64x64)
                .neg()
                .exp()
                .mul(initialCLevel64x64);
    }

    /**
     * @notice calculate the price of an option using the Premia Finance model
     * @param args arguments of quotePrice
     * @return premiaPrice64x64 64x64 fixed point representation of Premia option price
     * @return cLevel64x64 64x64 fixed point representation of C-Level of Pool after purchase
     */
    function quotePrice(QuoteArgs memory args)
        external
        pure
        returns (
            int128 premiaPrice64x64,
            int128 cLevel64x64,
            int128 slippageCoefficient64x64
        )
    {
        int128 deltaPoolState64x64 = args
            .newPoolState
            .sub(args.oldPoolState)
            .div(args.oldPoolState)
            .mul(args.steepness64x64);
        int128 tradingDelta64x64 = deltaPoolState64x64.neg().exp();

        int128 blackScholesPrice64x64 = _blackScholesPrice(
            args.varianceAnnualized64x64,
            args.strike64x64,
            args.spot64x64,
            args.timeToMaturity64x64,
            args.isCall
        );

        cLevel64x64 = tradingDelta64x64.mul(args.oldCLevel64x64);
        slippageCoefficient64x64 = ONE_64x64.sub(tradingDelta64x64).div(
            deltaPoolState64x64
        );

        premiaPrice64x64 = blackScholesPrice64x64.mul(cLevel64x64).mul(
            slippageCoefficient64x64
        );

        int128 intrinsicValue64x64;

        if (args.isCall && args.strike64x64 < args.spot64x64) {
            intrinsicValue64x64 = args.spot64x64.sub(args.strike64x64);
        } else if (!args.isCall && args.strike64x64 > args.spot64x64) {
            intrinsicValue64x64 = args.strike64x64.sub(args.spot64x64);
        }

        int128 collateralValue64x64 = args.isCall
            ? args.spot64x64
            : args.strike64x64;

        int128 minPrice64x64 = intrinsicValue64x64.add(
            collateralValue64x64.mul(args.minAPY64x64).mul(
                args.timeToMaturity64x64
            )
        );

        if (minPrice64x64 > premiaPrice64x64) {
            premiaPrice64x64 = minPrice64x64;
        }
    }

    /**
     * @notice calculate the decay of C-Level based on heat diffusion function
     * @param args structured CalculateCLevelDecayArgs
     * @return cLevelDecayed64x64 C-Level after accounting for decay
     */
    function calculateCLevelDecay(CalculateCLevelDecayArgs memory args)
        external
        pure
        returns (int128 cLevelDecayed64x64)
    {
        int128 convFHighU64x64 = (args.utilization64x64 >=
            args.utilizationUpperBound64x64 &&
            args.oldCLevel64x64 <= args.cLevelLowerBound64x64)
            ? ONE_64x64
            : int128(0);

        int128 convFLowU64x64 = (args.utilization64x64 <=
            args.utilizationLowerBound64x64 &&
            args.oldCLevel64x64 >= args.cLevelUpperBound64x64)
            ? ONE_64x64
            : int128(0);

        cLevelDecayed64x64 = args
            .oldCLevel64x64
            .sub(args.cConvergenceULowerBound64x64.mul(convFLowU64x64))
            .sub(args.cConvergenceUUpperBound64x64.mul(convFHighU64x64))
            .mul(
                convFLowU64x64
                    .mul(ONE_64x64.sub(args.utilization64x64))
                    .add(convFHighU64x64.mul(args.utilization64x64))
                    .mul(args.timeIntervalsElapsed64x64)
                    .neg()
                    .exp()
            )
            .add(
                args.cConvergenceULowerBound64x64.mul(convFLowU64x64).add(
                    args.cConvergenceUUpperBound64x64.mul(convFHighU64x64)
                )
            );
    }

    /**
     * @notice calculate the exponential decay coefficient for a given interval
     * @param oldTimestamp timestamp of previous update
     * @param newTimestamp current timestamp
     * @return 64x64 fixed point representation of exponential decay coefficient
     */
    function _decay(uint256 oldTimestamp, uint256 newTimestamp)
        internal
        pure
        returns (int128)
    {
        return
            ONE_64x64.sub(
                (-ABDKMath64x64.divu(newTimestamp - oldTimestamp, 7 days)).exp()
            );
    }

    /**
     * @notice calculate Choudhury’s approximation of the Black-Scholes CDF
     * @param input64x64 64x64 fixed point representation of random variable
     * @return 64x64 fixed point representation of the approximated CDF of x
     */
    function _N(int128 input64x64) internal pure returns (int128) {
        // squaring via mul is cheaper than via pow
        int128 inputSquared64x64 = input64x64.mul(input64x64);

        int128 value64x64 = (-inputSquared64x64 >> 1).exp().div(
            CDF_CONST_0.add(CDF_CONST_1.mul(input64x64.abs())).add(
                CDF_CONST_2.mul(inputSquared64x64.add(THREE_64x64).sqrt())
            )
        );

        return input64x64 > 0 ? ONE_64x64.sub(value64x64) : value64x64;
    }

    /**
     * @notice calculate the price of an option using the Black-Scholes model
     * @param varianceAnnualized64x64 64x64 fixed point representation of annualized variance
     * @param strike64x64 64x64 fixed point representation of strike price
     * @param spot64x64 64x64 fixed point representation of spot price
     * @param timeToMaturity64x64 64x64 fixed point representation of duration of option contract (in years)
     * @param isCall whether to price "call" or "put" option
     * @return 64x64 fixed point representation of Black-Scholes option price
     */
    function _blackScholesPrice(
        int128 varianceAnnualized64x64,
        int128 strike64x64,
        int128 spot64x64,
        int128 timeToMaturity64x64,
        bool isCall
    ) internal pure returns (int128) {
        int128 cumulativeVariance64x64 = timeToMaturity64x64.mul(
            varianceAnnualized64x64
        );
        int128 cumulativeVarianceSqrt64x64 = cumulativeVariance64x64.sqrt();

        int128 d1_64x64 = spot64x64
            .div(strike64x64)
            .ln()
            .add(cumulativeVariance64x64 >> 1)
            .div(cumulativeVarianceSqrt64x64);
        int128 d2_64x64 = d1_64x64.sub(cumulativeVarianceSqrt64x64);

        if (isCall) {
            return
                spot64x64.mul(_N(d1_64x64)).sub(strike64x64.mul(_N(d2_64x64)));
        } else {
            return
                -spot64x64.mul(_N(-d1_64x64)).sub(
                    strike64x64.mul(_N(-d2_64x64))
                );
        }
    }
}

// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.0;

import {PremiaMiningStorage} from "./PremiaMiningStorage.sol";

interface IPremiaMining {
    struct PoolAllocPoints {
        address pool;
        bool isCallPool;
        uint256 votes;
        uint256 poolUtilizationRateBPS; // 100% = 1e4
    }

    event Claim(
        address indexed user,
        address indexed pool,
        bool indexed isCallPool,
        uint256 rewardAmount
    );

    event UpdatePoolAlloc(
        address indexed pool,
        bool indexed isCallPool,
        uint256 votes,
        uint256 poolUtilizationRateBPS
    );

    function addPremiaRewards(uint256 _amount) external;

    function premiaRewardsAvailable() external view returns (uint256);

    function getTotalAllocationPoints() external view returns (uint256);

    function getPoolInfo(address pool, bool isCallPool)
        external
        view
        returns (PremiaMiningStorage.PoolInfo memory);

    function getPremiaPerYear() external view returns (uint256);

    function pendingPremia(
        address _pool,
        bool _isCallPool,
        address _user
    ) external view returns (uint256);

    function updatePool(
        address _pool,
        bool _isCallPool,
        uint256 _totalTVL,
        uint256 _utilizationRate
    ) external;

    function allocatePending(
        address _user,
        address _pool,
        bool _isCallPool,
        uint256 _userTVLOld,
        uint256 _userTVLNew,
        uint256 _totalTVL,
        uint256 _utilizationRate
    ) external;

    function claim(
        address _user,
        address _pool,
        bool _isCallPool,
        uint256 _userTVLOld,
        uint256 _userTVLNew,
        uint256 _totalTVL,
        uint256 _utilizationRate
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1
// For further clarification please see https://license.premia.legal

pragma solidity ^0.8.0;

library PremiaMiningStorage {
    bytes32 internal constant STORAGE_SLOT =
        keccak256("premia.contracts.storage.PremiaMining");

    // Info of each pool.
    struct PoolInfo {
        uint256 allocPoint; // How many allocation points assigned to this pool. PREMIA to distribute per block.
        uint256 lastRewardTimestamp; // Last timestamp that PREMIA distribution occurs
        uint256 accPremiaPerShare; // Accumulated PREMIA per share, times 1e12. See below.
    }

    // Info of each user.
    struct UserInfo {
        uint256 reward; // Total allocated unclaimed reward
        uint256 rewardDebt; // Reward debt. See explanation below.
        //
        // We do some fancy math here. Basically, any point in time, the amount of PREMIA
        // entitled to a user but is pending to be distributed is:
        //
        //   pending reward = (user.amount * pool.accPremiaPerShare) - user.rewardDebt
        //
        // Whenever a user deposits or withdraws LP tokens to a pool. Here's what happens:
        //   1. The pool's `accPremiaPerShare` (and `lastRewardBlock`) gets updated.
        //   2. User receives the pending reward sent to his/her address.
        //   3. User's `amount` gets updated.
        //   4. User's `rewardDebt` gets updated.
    }

    struct Layout {
        // Total PREMIA left to distribute
        uint256 premiaAvailable;
        // Amount of premia distributed per year
        uint256 premiaPerYear;
        // pool -> isCallPool -> PoolInfo
        mapping(address => mapping(bool => PoolInfo)) poolInfo;
        // pool -> isCallPool -> user -> UserInfo
        mapping(address => mapping(bool => mapping(address => UserInfo))) userInfo;
        // Total allocation points. Must be the sum of all allocation points in all pools.
        uint256 totalAllocPoint;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}

// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.0;

import {VolatilitySurfaceOracleStorage} from "./VolatilitySurfaceOracleStorage.sol";

interface IVolatilitySurfaceOracle {
    /**
     * @notice Pack IV model parameters into a single bytes32
     * @dev This function is used to pack the parameters into a single variable, which is then used as input in `update`
     * @param params Parameters of IV model to pack
     * @return result The packed parameters of IV model
     */
    function formatParams(int256[5] memory params)
        external
        pure
        returns (bytes32 result);

    /**
     * @notice Unpack IV model parameters from a bytes32
     * @param input Packed IV model parameters to unpack
     * @return params The unpacked parameters of the IV model
     */
    function parseParams(bytes32 input)
        external
        pure
        returns (int256[] memory params);

    /**
     * @notice Get the list of whitelisted relayers
     * @return The list of whitelisted relayers
     */
    function getWhitelistedRelayers() external view returns (address[] memory);

    /**
     * @notice Get the IV model parameters of a token pair
     * @param base The base token of the pair
     * @param underlying The underlying token of the pair
     * @return The IV model parameters
     */
    function getParams(address base, address underlying)
        external
        view
        returns (VolatilitySurfaceOracleStorage.Update memory);

    /**
     * @notice Get unpacked IV model parameters
     * @param base The base token of the pair
     * @param underlying The underlying token of the pair
     * @return The unpacked IV model parameters
     */
    function getParamsUnpacked(address base, address underlying)
        external
        view
        returns (int256[] memory);

    /**
     * @notice Get time to maturity in years, as a 64x64 fixed point representation
     * @param maturity Maturity timestamp
     * @return Time to maturity (in years), as a 64x64 fixed point representation
     */
    function getTimeToMaturity64x64(uint64 maturity)
        external
        view
        returns (int128);

    /**
     * @notice calculate the annualized volatility for given set of parameters
     * @param base The base token of the pair
     * @param underlying The underlying token of the pair
     * @param spot64x64 64x64 fixed point representation of spot price
     * @param strike64x64 64x64 fixed point representation of strike price
     * @param timeToMaturity64x64 64x64 fixed point representation of time to maturity (denominated in years)
     * @return 64x64 fixed point representation of annualized implied volatility, where 1 is defined as 100%
     */
    function getAnnualizedVolatility64x64(
        address base,
        address underlying,
        int128 spot64x64,
        int128 strike64x64,
        int128 timeToMaturity64x64
    ) external view returns (int128);

    /**
     * @notice calculate the price of an option using the Black-Scholes model
     * @param base The base token of the pair
     * @param underlying The underlying token of the pair
     * @param spot64x64 Spot price, as a 64x64 fixed point representation
     * @param strike64x64 Strike, as a64x64 fixed point representation
     * @param timeToMaturity64x64 64x64 fixed point representation of time to maturity (denominated in years)
     * @param isCall Whether it is for call or put
     * @return 64x64 fixed point representation of the Black Scholes price
     */
    function getBlackScholesPrice64x64(
        address base,
        address underlying,
        int128 spot64x64,
        int128 strike64x64,
        int128 timeToMaturity64x64,
        bool isCall
    ) external view returns (int128);

    /**
     * @notice Get Black Scholes price as an uint256 with 18 decimals
     * @param base The base token of the pair
     * @param underlying The underlying token of the pair
     * @param spot64x64 Spot price, as a 64x64 fixed point representation
     * @param strike64x64 Strike, as a64x64 fixed point representation
     * @param timeToMaturity64x64 64x64 fixed point representation of time to maturity (denominated in years)
     * @param isCall Whether it is for call or put
     * @return Black scholes price, as an uint256 with 18 decimals
     */
    function getBlackScholesPrice(
        address base,
        address underlying,
        int128 spot64x64,
        int128 strike64x64,
        int128 timeToMaturity64x64,
        bool isCall
    ) external view returns (uint256);

    /**
     * @notice Add relayers to the whitelist so that they can add oracle surfaces
     * @param accounts The addresses to add to the whitelist
     */
    function addWhitelistedRelayers(address[] memory accounts) external;

    /**
     * @notice Remove relayers from the whitelist so that they cannot add oracle surfaces
     * @param accounts The addresses to remove from the whitelist
     */
    function removeWhitelistedRelayers(address[] memory accounts) external;

    /**
     * @notice Update a list of IV model parameters
     * @param base List of base tokens
     * @param underlying List of underlying tokens
     * @param parameters List of IV model parameters
     */
    function updateParams(
        address[] memory base,
        address[] memory underlying,
        bytes32[] memory parameters
    ) external;
}

// SPDX-License-Identifier: BUSL-1.1

pragma solidity ^0.8.0;

import {EnumerableSet} from "@solidstate/contracts/utils/EnumerableSet.sol";

library VolatilitySurfaceOracleStorage {
    bytes32 internal constant STORAGE_SLOT =
        keccak256("premia.contracts.storage.VolatilitySurfaceOracle");

    uint256 internal constant PARAM_BITS = 51;
    uint256 internal constant PARAM_BITS_MINUS_ONE = 50;
    uint256 internal constant PARAM_AMOUNT = 5;
    // START_BIT = PARAM_BITS * (PARAM_AMOUNT - 1)
    uint256 internal constant START_BIT = 204;

    struct Update {
        uint256 updatedAt;
        bytes32 params;
    }

    struct Layout {
        // Base token -> Underlying token -> Update
        mapping(address => mapping(address => Update)) parameters;
        // Relayer addresses which can be trusted to provide accurate option trades
        EnumerableSet.AddressSet whitelistedRelayers;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    function getParams(
        Layout storage l,
        address base,
        address underlying
    ) internal view returns (bytes32) {
        return l.parameters[base][underlying].params;
    }

    function parseParams(bytes32 input)
        internal
        pure
        returns (int256[] memory params)
    {
        params = new int256[](PARAM_AMOUNT);

        // Value to add to negative numbers to cast them to int256
        int256 toAdd = (int256(-1) >> PARAM_BITS) << PARAM_BITS;

        assembly {
            let i := 0
            // Value equal to -1

            let mid := shl(PARAM_BITS_MINUS_ONE, 1)

            for {

            } lt(i, PARAM_AMOUNT) {

            } {
                let offset := sub(START_BIT, mul(PARAM_BITS, i))
                let param := shr(
                    offset,
                    sub(
                        input,
                        shl(
                            add(offset, PARAM_BITS),
                            shr(add(offset, PARAM_BITS), input)
                        )
                    )
                )

                // Check if value is a negative number and needs casting
                if or(eq(param, mid), gt(param, mid)) {
                    param := add(param, toAdd)
                }

                // Store result in the params array
                mstore(add(params, add(0x20, mul(0x20, i))), param)

                i := add(i, 1)
            }
        }
    }

    function formatParams(int256[5] memory params)
        internal
        pure
        returns (bytes32 result)
    {
        int256 max = int256(1 << PARAM_BITS_MINUS_ONE);

        unchecked {
            for (uint256 i = 0; i < PARAM_AMOUNT; i++) {
                require(params[i] < max && params[i] > -max, "Out of bounds");
            }
        }

        assembly {
            let i := 0

            for {

            } lt(i, PARAM_AMOUNT) {

            } {
                let offset := sub(START_BIT, mul(PARAM_BITS, i))
                let param := mload(add(params, mul(0x20, i)))

                result := add(
                    result,
                    shl(
                        offset,
                        sub(param, shl(PARAM_BITS, shr(PARAM_BITS, param)))
                    )
                )

                i := add(i, 1)
            }
        }
    }
}

// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.0;

interface IPoolEvents {
    event Purchase(
        address indexed user,
        uint256 longTokenId,
        uint256 contractSize,
        uint256 baseCost,
        uint256 feeCost,
        int128 spot64x64
    );

    event Sell(
        address indexed user,
        uint256 longTokenId,
        uint256 contractSize,
        uint256 baseCost,
        uint256 feeCost,
        int128 spot64x64
    );

    event Exercise(
        address indexed user,
        uint256 longTokenId,
        uint256 contractSize,
        uint256 exerciseValue,
        uint256 fee
    );

    event Underwrite(
        address indexed underwriter,
        address indexed longReceiver,
        uint256 shortTokenId,
        uint256 intervalContractSize,
        uint256 intervalPremium,
        bool isManualUnderwrite
    );

    event AssignExercise(
        address indexed underwriter,
        uint256 shortTokenId,
        uint256 freedAmount,
        uint256 intervalContractSize,
        uint256 fee
    );

    event AssignSale(
        address indexed underwriter,
        uint256 shortTokenId,
        uint256 freedAmount,
        uint256 intervalContractSize
    );

    event Deposit(address indexed user, bool isCallPool, uint256 amount);

    event Withdrawal(
        address indexed user,
        bool isCallPool,
        uint256 depositedAt,
        uint256 amount
    );

    event FeeWithdrawal(bool indexed isCallPool, uint256 amount);

    event APYFeeReserved(
        address underwriter,
        uint256 shortTokenId,
        uint256 amount
    );

    event APYFeePaid(address underwriter, uint256 shortTokenId, uint256 amount);

    event Annihilate(uint256 shortTokenId, uint256 amount);

    event UpdateCLevel(
        bool indexed isCall,
        int128 cLevel64x64,
        int128 oldLiquidity64x64,
        int128 newLiquidity64x64
    );

    event UpdateSteepness(int128 steepness64x64, bool isCallPool);

    event UpdateSpotOffset(int128 spotOffset64x64);
}

// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.0;

interface IPoolInternal {
    struct SwapArgs {
        // token to pass in to swap
        address tokenIn;
        // amount of tokenIn to trade
        uint256 amountInMax;
        //min amount out to be used to purchase
        uint256 amountOutMin;
        // exchange address to call to execute the trade
        address callee;
        // address for which to set allowance for the trade
        address allowanceTarget;
        // data to execute the trade
        bytes data;
        // address to which refund excess tokens
        address refundAddress;
    }
}

// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.0;

/**
 * @notice Administrative Pool interface for parameter tuning
 */
interface IPoolSettings {
    /**
     * @notice set minimum liquidity interval sizes
     * @param baseMinimum minimum base currency interval size
     * @param underlyingMinimum minimum underlying currency interval size
     */
    function setMinimumAmounts(uint256 baseMinimum, uint256 underlyingMinimum)
        external;

    /**
     * @notice set steepness of internal C-Level update multiplier
     * @param steepness64x64 64x64 fixed point representation of steepness
     * @param isCallPool true for call, false for put
     */
    function setSteepness64x64(int128 steepness64x64, bool isCallPool) external;

    /**
     * @notice set Pool C-Level
     * @param cLevel64x64 64x46 fixed point representation of C-Level
     * @param isCallPool true for call, false for put
     */
    function setCLevel64x64(int128 cLevel64x64, bool isCallPool) external;

    /**
     * @notice set APY fee amount
     * @param feeApy64x64 64x64 fixed point representation of APY fee
     */
    function setFeeApy64x64(int128 feeApy64x64) external;

    /**
     * @notice set spot price offset rate to account for Chainlink price feed lag
     * @param spotOffset64x64 64x64 fixed point representation of spot price offset
     */
    function setSpotOffset64x64(int128 spotOffset64x64) external;
}

// SPDX-License-Identifier: BUSL-1.1
// For further clarification please see https://license.premia.legal

pragma solidity ^0.8.0;

import {ABDKMath64x64Token} from "@solidstate/abdk-math-extensions/contracts/ABDKMath64x64Token.sol";
import {IERC173} from "@solidstate/contracts/interfaces/IERC173.sol";
import {OwnableStorage} from "@solidstate/contracts/access/ownable/OwnableStorage.sol";
import {SafeERC20} from "@solidstate/contracts/utils/SafeERC20.sol";
import {IERC20} from "@solidstate/contracts/interfaces/IERC20.sol";
import {ERC1155EnumerableInternal, ERC1155EnumerableStorage, EnumerableSet} from "@solidstate/contracts/token/ERC1155/enumerable/ERC1155Enumerable.sol";
import {IWETH} from "@solidstate/contracts/interfaces/IWETH.sol";
import {ABDKMath64x64} from "abdk-libraries-solidity/ABDKMath64x64.sol";

import {IExchangeHelper} from "../interfaces/IExchangeHelper.sol";
import {OptionMath} from "../libraries/OptionMath.sol";
import {IPremiaMining} from "../mining/IPremiaMining.sol";
import {IVolatilitySurfaceOracle} from "../oracle/IVolatilitySurfaceOracle.sol";
import {IPremiaStaking} from "../staking/IPremiaStaking.sol";
import {IPoolEvents} from "./IPoolEvents.sol";
import {IPoolInternal} from "./IPoolInternal.sol";
import {PoolStorage} from "./PoolStorage.sol";

/**
 * @title Premia option pool
 * @dev deployed standalone and referenced by PoolProxy
 */
contract PoolInternal is IPoolInternal, IPoolEvents, ERC1155EnumerableInternal {
    using ABDKMath64x64 for int128;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using PoolStorage for PoolStorage.Layout;
    using SafeERC20 for IERC20;

    struct Interval {
        uint256 contractSize;
        uint256 tokenAmount;
        uint256 payment;
        uint256 apyFee;
    }

    address internal immutable WRAPPED_NATIVE_TOKEN;
    address internal immutable PREMIA_MINING_ADDRESS;
    address internal immutable FEE_RECEIVER_ADDRESS;
    address internal immutable FEE_DISCOUNT_ADDRESS;
    address internal immutable IVOL_ORACLE_ADDRESS;
    address internal immutable EXCHANGE_HELPER;

    int128 internal immutable FEE_PREMIUM_64x64;

    uint256 internal immutable UNDERLYING_FREE_LIQ_TOKEN_ID;
    uint256 internal immutable BASE_FREE_LIQ_TOKEN_ID;

    uint256 internal immutable UNDERLYING_RESERVED_LIQ_TOKEN_ID;
    uint256 internal immutable BASE_RESERVED_LIQ_TOKEN_ID;

    uint256 internal constant INVERSE_BASIS_POINT = 1e4;
    uint256 internal constant BATCHING_PERIOD = 260;

    // Multiply sell quote by this constant
    int128 internal constant SELL_COEFFICIENT_64x64 = 0xb333333333333333; // 0.7

    constructor(
        address ivolOracle,
        address wrappedNativeToken,
        address premiaMining,
        address feeReceiver,
        address feeDiscountAddress,
        int128 feePremium64x64,
        address exchangeHelper
    ) {
        IVOL_ORACLE_ADDRESS = ivolOracle;
        WRAPPED_NATIVE_TOKEN = wrappedNativeToken;
        PREMIA_MINING_ADDRESS = premiaMining;
        FEE_RECEIVER_ADDRESS = feeReceiver;
        // PremiaFeeDiscount contract address
        FEE_DISCOUNT_ADDRESS = feeDiscountAddress;
        FEE_PREMIUM_64x64 = feePremium64x64;

        EXCHANGE_HELPER = exchangeHelper;

        UNDERLYING_FREE_LIQ_TOKEN_ID = PoolStorage.formatTokenId(
            PoolStorage.TokenType.UNDERLYING_FREE_LIQ,
            0,
            0
        );
        BASE_FREE_LIQ_TOKEN_ID = PoolStorage.formatTokenId(
            PoolStorage.TokenType.BASE_FREE_LIQ,
            0,
            0
        );

        UNDERLYING_RESERVED_LIQ_TOKEN_ID = PoolStorage.formatTokenId(
            PoolStorage.TokenType.UNDERLYING_RESERVED_LIQ,
            0,
            0
        );
        BASE_RESERVED_LIQ_TOKEN_ID = PoolStorage.formatTokenId(
            PoolStorage.TokenType.BASE_RESERVED_LIQ,
            0,
            0
        );
    }

    modifier onlyProtocolOwner() {
        require(
            msg.sender == IERC173(OwnableStorage.layout().owner).owner(),
            "Not protocol owner"
        );
        _;
    }

    function _fetchFeeDiscount64x64(address feePayer)
        internal
        view
        returns (int128 discount64x64)
    {
        if (FEE_DISCOUNT_ADDRESS != address(0)) {
            discount64x64 = ABDKMath64x64.divu(
                IPremiaStaking(FEE_DISCOUNT_ADDRESS).getDiscountBPS(feePayer),
                INVERSE_BASIS_POINT
            );
        }
    }

    function _withdrawFees(bool isCall) internal returns (uint256 amount) {
        uint256 tokenId = _getReservedLiquidityTokenId(isCall);
        amount = _balanceOf(FEE_RECEIVER_ADDRESS, tokenId);

        if (amount > 0) {
            _burn(FEE_RECEIVER_ADDRESS, tokenId, amount);
            _pushTo(
                FEE_RECEIVER_ADDRESS,
                PoolStorage.layout().getPoolToken(isCall),
                amount
            );
            emit FeeWithdrawal(isCall, amount);
        }
    }

    /**
     * @notice calculate price of option contract
     * @param args structured quote arguments
     * @return result quote result
     */
    function _quotePurchasePrice(PoolStorage.QuoteArgsInternal memory args)
        internal
        view
        returns (PoolStorage.QuoteResultInternal memory result)
    {
        require(
            args.strike64x64 > 0 && args.spot64x64 > 0 && args.maturity > 0,
            "invalid args"
        );

        PoolStorage.Layout storage l = PoolStorage.layout();

        // pessimistically adjust spot price to account for price feed lag

        if (args.isCall) {
            args.spot64x64 = args.spot64x64.add(
                args.spot64x64.mul(l.spotOffset64x64)
            );
        } else {
            args.spot64x64 = args.spot64x64.sub(
                args.spot64x64.mul(l.spotOffset64x64)
            );
        }

        int128 contractSize64x64 = ABDKMath64x64Token.fromDecimals(
            args.contractSize,
            l.underlyingDecimals
        );

        (int128 adjustedCLevel64x64, int128 oldLiquidity64x64) = l
            .getRealPoolState(args.isCall);

        require(oldLiquidity64x64 > 0, "no liq");

        int128 timeToMaturity64x64 = ABDKMath64x64.divu(
            args.maturity - block.timestamp,
            365 days
        );

        int128 annualizedVolatility64x64 = IVolatilitySurfaceOracle(
            IVOL_ORACLE_ADDRESS
        ).getAnnualizedVolatility64x64(
                l.base,
                l.underlying,
                args.spot64x64,
                args.strike64x64,
                timeToMaturity64x64
            );

        require(annualizedVolatility64x64 > 0, "vol = 0");

        int128 collateral64x64 = args.isCall
            ? contractSize64x64
            : contractSize64x64.mul(args.strike64x64);

        (
            int128 price64x64,
            int128 cLevel64x64,
            int128 slippageCoefficient64x64
        ) = OptionMath.quotePrice(
                OptionMath.QuoteArgs(
                    annualizedVolatility64x64.mul(annualizedVolatility64x64),
                    args.strike64x64,
                    args.spot64x64,
                    timeToMaturity64x64,
                    adjustedCLevel64x64,
                    oldLiquidity64x64,
                    oldLiquidity64x64.sub(collateral64x64),
                    0x10000000000000000, // 64x64 fixed point representation of 1
                    l.getMinApy64x64(),
                    args.isCall
                )
            );

        result.baseCost64x64 = args.isCall
            ? price64x64.mul(contractSize64x64).div(args.spot64x64)
            : price64x64.mul(contractSize64x64);
        result.feeCost64x64 = result.baseCost64x64.mul(FEE_PREMIUM_64x64);
        result.cLevel64x64 = cLevel64x64;
        result.slippageCoefficient64x64 = slippageCoefficient64x64;
        result.feeCost64x64 -= result.feeCost64x64.mul(
            _fetchFeeDiscount64x64(args.feePayer)
        );
    }

    function _quoteSalePrice(PoolStorage.QuoteArgsInternal memory args)
        internal
        view
        returns (int128 baseCost64x64, int128 feeCost64x64)
    {
        require(
            args.strike64x64 > 0 && args.spot64x64 > 0 && args.maturity > 0,
            "invalid args"
        );

        PoolStorage.Layout storage l = PoolStorage.layout();

        int128 timeToMaturity64x64 = ABDKMath64x64.divu(
            args.maturity - block.timestamp,
            365 days
        );

        int128 annualizedVolatility64x64 = IVolatilitySurfaceOracle(
            IVOL_ORACLE_ADDRESS
        ).getAnnualizedVolatility64x64(
                l.base,
                l.underlying,
                args.spot64x64,
                args.strike64x64,
                timeToMaturity64x64
            );

        require(annualizedVolatility64x64 > 0, "vol = 0");

        int128 blackScholesPrice64x64 = OptionMath._blackScholesPrice(
            annualizedVolatility64x64.mul(annualizedVolatility64x64),
            args.strike64x64,
            args.spot64x64,
            timeToMaturity64x64,
            args.isCall
        );

        int128 exerciseValue64x64 = ABDKMath64x64Token.fromDecimals(
            _calculateExerciseValue(
                l,
                args.contractSize,
                args.spot64x64,
                args.strike64x64,
                args.isCall
            ),
            args.isCall ? l.underlyingDecimals : l.baseDecimals
        );

        if (args.isCall) {
            exerciseValue64x64 = exerciseValue64x64.mul(args.spot64x64);
        }

        int128 sellCLevel64x64;

        {
            uint256 longTokenId = PoolStorage.formatTokenId(
                PoolStorage.getTokenType(args.isCall, true),
                args.maturity,
                args.strike64x64
            );

            // Initialize to min value, and replace by current if min not set or current is lower
            sellCLevel64x64 = l.minCLevel64x64[longTokenId];

            {
                (int128 currentCLevel64x64, ) = l.getRealPoolState(args.isCall);

                if (
                    sellCLevel64x64 == 0 || currentCLevel64x64 < sellCLevel64x64
                ) {
                    sellCLevel64x64 = currentCLevel64x64;
                }
            }
        }

        int128 contractSize64x64 = ABDKMath64x64Token.fromDecimals(
            args.contractSize,
            l.underlyingDecimals
        );

        baseCost64x64 = SELL_COEFFICIENT_64x64
            .mul(sellCLevel64x64)
            .mul(
                blackScholesPrice64x64.mul(contractSize64x64).sub(
                    exerciseValue64x64
                )
            )
            .add(exerciseValue64x64);

        if (args.isCall) {
            baseCost64x64 = baseCost64x64.div(args.spot64x64);
        }

        feeCost64x64 = baseCost64x64.mul(FEE_PREMIUM_64x64);

        feeCost64x64 -= feeCost64x64.mul(_fetchFeeDiscount64x64(args.feePayer));
        baseCost64x64 -= feeCost64x64;
    }

    function _getAvailableBuybackLiquidity(uint256 shortTokenId)
        internal
        view
        returns (uint256 totalLiquidity)
    {
        PoolStorage.Layout storage l = PoolStorage.layout();

        EnumerableSet.AddressSet storage accounts = ERC1155EnumerableStorage
            .layout()
            .accountsByToken[shortTokenId];
        (PoolStorage.TokenType tokenType, , ) = PoolStorage.parseTokenId(
            shortTokenId
        );
        bool isCall = tokenType == PoolStorage.TokenType.SHORT_CALL;

        uint256 length = accounts.length();

        for (uint256 i = 0; i < length; i++) {
            address lp = accounts.at(i);

            if (l.isBuybackEnabled[lp][isCall]) {
                totalLiquidity += _balanceOf(lp, shortTokenId);
            }
        }
    }

    /**
     * @notice burn corresponding long and short option tokens
     * @param l storage layout struct
     * @param account holder of tokens to annihilate
     * @param maturity timestamp of option maturity
     * @param strike64x64 64x64 fixed point representation of strike price
     * @param isCall true for call, false for put
     * @param contractSize quantity of option contract tokens to annihilate
     * @return collateralFreed amount of collateral freed, including APY fee rebate
     */
    function _annihilate(
        PoolStorage.Layout storage l,
        address account,
        uint64 maturity,
        int128 strike64x64,
        bool isCall,
        uint256 contractSize
    ) internal returns (uint256 collateralFreed) {
        uint256 longTokenId = PoolStorage.formatTokenId(
            PoolStorage.getTokenType(isCall, true),
            maturity,
            strike64x64
        );
        uint256 shortTokenId = PoolStorage.formatTokenId(
            PoolStorage.getTokenType(isCall, false),
            maturity,
            strike64x64
        );

        uint256 tokenAmount = l.contractSizeToBaseTokenAmount(
            contractSize,
            strike64x64,
            isCall
        );

        // calculate unconsumed APY fee so that it may be refunded

        uint256 intervalApyFee = _calculateApyFee(
            l,
            shortTokenId,
            tokenAmount,
            maturity
        );

        _burn(account, longTokenId, contractSize);

        uint256 rebate = _fulfillApyFee(
            l,
            account,
            shortTokenId,
            contractSize,
            intervalApyFee,
            isCall
        );

        _burn(account, shortTokenId, contractSize);

        collateralFreed = tokenAmount + rebate + intervalApyFee;

        emit Annihilate(shortTokenId, contractSize);
    }

    /**
     * @notice deposit underlying currency, underwriting calls of that currency with respect to base currency
     * @param amount quantity of underlying currency to deposit
     * @param isCallPool whether to deposit underlying in the call pool or base in the put pool
     */
    function _deposit(
        PoolStorage.Layout storage l,
        uint256 amount,
        bool isCallPool
    ) internal {
        // Reset gradual divestment timestamp
        delete l.divestmentTimestamps[msg.sender][isCallPool];

        _processPendingDeposits(l, isCallPool);

        l.depositedAt[msg.sender][isCallPool] = block.timestamp;
        _addUserTVL(
            l,
            msg.sender,
            isCallPool,
            amount,
            l.getUtilization64x64(isCallPool)
        );

        _processAvailableFunds(msg.sender, amount, isCallPool, false, false);

        emit Deposit(msg.sender, isCallPool, amount);
    }

    /**
     * @notice purchase option
     * @param l storage layout struct
     * @param account recipient of purchased option
     * @param maturity timestamp of option maturity
     * @param strike64x64 64x64 fixed point representation of strike price
     * @param isCall true for call, false for put
     * @param contractSize size of option contract
     * @param newPrice64x64 64x64 fixed point representation of current spot price
     * @return baseCost quantity of tokens required to purchase long position
     * @return feeCost quantity of tokens required to pay fees
     */
    function _purchase(
        PoolStorage.Layout storage l,
        address account,
        uint64 maturity,
        int128 strike64x64,
        bool isCall,
        uint256 contractSize,
        int128 newPrice64x64
    ) internal returns (uint256 baseCost, uint256 feeCost) {
        require(maturity > block.timestamp, "expired");
        require(contractSize >= l.underlyingMinimum, "too small");

        int128 utilization64x64 = l.getUtilization64x64(isCall);

        {
            uint256 tokenAmount = l.contractSizeToBaseTokenAmount(
                contractSize,
                strike64x64,
                isCall
            );

            uint256 freeLiquidityTokenId = _getFreeLiquidityTokenId(isCall);

            require(
                tokenAmount <=
                    _totalSupply(freeLiquidityTokenId) -
                        l.totalPendingDeposits(isCall) -
                        (_balanceOf(account, freeLiquidityTokenId) -
                            l.pendingDepositsOf(account, isCall)),
                "insuf liq"
            );
        }

        PoolStorage.QuoteResultInternal memory quote = _quotePurchasePrice(
            PoolStorage.QuoteArgsInternal(
                account,
                maturity,
                strike64x64,
                newPrice64x64,
                contractSize,
                isCall
            )
        );

        baseCost = ABDKMath64x64Token.toDecimals(
            quote.baseCost64x64,
            l.getTokenDecimals(isCall)
        );

        feeCost = ABDKMath64x64Token.toDecimals(
            quote.feeCost64x64,
            l.getTokenDecimals(isCall)
        );

        uint256 longTokenId = PoolStorage.formatTokenId(
            PoolStorage.getTokenType(isCall, true),
            maturity,
            strike64x64
        );

        {
            int128 minCLevel64x64 = l.minCLevel64x64[longTokenId];
            if (minCLevel64x64 == 0 || quote.cLevel64x64 < minCLevel64x64) {
                l.minCLevel64x64[longTokenId] = quote.cLevel64x64;
            }
        }

        // mint long option token for buyer
        _mint(account, longTokenId, contractSize);

        int128 oldLiquidity64x64 = l.totalFreeLiquiditySupply64x64(isCall);
        // burn free liquidity tokens from other underwriters
        _mintShortTokenLoop(
            l,
            account,
            maturity,
            strike64x64,
            contractSize,
            baseCost,
            isCall,
            utilization64x64
        );
        int128 newLiquidity64x64 = l.totalFreeLiquiditySupply64x64(isCall);

        _setCLevel(
            l,
            oldLiquidity64x64,
            newLiquidity64x64,
            isCall,
            utilization64x64
        );

        // mint reserved liquidity tokens for fee receiver

        _processAvailableFunds(
            FEE_RECEIVER_ADDRESS,
            feeCost,
            isCall,
            true,
            false
        );

        emit Purchase(
            account,
            longTokenId,
            contractSize,
            baseCost,
            feeCost,
            newPrice64x64
        );
    }

    /**
     * @notice reassign short position to new underwriter
     * @param l storage layout struct
     * @param account holder of positions to be reassigned
     * @param maturity timestamp of option maturity
     * @param strike64x64 64x64 fixed point representation of strike price
     * @param isCall true for call, false for put
     * @param contractSize quantity of option contract tokens to reassign
     * @param newPrice64x64 64x64 fixed point representation of current spot price
     * @return baseCost quantity of tokens required to reassign short position
     * @return feeCost quantity of tokens required to pay fees
     * @return netCollateralFreed quantity of liquidity freed
     */
    function _reassign(
        PoolStorage.Layout storage l,
        address account,
        uint64 maturity,
        int128 strike64x64,
        bool isCall,
        uint256 contractSize,
        int128 newPrice64x64
    )
        internal
        returns (
            uint256 baseCost,
            uint256 feeCost,
            uint256 netCollateralFreed
        )
    {
        (baseCost, feeCost) = _purchase(
            l,
            account,
            maturity,
            strike64x64,
            isCall,
            contractSize,
            newPrice64x64
        );

        uint256 totalCollateralFreed = _annihilate(
            l,
            account,
            maturity,
            strike64x64,
            isCall,
            contractSize
        );

        netCollateralFreed = totalCollateralFreed - baseCost - feeCost;
    }

    /**
     * @notice exercise option on behalf of holder
     * @dev used for processing of expired options if passed holder is zero address
     * @param holder owner of long option tokens to exercise
     * @param longTokenId long option token id
     * @param contractSize quantity of tokens to exercise
     */
    function _exercise(
        address holder,
        uint256 longTokenId,
        uint256 contractSize
    ) internal {
        uint64 maturity;
        int128 strike64x64;
        bool isCall;

        bool onlyExpired = holder == address(0);

        {
            PoolStorage.TokenType tokenType;
            (tokenType, maturity, strike64x64) = PoolStorage.parseTokenId(
                longTokenId
            );
            require(
                tokenType == PoolStorage.TokenType.LONG_CALL ||
                    tokenType == PoolStorage.TokenType.LONG_PUT,
                "invalid type"
            );
            require(!onlyExpired || maturity < block.timestamp, "not expired");
            isCall = tokenType == PoolStorage.TokenType.LONG_CALL;
        }

        PoolStorage.Layout storage l = PoolStorage.layout();
        int128 utilization64x64 = l.getUtilization64x64(isCall);

        int128 spot64x64 = _update(l);

        if (maturity < block.timestamp) {
            spot64x64 = l.getPriceUpdateAfter(maturity);
        }

        require(
            onlyExpired ||
                (
                    isCall
                        ? (spot64x64 > strike64x64)
                        : (spot64x64 < strike64x64)
                ),
            "not ITM"
        );

        uint256 exerciseValue = _calculateExerciseValue(
            l,
            contractSize,
            spot64x64,
            strike64x64,
            isCall
        );

        if (onlyExpired) {
            // burn long option tokens from multiple holders
            // transfer profit to and emit Exercise event for each holder in loop

            _burnLongTokenLoop(
                contractSize,
                exerciseValue,
                longTokenId,
                isCall
            );
        } else {
            // burn long option tokens from sender

            _burnLongTokenInterval(
                holder,
                longTokenId,
                contractSize,
                exerciseValue,
                isCall
            );
        }

        // burn short option tokens from multiple underwriters

        _burnShortTokenLoop(
            l,
            maturity,
            strike64x64,
            contractSize,
            exerciseValue,
            isCall,
            false,
            utilization64x64
        );
    }

    function _calculateExerciseValue(
        PoolStorage.Layout storage l,
        uint256 contractSize,
        int128 spot64x64,
        int128 strike64x64,
        bool isCall
    ) internal view returns (uint256 exerciseValue) {
        // calculate exercise value if option is in-the-money

        if (isCall) {
            if (spot64x64 > strike64x64) {
                exerciseValue = spot64x64.sub(strike64x64).div(spot64x64).mulu(
                    contractSize
                );
            }
        } else {
            if (spot64x64 < strike64x64) {
                exerciseValue = l.contractSizeToBaseTokenAmount(
                    contractSize,
                    strike64x64.sub(spot64x64),
                    isCall
                );
            }
        }
    }

    function _mintShortTokenLoop(
        PoolStorage.Layout storage l,
        address buyer,
        uint64 maturity,
        int128 strike64x64,
        uint256 contractSize,
        uint256 premium,
        bool isCall,
        int128 utilization64x64
    ) internal {
        uint256 shortTokenId = PoolStorage.formatTokenId(
            PoolStorage.getTokenType(isCall, false),
            maturity,
            strike64x64
        );

        uint256 tokenAmount = l.contractSizeToBaseTokenAmount(
            contractSize,
            strike64x64,
            isCall
        );

        // calculate anticipated APY fee so that it may be reserved

        uint256 apyFee = _calculateApyFee(
            l,
            shortTokenId,
            tokenAmount,
            maturity
        );

        while (tokenAmount > 0) {
            address underwriter = l.liquidityQueueAscending[isCall][address(0)];

            uint256 balance = _balanceOf(
                underwriter,
                _getFreeLiquidityTokenId(isCall)
            );

            // if underwriter is in process of divestment, remove from queue

            if (!l.getReinvestmentStatus(underwriter, isCall)) {
                _burn(underwriter, _getFreeLiquidityTokenId(isCall), balance);
                _processAvailableFunds(
                    underwriter,
                    balance,
                    isCall,
                    true,
                    false
                );
                _subUserTVL(l, underwriter, isCall, balance, utilization64x64);
                continue;
            }

            // if underwriter has insufficient liquidity, remove from queue

            if (balance < l.getMinimumAmount(isCall)) {
                l.removeUnderwriter(underwriter, isCall);
                continue;
            }

            // move interval to end of queue if underwriter is buyer

            if (underwriter == buyer) {
                l.removeUnderwriter(underwriter, isCall);
                l.addUnderwriter(underwriter, isCall);
                continue;
            }

            balance -= l.pendingDepositsOf(underwriter, isCall);

            Interval memory interval;

            // amount of liquidity provided by underwriter, accounting for reinvested premium
            interval.tokenAmount =
                (balance * (tokenAmount + premium - apyFee)) /
                tokenAmount;

            // skip underwriters whose liquidity is pending deposit processing

            if (interval.tokenAmount == 0) continue;

            // truncate interval if underwriter has excess liquidity available

            if (interval.tokenAmount > tokenAmount)
                interval.tokenAmount = tokenAmount;

            // calculate derived interval variables

            interval.contractSize =
                (contractSize * interval.tokenAmount) /
                tokenAmount;
            interval.payment = (premium * interval.tokenAmount) / tokenAmount;
            interval.apyFee = (apyFee * interval.tokenAmount) / tokenAmount;

            _mintShortTokenInterval(
                l,
                underwriter,
                buyer,
                shortTokenId,
                interval,
                isCall,
                utilization64x64
            );

            tokenAmount -= interval.tokenAmount;
            contractSize -= interval.contractSize;
            premium -= interval.payment;
            apyFee -= interval.apyFee;
        }
    }

    function _mintShortTokenInterval(
        PoolStorage.Layout storage l,
        address underwriter,
        address longReceiver,
        uint256 shortTokenId,
        Interval memory interval,
        bool isCallPool,
        int128 utilization64x64
    ) internal {
        // track prepaid APY fees

        _reserveApyFee(l, underwriter, shortTokenId, interval.apyFee);

        // if payment is equal to collateral amount plus APY fee, this is a manual underwrite

        bool isManualUnderwrite = interval.payment ==
            interval.tokenAmount + interval.apyFee;

        if (!isManualUnderwrite) {
            // burn free liquidity tokens from underwriter
            _burn(
                underwriter,
                _getFreeLiquidityTokenId(isCallPool),
                interval.tokenAmount + interval.apyFee - interval.payment
            );
        }

        // mint short option tokens for underwriter
        _mint(underwriter, shortTokenId, interval.contractSize);

        _addUserTVL(
            l,
            underwriter,
            isCallPool,
            interval.payment - interval.apyFee,
            utilization64x64
        );

        emit Underwrite(
            underwriter,
            longReceiver,
            shortTokenId,
            interval.contractSize,
            isManualUnderwrite ? 0 : interval.payment,
            isManualUnderwrite
        );
    }

    function _burnLongTokenLoop(
        uint256 contractSize,
        uint256 exerciseValue,
        uint256 longTokenId,
        bool isCallPool
    ) internal {
        EnumerableSet.AddressSet storage holders = ERC1155EnumerableStorage
            .layout()
            .accountsByToken[longTokenId];

        while (contractSize > 0) {
            address longTokenHolder = holders.at(holders.length() - 1);

            uint256 intervalContractSize = _balanceOf(
                longTokenHolder,
                longTokenId
            );

            // truncate interval if holder has excess long position size

            if (intervalContractSize > contractSize)
                intervalContractSize = contractSize;

            uint256 intervalExerciseValue = (exerciseValue *
                intervalContractSize) / contractSize;

            _burnLongTokenInterval(
                longTokenHolder,
                longTokenId,
                intervalContractSize,
                intervalExerciseValue,
                isCallPool
            );

            contractSize -= intervalContractSize;
            exerciseValue -= intervalExerciseValue;
        }
    }

    function _burnLongTokenInterval(
        address holder,
        uint256 longTokenId,
        uint256 contractSize,
        uint256 exerciseValue,
        bool isCallPool
    ) internal {
        _burn(holder, longTokenId, contractSize);

        if (exerciseValue > 0) {
            _processAvailableFunds(
                holder,
                exerciseValue,
                isCallPool,
                true,
                true
            );
        }

        emit Exercise(holder, longTokenId, contractSize, exerciseValue, 0);
    }

    function _burnShortTokenLoop(
        PoolStorage.Layout storage l,
        uint64 maturity,
        int128 strike64x64,
        uint256 contractSize,
        uint256 payment,
        bool isCall,
        bool onlyBuybackLiquidity,
        int128 utilization64x64
    ) internal {
        uint256 shortTokenId = PoolStorage.formatTokenId(
            PoolStorage.getTokenType(isCall, false),
            maturity,
            strike64x64
        );

        uint256 tokenAmount = l.contractSizeToBaseTokenAmount(
            contractSize,
            strike64x64,
            isCall
        );

        // calculate unconsumed APY fee so that it may be refunded

        uint256 apyFee = _calculateApyFee(
            l,
            shortTokenId,
            tokenAmount,
            maturity
        );

        EnumerableSet.AddressSet storage underwriters = ERC1155EnumerableStorage
            .layout()
            .accountsByToken[shortTokenId];

        uint256 index = underwriters.length();

        while (contractSize > 0) {
            address underwriter = underwriters.at(--index);

            // skip underwriters who do not provide buyback liqudity, if applicable

            if (
                onlyBuybackLiquidity && !l.isBuybackEnabled[underwriter][isCall]
            ) continue;

            Interval memory interval;

            // amount of liquidity provided by underwriter
            interval.contractSize = _balanceOf(underwriter, shortTokenId);

            // truncate interval if underwriter has excess short position size

            if (interval.contractSize > contractSize)
                interval.contractSize = contractSize;

            // calculate derived interval variables

            interval.tokenAmount =
                (tokenAmount * interval.contractSize) /
                contractSize;
            interval.payment = (payment * interval.contractSize) / contractSize;
            interval.apyFee = (apyFee * interval.contractSize) / contractSize;

            _burnShortTokenInterval(
                l,
                underwriter,
                shortTokenId,
                interval,
                isCall,
                onlyBuybackLiquidity,
                utilization64x64
            );

            contractSize -= interval.contractSize;
            tokenAmount -= interval.tokenAmount;
            payment -= interval.payment;
            apyFee -= interval.apyFee;
        }
    }

    function _burnShortTokenInterval(
        PoolStorage.Layout storage l,
        address underwriter,
        uint256 shortTokenId,
        Interval memory interval,
        bool isCallPool,
        bool isSale,
        int128 utilization64x64
    ) internal {
        // track prepaid APY fees

        uint256 refundWithRebate = interval.apyFee +
            _fulfillApyFee(
                l,
                underwriter,
                shortTokenId,
                interval.contractSize,
                interval.apyFee,
                isCallPool
            );

        // burn short option tokens from underwriter
        _burn(underwriter, shortTokenId, interval.contractSize);

        bool divest = !l.getReinvestmentStatus(underwriter, isCallPool);

        _processAvailableFunds(
            underwriter,
            interval.tokenAmount - interval.payment + refundWithRebate,
            isCallPool,
            divest,
            false
        );

        if (divest) {
            _subUserTVL(
                l,
                underwriter,
                isCallPool,
                interval.tokenAmount,
                utilization64x64
            );
        } else {
            if (refundWithRebate > interval.payment) {
                _addUserTVL(
                    l,
                    underwriter,
                    isCallPool,
                    refundWithRebate - interval.payment,
                    utilization64x64
                );
            } else if (interval.payment > refundWithRebate) {
                _subUserTVL(
                    l,
                    underwriter,
                    isCallPool,
                    interval.payment - refundWithRebate,
                    utilization64x64
                );
            }
        }

        if (isSale) {
            emit AssignSale(
                underwriter,
                shortTokenId,
                interval.tokenAmount - interval.payment,
                interval.contractSize
            );
        } else {
            emit AssignExercise(
                underwriter,
                shortTokenId,
                interval.tokenAmount - interval.payment,
                interval.contractSize,
                0
            );
        }
    }

    function _calculateApyFee(
        PoolStorage.Layout storage l,
        uint256 shortTokenId,
        uint256 tokenAmount,
        uint64 maturity
    ) internal view returns (uint256 apyFee) {
        if (block.timestamp < maturity) {
            int128 apyFeeRate64x64 = _totalSupply(shortTokenId) == 0
                ? l.getFeeApy64x64()
                : l.feeReserveRates[shortTokenId];

            apyFee = apyFeeRate64x64.mulu(
                (tokenAmount * (maturity - block.timestamp)) / (365 days)
            );
        }
    }

    function _reserveApyFee(
        PoolStorage.Layout storage l,
        address underwriter,
        uint256 shortTokenId,
        uint256 amount
    ) internal {
        l.feesReserved[underwriter][shortTokenId] += amount;

        emit APYFeeReserved(underwriter, shortTokenId, amount);
    }

    /**
     * @notice credit fee receiver with fees earned and calculate rebate for underwriter
     * @dev short tokens which have acrrued fee must not be burned or transferred until after this helper is called
     * @param l storage layout struct
     * @param underwriter holder of short position who reserved fees
     * @param shortTokenId short token id whose reserved fees to pay and rebate
     * @param intervalContractSize size of position for which to calculate accrued fees
     * @param intervalApyFee quantity of fees reserved but not yet accrued
     * @param isCallPool true for call, false for put
     */
    function _fulfillApyFee(
        PoolStorage.Layout storage l,
        address underwriter,
        uint256 shortTokenId,
        uint256 intervalContractSize,
        uint256 intervalApyFee,
        bool isCallPool
    ) internal returns (uint256 rebate) {
        // calculate proportion of fees reserved corresponding to interval

        uint256 feesReserved = l.feesReserved[underwriter][shortTokenId];

        uint256 intervalFeesReserved = (feesReserved * intervalContractSize) /
            _balanceOf(underwriter, shortTokenId);

        // deduct fees for time not elapsed

        l.feesReserved[underwriter][shortTokenId] -= intervalFeesReserved;

        // apply rebate to fees accrued

        rebate = _fetchFeeDiscount64x64(underwriter).mulu(
            intervalFeesReserved - intervalApyFee
        );

        // credit fee receiver with fees paid

        uint256 intervalFeesPaid = intervalFeesReserved -
            intervalApyFee -
            rebate;

        _processAvailableFunds(
            FEE_RECEIVER_ADDRESS,
            intervalFeesPaid,
            isCallPool,
            true,
            false
        );

        emit APYFeePaid(underwriter, shortTokenId, intervalFeesPaid);
    }

    function _addToDepositQueue(
        address account,
        uint256 amount,
        bool isCallPool
    ) internal {
        PoolStorage.Layout storage l = PoolStorage.layout();

        uint256 freeLiqTokenId = _getFreeLiquidityTokenId(isCallPool);

        if (_totalSupply(freeLiqTokenId) > 0) {
            uint256 nextBatch = (block.timestamp / BATCHING_PERIOD) *
                BATCHING_PERIOD +
                BATCHING_PERIOD;
            l.pendingDeposits[account][nextBatch][isCallPool] += amount;

            PoolStorage.BatchData storage batchData = l.nextDeposits[
                isCallPool
            ];
            batchData.totalPendingDeposits += amount;
            batchData.eta = nextBatch;
        }

        _mint(account, freeLiqTokenId, amount);
    }

    function _processPendingDeposits(PoolStorage.Layout storage l, bool isCall)
        internal
    {
        PoolStorage.BatchData storage batchData = l.nextDeposits[isCall];

        if (batchData.eta == 0 || block.timestamp < batchData.eta) return;

        int128 oldLiquidity64x64 = l.totalFreeLiquiditySupply64x64(isCall);

        _setCLevel(
            l,
            oldLiquidity64x64,
            oldLiquidity64x64.add(
                ABDKMath64x64Token.fromDecimals(
                    batchData.totalPendingDeposits,
                    l.getTokenDecimals(isCall)
                )
            ),
            isCall,
            l.getUtilization64x64(isCall)
        );

        delete l.nextDeposits[isCall];
    }

    function _getFreeLiquidityTokenId(bool isCall)
        internal
        view
        returns (uint256 freeLiqTokenId)
    {
        freeLiqTokenId = isCall
            ? UNDERLYING_FREE_LIQ_TOKEN_ID
            : BASE_FREE_LIQ_TOKEN_ID;
    }

    function _getReservedLiquidityTokenId(bool isCall)
        internal
        view
        returns (uint256 reservedLiqTokenId)
    {
        reservedLiqTokenId = isCall
            ? UNDERLYING_RESERVED_LIQ_TOKEN_ID
            : BASE_RESERVED_LIQ_TOKEN_ID;
    }

    function _setCLevel(
        PoolStorage.Layout storage l,
        int128 oldLiquidity64x64,
        int128 newLiquidity64x64,
        bool isCallPool,
        int128 utilization64x64
    ) internal {
        int128 oldCLevel64x64 = l.getDecayAdjustedCLevel64x64(
            isCallPool,
            utilization64x64
        );

        int128 cLevel64x64 = l.applyCLevelLiquidityChangeAdjustment(
            oldCLevel64x64,
            oldLiquidity64x64,
            newLiquidity64x64,
            isCallPool
        );

        l.setCLevel(cLevel64x64, isCallPool);

        emit UpdateCLevel(
            isCallPool,
            cLevel64x64,
            oldLiquidity64x64,
            newLiquidity64x64
        );
    }

    /**
     * @notice calculate and store updated market state
     * @param l storage layout struct
     * @return newPrice64x64 64x64 fixed point representation of current spot price
     */
    function _update(PoolStorage.Layout storage l)
        internal
        returns (int128 newPrice64x64)
    {
        if (l.updatedAt == block.timestamp) {
            return (l.getPriceUpdate(block.timestamp));
        }

        newPrice64x64 = l.fetchPriceUpdate();

        if (l.getPriceUpdate(block.timestamp) == 0) {
            l.setPriceUpdate(block.timestamp, newPrice64x64);
        }

        l.updatedAt = block.timestamp;

        _processPendingDeposits(l, true);
        _processPendingDeposits(l, false);
    }

    /**
     * @notice transfer ERC20 tokens to message sender
     * @param token ERC20 token address
     * @param amount quantity of token to transfer
     */
    function _pushTo(
        address to,
        address token,
        uint256 amount
    ) internal {
        if (amount == 0) return;

        require(IERC20(token).transfer(to, amount), "ERC20 transfer failed");
    }

    /**
     * @notice transfer ERC20 tokens from message sender
     * @param l storage layout struct
     * @param from address from which tokens are pulled from
     * @param amount quantity of token to transfer
     * @param isCallPool whether funds correspond to call or put pool
     * @param creditMessageValue whether to attempt to treat message value as credit
     */
    function _pullFrom(
        PoolStorage.Layout storage l,
        address from,
        uint256 amount,
        bool isCallPool,
        bool creditMessageValue
    ) internal {
        uint256 credit;

        if (creditMessageValue) {
            credit = _creditMessageValue(amount, isCallPool);
        }

        if (amount > credit) {
            credit += _creditReservedLiquidity(
                from,
                amount - credit,
                isCallPool
            );
        }

        if (amount > credit) {
            require(
                IERC20(l.getPoolToken(isCallPool)).transferFrom(
                    from,
                    address(this),
                    amount - credit
                ),
                "ERC20 transfer failed"
            );
        }
    }

    /**
     * @notice transfer or reinvest available user funds
     * @param account owner of funds
     * @param amount quantity of funds available
     * @param isCallPool whether funds correspond to call or put pool
     * @param divest whether to reserve funds or reinvest
     * @param transferOnDivest whether to transfer divested funds to owner
     */
    function _processAvailableFunds(
        address account,
        uint256 amount,
        bool isCallPool,
        bool divest,
        bool transferOnDivest
    ) internal {
        if (divest) {
            if (transferOnDivest) {
                _pushTo(
                    account,
                    PoolStorage.layout().getPoolToken(isCallPool),
                    amount
                );
            } else {
                _mint(
                    account,
                    _getReservedLiquidityTokenId(isCallPool),
                    amount
                );
            }
        } else {
            _addToDepositQueue(account, amount, isCallPool);
        }
    }

    /**
     * @notice validate that pool accepts ether deposits and calculate credit amount from message value
     * @param amount total deposit quantity
     * @param isCallPool whether to deposit underlying in the call pool or base in the put pool
     * @return credit quantity of credit to apply
     */
    function _creditMessageValue(uint256 amount, bool isCallPool)
        internal
        returns (uint256 credit)
    {
        if (msg.value > 0) {
            require(
                PoolStorage.layout().getPoolToken(isCallPool) ==
                    WRAPPED_NATIVE_TOKEN,
                "not WETH deposit"
            );

            if (msg.value > amount) {
                unchecked {
                    (bool success, ) = payable(msg.sender).call{
                        value: msg.value - amount
                    }("");

                    require(success, "ETH refund failed");

                    credit = amount;
                }
            } else {
                credit = msg.value;
            }

            IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: credit}();
        }
    }

    /**
     * @notice calculate credit amount from reserved liquidity
     * @param account address whose reserved liquidity to use as credit
     * @param amount total deposit quantity
     * @param isCallPool whether to deposit underlying in the call pool or base in the put pool
     * @return credit quantity of credit to apply
     */
    function _creditReservedLiquidity(
        address account,
        uint256 amount,
        bool isCallPool
    ) internal returns (uint256 credit) {
        uint256 reservedLiqTokenId = _getReservedLiquidityTokenId(isCallPool);

        uint256 balance = _balanceOf(account, reservedLiqTokenId);

        if (balance > 0) {
            credit = balance > amount ? amount : balance;

            _burn(account, reservedLiqTokenId, credit);
        }
    }

    /*
     * @notice mint ERC1155 token without pasing data payload or calling safe transfer acceptance check
     * @param account recipient of minted tokens
     * @param tokenId id of token to mint
     * @param amount quantity of tokens to mint
     */
    function _mint(
        address account,
        uint256 tokenId,
        uint256 amount
    ) internal {
        _mint(account, tokenId, amount, "");
    }

    function _addUserTVL(
        PoolStorage.Layout storage l,
        address user,
        bool isCallPool,
        uint256 amount,
        int128 utilization64x64
    ) internal {
        uint256 userTVL = l.userTVL[user][isCallPool];
        uint256 totalTVL = l.totalTVL[isCallPool];

        IPremiaMining(PREMIA_MINING_ADDRESS).allocatePending(
            user,
            address(this),
            isCallPool,
            userTVL,
            userTVL + amount,
            totalTVL,
            ABDKMath64x64Token.toDecimals(utilization64x64, 4)
        );

        l.userTVL[user][isCallPool] = userTVL + amount;
        l.totalTVL[isCallPool] = totalTVL + amount;
    }

    function _subUserTVL(
        PoolStorage.Layout storage l,
        address user,
        bool isCallPool,
        uint256 amount,
        int128 utilization64x64
    ) internal {
        uint256 userTVL = l.userTVL[user][isCallPool];
        uint256 totalTVL = l.totalTVL[isCallPool];

        uint256 newUserTVL;
        uint256 newTotalTVL;

        if (userTVL < amount) {
            amount = userTVL;
        }

        newUserTVL = userTVL - amount;
        newTotalTVL = totalTVL - amount;

        IPremiaMining(PREMIA_MINING_ADDRESS).allocatePending(
            user,
            address(this),
            isCallPool,
            userTVL,
            newUserTVL,
            totalTVL,
            ABDKMath64x64Token.toDecimals(utilization64x64, 4)
        );

        l.userTVL[user][isCallPool] = newUserTVL;
        l.totalTVL[isCallPool] = newTotalTVL;
    }

    function _transferUserTVL(
        PoolStorage.Layout storage l,
        address from,
        address to,
        bool isCallPool,
        uint256 amount,
        int128 utilization64x64
    ) internal {
        uint256 fromTVL = l.userTVL[from][isCallPool];
        uint256 toTVL = l.userTVL[to][isCallPool];
        uint256 totalTVL = l.totalTVL[isCallPool];

        uint256 newFromTVL;
        if (fromTVL > amount) {
            newFromTVL = fromTVL - amount;
        }

        uint256 newToTVL = toTVL + amount;

        IPremiaMining(PREMIA_MINING_ADDRESS).allocatePending(
            from,
            address(this),
            isCallPool,
            fromTVL,
            newFromTVL,
            totalTVL,
            ABDKMath64x64Token.toDecimals(utilization64x64, 4)
        );

        IPremiaMining(PREMIA_MINING_ADDRESS).allocatePending(
            to,
            address(this),
            isCallPool,
            toTVL,
            newToTVL,
            totalTVL,
            ABDKMath64x64Token.toDecimals(utilization64x64, 4)
        );

        l.userTVL[from][isCallPool] = newFromTVL;
        l.userTVL[to][isCallPool] = newToTVL;
    }

    /**
     * @dev pull token from user, send to exchangeHelper and trigger a trade from exchangeHelper
     * @param s swap arguments
     * @param tokenOut token to swap for. should always equal to the pool token.
     * @return amountCredited amount of tokenOut we got from the trade.
     */
    function _swapForPoolTokens(
        IPoolInternal.SwapArgs memory s,
        address tokenOut
    ) internal returns (uint256 amountCredited) {
        if (msg.value > 0) {
            require(s.tokenIn == WRAPPED_NATIVE_TOKEN, "wrong tokenIn");
            IWETH(WRAPPED_NATIVE_TOKEN).deposit{value: msg.value}();
            IWETH(WRAPPED_NATIVE_TOKEN).transfer(EXCHANGE_HELPER, msg.value);
        }
        if (s.amountInMax > 0) {
            IERC20(s.tokenIn).safeTransferFrom(
                msg.sender,
                EXCHANGE_HELPER,
                s.amountInMax
            );
        }

        amountCredited = IExchangeHelper(EXCHANGE_HELPER).swapWithToken(
            s.tokenIn,
            tokenOut,
            s.amountInMax + msg.value,
            s.callee,
            s.allowanceTarget,
            s.data,
            s.refundAddress
        );
        require(
            amountCredited >= s.amountOutMin,
            "not enough output from trade"
        );
    }

    /**
     * @notice ERC1155 hook: track eligible underwriters
     * @param operator transaction sender
     * @param from token sender
     * @param to token receiver
     * @param ids token ids transferred
     * @param amounts token quantities transferred
     * @param data data payload
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);

        PoolStorage.Layout storage l = PoolStorage.layout();

        for (uint256 i; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            if (amount == 0) continue;

            if (from == address(0)) {
                l.tokenIds.add(id);
            }

            if (to == address(0) && _totalSupply(id) == 0) {
                l.tokenIds.remove(id);
            }

            // prevent transfer of free and reserved liquidity during waiting period

            if (
                id == UNDERLYING_FREE_LIQ_TOKEN_ID ||
                id == BASE_FREE_LIQ_TOKEN_ID ||
                id == UNDERLYING_RESERVED_LIQ_TOKEN_ID ||
                id == BASE_RESERVED_LIQ_TOKEN_ID
            ) {
                if (from != address(0) && to != address(0)) {
                    bool isCallPool = id == UNDERLYING_FREE_LIQ_TOKEN_ID ||
                        id == UNDERLYING_RESERVED_LIQ_TOKEN_ID;

                    require(
                        l.depositedAt[from][isCallPool] + (1 days) <
                            block.timestamp,
                        "liq lock 1d"
                    );
                }
            }

            if (
                id == UNDERLYING_FREE_LIQ_TOKEN_ID ||
                id == BASE_FREE_LIQ_TOKEN_ID
            ) {
                bool isCallPool = id == UNDERLYING_FREE_LIQ_TOKEN_ID;
                uint256 minimum = l.getMinimumAmount(isCallPool);

                if (from != address(0)) {
                    uint256 balance = _balanceOf(from, id);

                    if (balance > minimum && balance <= amount + minimum) {
                        require(
                            balance - l.pendingDepositsOf(from, isCallPool) >=
                                amount,
                            "Insuf balance"
                        );
                        l.removeUnderwriter(from, isCallPool);
                    }

                    if (to != address(0)) {
                        _transferUserTVL(
                            l,
                            from,
                            to,
                            isCallPool,
                            amount,
                            l.getUtilization64x64(isCallPool)
                        );
                    }
                }

                if (to != address(0)) {
                    uint256 balance = _balanceOf(to, id);

                    if (balance <= minimum && balance + amount >= minimum) {
                        l.addUnderwriter(to, isCallPool);
                    }
                }
            }

            // Update userTVL on SHORT options transfers
            (PoolStorage.TokenType tokenType, , ) = PoolStorage.parseTokenId(
                id
            );

            if (
                tokenType == PoolStorage.TokenType.SHORT_CALL ||
                tokenType == PoolStorage.TokenType.SHORT_PUT
            ) {
                int128 utilization64x64 = l.getUtilization64x64(
                    tokenType == PoolStorage.TokenType.SHORT_CALL
                );
                _beforeShortTokenTransfer(
                    l,
                    from,
                    to,
                    id,
                    amount,
                    utilization64x64
                );
            }
        }
    }

    function _beforeShortTokenTransfer(
        PoolStorage.Layout storage l,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        int128 utilization64x64
    ) private {
        // total supply has already been updated, so compare to amount rather than 0
        if (from == address(0) && _totalSupply(id) == amount) {
            l.feeReserveRates[id] = l.getFeeApy64x64();
        }

        if (to == address(0) && _totalSupply(id) == 0) {
            delete l.feeReserveRates[id];
        }

        if (from != address(0) && to != address(0)) {
            bool isCall;
            uint256 collateral;
            uint256 intervalApyFee;

            {
                (
                    PoolStorage.TokenType tokenType,
                    uint64 maturity,
                    int128 strike64x64
                ) = PoolStorage.parseTokenId(id);

                isCall = tokenType == PoolStorage.TokenType.SHORT_CALL;
                collateral = l.contractSizeToBaseTokenAmount(
                    amount,
                    strike64x64,
                    isCall
                );

                intervalApyFee = _calculateApyFee(l, id, collateral, maturity);
            }

            uint256 rebate = _fulfillApyFee(
                l,
                from,
                id,
                amount,
                intervalApyFee,
                isCall
            );

            _reserveApyFee(l, to, id, intervalApyFee);

            bool divest = !l.getReinvestmentStatus(from, isCall);

            if (rebate > 0) {
                _processAvailableFunds(from, rebate, isCall, divest, false);
            }

            _subUserTVL(
                l,
                from,
                isCall,
                divest ? collateral : collateral - rebate,
                utilization64x64
            );

            _addUserTVL(l, to, isCall, collateral, utilization64x64);
        }
    }
}

// SPDX-License-Identifier: BUSL-1.1
// For further clarification please see https://license.premia.legal

pragma solidity ^0.8.0;

import {ABDKMath64x64} from "abdk-libraries-solidity/ABDKMath64x64.sol";

import {OptionMath} from "../libraries/OptionMath.sol";
import {IPoolSettings} from "./IPoolSettings.sol";
import {PoolInternal} from "./PoolInternal.sol";
import {PoolStorage} from "./PoolStorage.sol";

/**
 * @title Premia option pool
 * @dev deployed standalone and referenced by PoolProxy
 */
contract PoolSettings is IPoolSettings, PoolInternal {
    using PoolStorage for PoolStorage.Layout;
    using ABDKMath64x64 for int128;

    struct APYFeeData {
        address underwriter;
        uint256 shortTokenId;
        bool isCallPool;
        int128 feeDiscount64x64;
        bool divest;
    }

    constructor(
        address ivolOracle,
        address wrappedNativeToken,
        address premiaMining,
        address feeReceiver,
        address feeDiscountAddress,
        int128 feePremium64x64,
        address exchangeHelper
    )
        PoolInternal(
            ivolOracle,
            wrappedNativeToken,
            premiaMining,
            feeReceiver,
            feeDiscountAddress,
            feePremium64x64,
            exchangeHelper
        )
    {}

    function processApyFees(APYFeeData[] calldata apyFeeData)
        external
        onlyProtocolOwner
    {
        unchecked {
            PoolStorage.Layout storage l = PoolStorage.layout();

            uint256 callFeesPaid;
            uint256 putFeesPaid;

            for (uint256 i; i < apyFeeData.length; i++) {
                APYFeeData memory data = apyFeeData[i];

                address underwriter = data.underwriter;
                uint256 shortTokenId = data.shortTokenId;
                bool isCallPool = data.isCallPool;

                uint256 feesReserved = l.feesReserved[underwriter][
                    shortTokenId
                ];
                delete l.feesReserved[underwriter][shortTokenId];

                uint256 rebate = data.feeDiscount64x64.mulu(feesReserved);
                uint256 feesPaid = feesReserved - rebate;

                _processAvailableFunds(
                    underwriter,
                    rebate,
                    isCallPool,
                    data.divest,
                    false
                );

                if (isCallPool) {
                    callFeesPaid += feesPaid;
                } else {
                    putFeesPaid += feesPaid;
                }

                emit APYFeePaid(underwriter, shortTokenId, feesPaid);
            }

            _processAvailableFunds(
                FEE_RECEIVER_ADDRESS,
                callFeesPaid,
                true,
                true,
                false
            );

            _processAvailableFunds(
                FEE_RECEIVER_ADDRESS,
                putFeesPaid,
                false,
                true,
                false
            );
        }
    }

    /**
     * @inheritdoc IPoolSettings
     */
    function setMinimumAmounts(uint256 baseMinimum, uint256 underlyingMinimum)
        external
        onlyProtocolOwner
    {
        PoolStorage.Layout storage l = PoolStorage.layout();
        l.baseMinimum = baseMinimum;
        l.underlyingMinimum = underlyingMinimum;
    }

    /**
     * @inheritdoc IPoolSettings
     */
    function setSteepness64x64(int128 steepness64x64, bool isCallPool)
        external
        onlyProtocolOwner
    {
        if (isCallPool) {
            PoolStorage.layout().steepnessUnderlying64x64 = steepness64x64;
        } else {
            PoolStorage.layout().steepnessBase64x64 = steepness64x64;
        }

        emit UpdateSteepness(steepness64x64, isCallPool);
    }

    /**
     * @inheritdoc IPoolSettings
     */
    function setCLevel64x64(int128 cLevel64x64, bool isCallPool)
        external
        onlyProtocolOwner
    {
        PoolStorage.Layout storage l = PoolStorage.layout();

        l.setCLevel(cLevel64x64, isCallPool);

        int128 liquidity64x64 = l.totalFreeLiquiditySupply64x64(isCallPool);

        emit UpdateCLevel(
            isCallPool,
            cLevel64x64,
            liquidity64x64,
            liquidity64x64
        );
    }

    /**
     * @inheritdoc IPoolSettings
     */
    function setFeeApy64x64(int128 feeApy64x64) external onlyProtocolOwner {
        PoolStorage.layout().feeApy64x64 = feeApy64x64;
    }

    /**
     * @inheritdoc IPoolSettings
     */
    function setSpotOffset64x64(int128 spotOffset64x64)
        external
        onlyProtocolOwner
    {
        require(spotOffset64x64 >= 0, "too low");
        require(spotOffset64x64 < OptionMath.ONE_64x64, "too high");
        PoolStorage.layout().spotOffset64x64 = spotOffset64x64;

        emit UpdateSpotOffset(spotOffset64x64);
    }
}

// SPDX-License-Identifier: BUSL-1.1
// For further clarification please see https://license.premia.legal

pragma solidity ^0.8.0;

import {AggregatorInterface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorInterface.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {ABDKMath64x64Token} from "@solidstate/abdk-math-extensions/contracts/ABDKMath64x64Token.sol";
import {EnumerableSet, ERC1155EnumerableStorage} from "@solidstate/contracts/token/ERC1155/enumerable/ERC1155EnumerableStorage.sol";
import {ABDKMath64x64} from "abdk-libraries-solidity/ABDKMath64x64.sol";

import {OptionMath} from "../libraries/OptionMath.sol";

library PoolStorage {
    using ABDKMath64x64 for int128;
    using PoolStorage for PoolStorage.Layout;

    enum TokenType {
        UNDERLYING_FREE_LIQ,
        BASE_FREE_LIQ,
        UNDERLYING_RESERVED_LIQ,
        BASE_RESERVED_LIQ,
        LONG_CALL,
        SHORT_CALL,
        LONG_PUT,
        SHORT_PUT
    }

    struct PoolSettings {
        address underlying;
        address base;
        address underlyingOracle;
        address baseOracle;
    }

    struct QuoteArgsInternal {
        address feePayer; // address of the fee payer
        uint64 maturity; // timestamp of option maturity
        int128 strike64x64; // 64x64 fixed point representation of strike price
        int128 spot64x64; // 64x64 fixed point representation of spot price
        uint256 contractSize; // size of option contract
        bool isCall; // true for call, false for put
    }

    struct QuoteResultInternal {
        int128 baseCost64x64; // 64x64 fixed point representation of option cost denominated in underlying currency (without fee)
        int128 feeCost64x64; // 64x64 fixed point representation of option fee cost denominated in underlying currency for call, or base currency for put
        int128 cLevel64x64; // 64x64 fixed point representation of C-Level of Pool after purchase
        int128 slippageCoefficient64x64; // 64x64 fixed point representation of slippage coefficient for given order size
    }

    struct BatchData {
        uint256 eta;
        uint256 totalPendingDeposits;
    }

    bytes32 internal constant STORAGE_SLOT =
        keccak256("premia.contracts.storage.Pool");

    uint256 private constant C_DECAY_BUFFER = 12 hours;
    uint256 private constant C_DECAY_INTERVAL = 4 hours;

    int128 internal constant ONE_64x64 = 0x10000000000000000;

    struct Layout {
        // ERC20 token addresses
        address base;
        address underlying;
        // AggregatorV3Interface oracle addresses
        address baseOracle;
        address underlyingOracle;
        // token metadata
        uint8 underlyingDecimals;
        uint8 baseDecimals;
        // minimum amounts
        uint256 baseMinimum;
        uint256 underlyingMinimum;
        // deposit caps
        uint256 _deprecated_basePoolCap;
        uint256 _deprecated_underlyingPoolCap;
        // market state
        int128 _deprecated_steepness64x64;
        int128 cLevelBase64x64;
        int128 cLevelUnderlying64x64;
        uint256 cLevelBaseUpdatedAt;
        uint256 cLevelUnderlyingUpdatedAt;
        uint256 updatedAt;
        // User -> isCall -> depositedAt
        mapping(address => mapping(bool => uint256)) depositedAt;
        mapping(address => mapping(bool => uint256)) divestmentTimestamps;
        // doubly linked list of free liquidity intervals
        // isCall -> User -> User
        mapping(bool => mapping(address => address)) liquidityQueueAscending;
        mapping(bool => mapping(address => address)) liquidityQueueDescending;
        // minimum resolution price bucket => price
        mapping(uint256 => int128) bucketPrices64x64;
        // sequence id (minimum resolution price bucket / 256) => price update sequence
        mapping(uint256 => uint256) priceUpdateSequences;
        // isCall -> batch data
        mapping(bool => BatchData) nextDeposits;
        // user -> batch timestamp -> isCall -> pending amount
        mapping(address => mapping(uint256 => mapping(bool => uint256))) pendingDeposits;
        EnumerableSet.UintSet tokenIds;
        // user -> isCallPool -> total value locked of user (Used for liquidity mining)
        mapping(address => mapping(bool => uint256)) userTVL;
        // isCallPool -> total value locked
        mapping(bool => uint256) totalTVL;
        // steepness values
        int128 steepnessBase64x64;
        int128 steepnessUnderlying64x64;
        // User -> isCallPool -> isBuybackEnabled
        mapping(address => mapping(bool => bool)) isBuybackEnabled;
        // LongTokenId -> minC
        mapping(uint256 => int128) minCLevel64x64;
        // APY fee tracking
        // underwriter -> shortTokenId -> amount
        mapping(address => mapping(uint256 => uint256)) feesReserved;
        // shortTokenId -> 64x64 fixed point representation of apy fee
        mapping(uint256 => int128) feeReserveRates;
        // APY fee paid by underwriters
        // Also used along with multiplier to calculate minimum option price as APY
        int128 feeApy64x64;
        // adjustment applied to spot price for puchase calculations
        int128 spotOffset64x64;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }

    /**
     * @notice calculate ERC1155 token id for given option parameters
     * @param tokenType TokenType enum
     * @param maturity timestamp of option maturity
     * @param strike64x64 64x64 fixed point representation of strike price
     * @return tokenId token id
     */
    function formatTokenId(
        TokenType tokenType,
        uint64 maturity,
        int128 strike64x64
    ) internal pure returns (uint256 tokenId) {
        tokenId =
            (uint256(tokenType) << 248) +
            (uint256(maturity) << 128) +
            uint256(int256(strike64x64));
    }

    /**
     * @notice derive option maturity and strike price from ERC1155 token id
     * @param tokenId token id
     * @return tokenType TokenType enum
     * @return maturity timestamp of option maturity
     * @return strike64x64 option strike price
     */
    function parseTokenId(uint256 tokenId)
        internal
        pure
        returns (
            TokenType tokenType,
            uint64 maturity,
            int128 strike64x64
        )
    {
        assembly {
            tokenType := shr(248, tokenId)
            maturity := shr(128, tokenId)
            strike64x64 := tokenId
        }
    }

    function getTokenType(bool isCall, bool isLong)
        internal
        pure
        returns (TokenType tokenType)
    {
        if (isCall) {
            tokenType = isLong ? TokenType.LONG_CALL : TokenType.SHORT_CALL;
        } else {
            tokenType = isLong ? TokenType.LONG_PUT : TokenType.SHORT_PUT;
        }
    }

    function getPoolToken(Layout storage l, bool isCall)
        internal
        view
        returns (address token)
    {
        token = isCall ? l.underlying : l.base;
    }

    function getTokenDecimals(Layout storage l, bool isCall)
        internal
        view
        returns (uint8 decimals)
    {
        decimals = isCall ? l.underlyingDecimals : l.baseDecimals;
    }

    function getMinimumAmount(Layout storage l, bool isCall)
        internal
        view
        returns (uint256 minimumAmount)
    {
        minimumAmount = isCall ? l.underlyingMinimum : l.baseMinimum;
    }

    /**
     * @notice get the total supply of free liquidity tokens, minus pending deposits
     * @param l storage layout struct
     * @param isCall whether query is for call or put pool
     * @return 64x64 fixed point representation of total free liquidity
     */
    function totalFreeLiquiditySupply64x64(Layout storage l, bool isCall)
        internal
        view
        returns (int128)
    {
        uint256 tokenId = formatTokenId(
            isCall ? TokenType.UNDERLYING_FREE_LIQ : TokenType.BASE_FREE_LIQ,
            0,
            0
        );

        return
            ABDKMath64x64Token.fromDecimals(
                ERC1155EnumerableStorage.layout().totalSupply[tokenId] -
                    l.totalPendingDeposits(isCall),
                l.getTokenDecimals(isCall)
            );
    }

    function getReinvestmentStatus(
        Layout storage l,
        address account,
        bool isCallPool
    ) internal view returns (bool) {
        uint256 timestamp = l.divestmentTimestamps[account][isCallPool];
        return timestamp == 0 || timestamp > block.timestamp;
    }

    function getFeeApy64x64(Layout storage l)
        internal
        view
        returns (int128 feeApy64x64)
    {
        feeApy64x64 = l.feeApy64x64;

        if (feeApy64x64 == 0) {
            // if APY fee is not set, set to 0.025
            feeApy64x64 = 0x666666666666666;
        }
    }

    function getMinApy64x64(Layout storage l)
        internal
        view
        returns (int128 feeApy64x64)
    {
        feeApy64x64 = l.getFeeApy64x64() << 3;
    }

    function addUnderwriter(
        Layout storage l,
        address account,
        bool isCallPool
    ) internal {
        require(account != address(0));

        mapping(address => address) storage asc = l.liquidityQueueAscending[
            isCallPool
        ];
        mapping(address => address) storage desc = l.liquidityQueueDescending[
            isCallPool
        ];

        if (_isInQueue(account, asc, desc)) return;

        address last = desc[address(0)];

        asc[last] = account;
        desc[account] = last;
        desc[address(0)] = account;
    }

    function removeUnderwriter(
        Layout storage l,
        address account,
        bool isCallPool
    ) internal {
        require(account != address(0));

        mapping(address => address) storage asc = l.liquidityQueueAscending[
            isCallPool
        ];
        mapping(address => address) storage desc = l.liquidityQueueDescending[
            isCallPool
        ];

        if (!_isInQueue(account, asc, desc)) return;

        address prev = desc[account];
        address next = asc[account];
        asc[prev] = next;
        desc[next] = prev;
        delete asc[account];
        delete desc[account];
    }

    function isInQueue(
        Layout storage l,
        address account,
        bool isCallPool
    ) internal view returns (bool) {
        mapping(address => address) storage asc = l.liquidityQueueAscending[
            isCallPool
        ];
        mapping(address => address) storage desc = l.liquidityQueueDescending[
            isCallPool
        ];

        return _isInQueue(account, asc, desc);
    }

    function _isInQueue(
        address account,
        mapping(address => address) storage asc,
        mapping(address => address) storage desc
    ) private view returns (bool) {
        return asc[account] != address(0) || desc[address(0)] == account;
    }

    /**
     * @notice get current C-Level, without accounting for pending adjustments
     * @param l storage layout struct
     * @param isCall whether query is for call or put pool
     * @return cLevel64x64 64x64 fixed point representation of C-Level
     */
    function getRawCLevel64x64(Layout storage l, bool isCall)
        internal
        view
        returns (int128 cLevel64x64)
    {
        cLevel64x64 = isCall ? l.cLevelUnderlying64x64 : l.cLevelBase64x64;
    }

    /**
     * @notice get current C-Level, accounting for unrealized decay
     * @param l storage layout struct
     * @param isCall whether query is for call or put pool
     * @param utilization64x64 utilization of the pool
     * @return cLevel64x64 64x64 fixed point representation of C-Level
     */
    function getDecayAdjustedCLevel64x64(
        Layout storage l,
        bool isCall,
        int128 utilization64x64
    ) internal view returns (int128 cLevel64x64) {
        // get raw C-Level from storage
        cLevel64x64 = l.getRawCLevel64x64(isCall);

        // account for C-Level decay
        cLevel64x64 = l.applyCLevelDecayAdjustment(
            cLevel64x64,
            isCall,
            utilization64x64
        );
    }

    /**
     * @notice get updated C-Level and pool liquidity level, accounting for decay and pending deposits
     * @param l storage layout struct
     * @param isCall whether to update C-Level for call or put pool
     * @return cLevel64x64 64x64 fixed point representation of C-Level
     * @return liquidity64x64 64x64 fixed point representation of new liquidity amount
     */
    function getRealPoolState(Layout storage l, bool isCall)
        internal
        view
        returns (int128 cLevel64x64, int128 liquidity64x64)
    {
        PoolStorage.BatchData storage batchData = l.nextDeposits[isCall];

        int128 oldCLevel64x64 = l.getDecayAdjustedCLevel64x64(
            isCall,
            l.getUtilization64x64(isCall)
        );
        int128 oldLiquidity64x64 = l.totalFreeLiquiditySupply64x64(isCall);

        if (
            batchData.totalPendingDeposits > 0 &&
            batchData.eta != 0 &&
            block.timestamp >= batchData.eta
        ) {
            liquidity64x64 = ABDKMath64x64Token
                .fromDecimals(
                    batchData.totalPendingDeposits,
                    l.getTokenDecimals(isCall)
                )
                .add(oldLiquidity64x64);

            cLevel64x64 = l.applyCLevelLiquidityChangeAdjustment(
                oldCLevel64x64,
                oldLiquidity64x64,
                liquidity64x64,
                isCall
            );
        } else {
            cLevel64x64 = oldCLevel64x64;
            liquidity64x64 = oldLiquidity64x64;
        }
    }

    /**
     * @notice calculate updated C-Level, accounting for unrealized decay
     * @param l storage layout struct
     * @param oldCLevel64x64 64x64 fixed point representation pool C-Level before accounting for decay
     * @param isCall whether query is for call or put pool
     * @return cLevel64x64 64x64 fixed point representation of C-Level of Pool after accounting for decay
     */
    function applyCLevelDecayAdjustment(
        Layout storage l,
        int128 oldCLevel64x64,
        bool isCall,
        int128 utilization64x64
    ) internal view returns (int128 cLevel64x64) {
        uint256 timeElapsed = block.timestamp -
            (isCall ? l.cLevelUnderlyingUpdatedAt : l.cLevelBaseUpdatedAt);

        // do not apply C decay if less than 24 hours have elapsed

        if (timeElapsed > C_DECAY_BUFFER) {
            timeElapsed -= C_DECAY_BUFFER;
        } else {
            return oldCLevel64x64;
        }

        int128 timeIntervalsElapsed64x64 = ABDKMath64x64.divu(
            timeElapsed,
            C_DECAY_INTERVAL
        );

        return
            OptionMath.calculateCLevelDecay(
                OptionMath.CalculateCLevelDecayArgs(
                    timeIntervalsElapsed64x64,
                    oldCLevel64x64,
                    utilization64x64,
                    0xb333333333333333, // 0.7
                    0xe666666666666666, // 0.9
                    0x10000000000000000, // 1.0
                    0x10000000000000000, // 1.0
                    0xe666666666666666, // 0.9
                    0x56fc2a2c515da32ea // 2e
                )
            );
    }

    function getUtilization64x64(Layout storage l, bool isCall)
        internal
        view
        returns (int128 utilization64x64)
    {
        uint256 tokenId = formatTokenId(
            isCall ? TokenType.UNDERLYING_FREE_LIQ : TokenType.BASE_FREE_LIQ,
            0,
            0
        );

        uint256 tvl = l.totalTVL[isCall];
        uint256 pendingDeposits = l.totalPendingDeposits(isCall);

        if (tvl <= pendingDeposits) return 0;

        uint256 freeLiq = ERC1155EnumerableStorage.layout().totalSupply[
            tokenId
        ];

        if (tvl < freeLiq) {
            // workaround for TVL underflow issue
            freeLiq = tvl;
        }

        utilization64x64 = ABDKMath64x64.divu(
            tvl - freeLiq,
            tvl - pendingDeposits
        );

        // Safeguard check
        require(utilization64x64 <= ONE_64x64, "utilization > 1");
    }

    /**
     * @notice calculate updated C-Level, accounting for change in liquidity
     * @param l storage layout struct
     * @param oldCLevel64x64 64x64 fixed point representation pool C-Level before accounting for liquidity change
     * @param oldLiquidity64x64 64x64 fixed point representation of previous liquidity
     * @param newLiquidity64x64 64x64 fixed point representation of current liquidity
     * @param isCallPool whether to update C-Level for call or put pool
     * @return cLevel64x64 64x64 fixed point representation of C-Level
     */
    function applyCLevelLiquidityChangeAdjustment(
        Layout storage l,
        int128 oldCLevel64x64,
        int128 oldLiquidity64x64,
        int128 newLiquidity64x64,
        bool isCallPool
    ) internal view returns (int128 cLevel64x64) {
        int128 steepness64x64 = isCallPool
            ? l.steepnessUnderlying64x64
            : l.steepnessBase64x64;

        // fallback to deprecated storage value if side-specific value is not set
        if (steepness64x64 == 0) steepness64x64 = l._deprecated_steepness64x64;

        cLevel64x64 = OptionMath.calculateCLevel(
            oldCLevel64x64,
            oldLiquidity64x64,
            newLiquidity64x64,
            steepness64x64
        );

        if (cLevel64x64 < 0xb333333333333333) {
            cLevel64x64 = int128(0xb333333333333333); // 64x64 fixed point representation of 0.7
        }
    }

    /**
     * @notice set C-Level to arbitrary pre-calculated value
     * @param cLevel64x64 new C-Level of pool
     * @param isCallPool whether to update C-Level for call or put pool
     */
    function setCLevel(
        Layout storage l,
        int128 cLevel64x64,
        bool isCallPool
    ) internal {
        if (isCallPool) {
            l.cLevelUnderlying64x64 = cLevel64x64;
            l.cLevelUnderlyingUpdatedAt = block.timestamp;
        } else {
            l.cLevelBase64x64 = cLevel64x64;
            l.cLevelBaseUpdatedAt = block.timestamp;
        }
    }

    function setOracles(
        Layout storage l,
        address baseOracle,
        address underlyingOracle
    ) internal {
        require(
            AggregatorV3Interface(baseOracle).decimals() ==
                AggregatorV3Interface(underlyingOracle).decimals(),
            "Pool: oracle decimals must match"
        );

        l.baseOracle = baseOracle;
        l.underlyingOracle = underlyingOracle;
    }

    function fetchPriceUpdate(Layout storage l)
        internal
        view
        returns (int128 price64x64)
    {
        int256 priceUnderlying = AggregatorInterface(l.underlyingOracle)
            .latestAnswer();
        int256 priceBase = AggregatorInterface(l.baseOracle).latestAnswer();

        return ABDKMath64x64.divi(priceUnderlying, priceBase);
    }

    /**
     * @notice set price update for hourly bucket corresponding to given timestamp
     * @param l storage layout struct
     * @param timestamp timestamp to update
     * @param price64x64 64x64 fixed point representation of price
     */
    function setPriceUpdate(
        Layout storage l,
        uint256 timestamp,
        int128 price64x64
    ) internal {
        uint256 bucket = timestamp / (1 hours);
        l.bucketPrices64x64[bucket] = price64x64;
        l.priceUpdateSequences[bucket >> 8] += 1 << (255 - (bucket & 255));
    }

    /**
     * @notice get price update for hourly bucket corresponding to given timestamp
     * @param l storage layout struct
     * @param timestamp timestamp to query
     * @return 64x64 fixed point representation of price
     */
    function getPriceUpdate(Layout storage l, uint256 timestamp)
        internal
        view
        returns (int128)
    {
        return l.bucketPrices64x64[timestamp / (1 hours)];
    }

    /**
     * @notice get first price update available following given timestamp
     * @param l storage layout struct
     * @param timestamp timestamp to query
     * @return 64x64 fixed point representation of price
     */
    function getPriceUpdateAfter(Layout storage l, uint256 timestamp)
        internal
        view
        returns (int128)
    {
        // price updates are grouped into hourly buckets
        uint256 bucket = timestamp / (1 hours);
        // divide by 256 to get the index of the relevant price update sequence
        uint256 sequenceId = bucket >> 8;

        // get position within sequence relevant to current price update

        uint256 offset = bucket & 255;
        // shift to skip buckets from earlier in sequence
        uint256 sequence = (l.priceUpdateSequences[sequenceId] << offset) >>
            offset;

        // iterate through future sequences until a price update is found
        // sequence corresponding to current timestamp used as upper bound

        uint256 currentPriceUpdateSequenceId = block.timestamp / (256 hours);

        while (sequence == 0 && sequenceId <= currentPriceUpdateSequenceId) {
            sequence = l.priceUpdateSequences[++sequenceId];
        }

        // if no price update is found (sequence == 0) function will return 0
        // this should never occur, as each relevant external function triggers a price update

        // the most significant bit of the sequence corresponds to the offset of the relevant bucket

        uint256 msb;

        for (uint256 i = 128; i > 0; i >>= 1) {
            if (sequence >> i > 0) {
                msb += i;
                sequence >>= i;
            }
        }

        return l.bucketPrices64x64[((sequenceId + 1) << 8) - msb - 1];
    }

    function totalPendingDeposits(Layout storage l, bool isCallPool)
        internal
        view
        returns (uint256)
    {
        return l.nextDeposits[isCallPool].totalPendingDeposits;
    }

    function pendingDepositsOf(
        Layout storage l,
        address account,
        bool isCallPool
    ) internal view returns (uint256) {
        return
            l.pendingDeposits[account][l.nextDeposits[isCallPool].eta][
                isCallPool
            ];
    }

    function contractSizeToBaseTokenAmount(
        Layout storage l,
        uint256 contractSize,
        int128 price64x64,
        bool isCallPool
    ) internal view returns (uint256 tokenAmount) {
        if (isCallPool) {
            tokenAmount = contractSize;
        } else {
            uint256 value = price64x64.mulu(contractSize);

            int128 value64x64 = ABDKMath64x64Token.fromDecimals(
                value,
                l.underlyingDecimals
            );

            tokenAmount = ABDKMath64x64Token.toDecimals(
                value64x64,
                l.baseDecimals
            );
        }
    }

    function setBuybackEnabled(
        Layout storage l,
        bool state,
        bool isCallPool
    ) internal {
        l.isBuybackEnabled[msg.sender][isCallPool] = state;
    }
}

// SPDX-License-Identifier: LGPL-3.0-or-later

pragma solidity ^0.8.0;

import {PremiaStakingStorage} from "./PremiaStakingStorage.sol";
import {IOFT} from "../layerZero/token/oft/IOFT.sol";

import {IERC2612} from "@solidstate/contracts/token/ERC20/permit/IERC2612.sol";

// IERC20Metadata inheritance not possible due to linearization issue
interface IPremiaStaking is IERC2612, IOFT {
    error PremiaStaking__CantTransfer();
    error PremiaStaking__ExcessiveStakePeriod();
    error PremiaStaking__NoPendingWithdrawal();
    error PremiaStaking__NotEnoughLiquidity();
    error PremiaStaking__StakeLocked();
    error PremiaStaking__StakeNotLocked();
    error PremiaStaking__WithdrawalStillPending();
    error PremiaStaking__InsufficientSwapOutput();

    event Stake(
        address indexed user,
        uint256 amount,
        uint64 stakePeriod,
        uint64 lockedUntil
    );

    event Unstake(
        address indexed user,
        uint256 amount,
        uint256 fee,
        uint256 startDate
    );

    event Harvest(address indexed user, uint256 amount);

    event EarlyUnstakeRewardCollected(address indexed user, uint256 amount);

    event Withdraw(address indexed user, uint256 amount);

    event RewardsAdded(uint256 amount);

    struct StakeLevel {
        uint256 amount; // Amount to stake
        uint256 discountBPS; // Discount when amount is reached
    }

    struct SwapArgs {
        //min amount out to be used to purchase
        uint256 amountOutMin;
        // exchange address to call to execute the trade
        address callee;
        // address for which to set allowance for the trade
        address allowanceTarget;
        // data to execute the trade
        bytes data;
        // address to which refund excess tokens
        address refundAddress;
    }

    event BridgeLock(
        address indexed user,
        uint64 stakePeriod,
        uint64 lockedUntil
    );

    /**
     * @notice Returns the reward token address
     * @return The reward token address
     */
    function getRewardToken() external view returns (address);

    /**
     * @notice add premia tokens as available tokens to be distributed as rewards
     * @param amount amount of premia tokens to add as rewards
     */
    function addRewards(uint256 amount) external;

    /**
     * @notice get amount of tokens that have not yet been distributed as rewards
     * @return rewards amount of tokens not yet distributed as rewards
     * @return unstakeRewards amount of PREMIA not yet claimed from early unstake fees
     */
    function getAvailableRewards()
        external
        view
        returns (uint256 rewards, uint256 unstakeRewards);

    /**
     * @notice get pending amount of tokens to be distributed as rewards to stakers
     * @return amount of tokens pending to be distributed as rewards
     */
    function getPendingRewards() external view returns (uint256);

    /**
     * @notice get pending withdrawal data of a user
     * @return amount pending withdrawal amount
     * @return startDate start timestamp of withdrawal
     * @return unlockDate timestamp at which withdrawal becomes available
     */
    function getPendingWithdrawal(address user)
        external
        view
        returns (
            uint256 amount,
            uint256 startDate,
            uint256 unlockDate
        );

    /**
     * @notice get the amount of PREMIA available for withdrawal
     * @return amount of PREMIA available for withdrawal
     */
    function getAvailablePremiaAmount() external view returns (uint256);

    /**
     * @notice Stake using IERC2612 permit
     * @param amount The amount of xPremia to stake
     * @param period The lockup period (in seconds)
     * @param deadline Deadline after which permit will fail
     * @param v V
     * @param r R
     * @param s S
     */
    function stakeWithPermit(
        uint256 amount,
        uint64 period,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @notice Lockup xPremia for protocol fee discounts
     *          Longer period of locking will apply a multiplier on the amount staked, in the fee discount calculation
     * @param amount The amount of xPremia to stake
     * @param period The lockup period (in seconds)
     */
    function stake(uint256 amount, uint64 period) external;

    /**
     * @notice harvest rewards, convert to PREMIA using exchange helper, and stake
     * @param s swap arguments
     * @param stakePeriod The lockup period (in seconds)
     */
    function harvestAndStake(
        IPremiaStaking.SwapArgs memory s,
        uint64 stakePeriod
    ) external;

    /**
     * @notice Harvest rewards directly to user wallet
     */
    function harvest() external;

    /**
     * @notice Get pending rewards amount, including pending pool update
     * @param user User for which to calculate pending rewards
     * @return reward amount of pending rewards from protocol fees (in REWARD_TOKEN)
     * @return unstakeReward amount of pending rewards from early unstake fees (in PREMIA)
     */
    function getPendingUserRewards(address user)
        external
        view
        returns (uint256 reward, uint256 unstakeReward);

    /**
     * @notice unstake tokens before end of the lock period, for a fee
     * @param amount the amount of vxPremia to unstake
     */
    function earlyUnstake(uint256 amount) external;

    /**
     * @notice get early unstake fee for given user
     * @param user address of the user
     * @return feePercentage % fee to pay for early unstake (1e4 = 100%)
     */
    function getEarlyUnstakeFeeBPS(address user)
        external
        view
        returns (uint256 feePercentage);

    /**
     * @notice Initiate the withdrawal process by burning xPremia, starting the delay period
     * @param amount quantity of xPremia to unstake
     */
    function startWithdraw(uint256 amount) external;

    /**
     * @notice Withdraw underlying premia
     */
    function withdraw() external;

    //////////
    // View //
    //////////

    /**
     * Calculate the stake amount of a user, after applying the bonus from the lockup period chosen
     * @param user The user from which to query the stake amount
     * @return The user stake amount after applying the bonus
     */
    function getUserPower(address user) external view returns (uint256);

    /**
     * Return the total power across all users (applying the bonus from lockup period chosen)
     * @return The total power across all users
     */
    function getTotalPower() external view returns (uint256);

    /**
     * @notice Calculate the % of fee discount for user, based on his stake
     * @param user The _user for which the discount is for
     * @return Percentage of protocol fee discount (in basis point)
     *         Ex : 1000 = 10% fee discount
     */
    function getDiscountBPS(address user) external view returns (uint256);

    /**
     * @notice Get stake levels
     * @return Stake levels
     *         Ex : 2500 = -25%
     */
    function getStakeLevels() external returns (StakeLevel[] memory);

    /**
     * @notice Get stake period multiplier
     * @param period The duration (in seconds) for which tokens are locked
     * @return The multiplier for this staking period
     *         Ex : 20000 = x2
     */
    function getStakePeriodMultiplierBPS(uint256 period)
        external
        returns (uint256);

    /**
     * @notice Get staking infos of a user
     * @param user The user address for which to get staking infos
     * @return The staking infos of the user
     */
    function getUserInfo(address user)
        external
        view
        returns (PremiaStakingStorage.UserInfo memory);
}

// SPDX-License-Identifier: BUSL-1.1
// For further clarification please see https://license.premia.legal

pragma solidity ^0.8.0;

library PremiaStakingStorage {
    bytes32 internal constant STORAGE_SLOT =
        keccak256("premia.contracts.staking.PremiaStaking");

    struct Withdrawal {
        uint256 amount; // Premia amount
        uint256 startDate; // Will unlock at startDate + withdrawalDelay
    }

    struct UserInfo {
        uint256 reward; // Amount of rewards accrued which havent been claimed yet
        uint256 rewardDebt; // Debt to subtract from reward calculation
        uint256 unstakeRewardDebt; // Debt to subtract from reward calculation from early unstake fee
        uint64 stakePeriod; // Stake period selected by user
        uint64 lockedUntil; // Timestamp at which the lock ends
    }

    struct Layout {
        uint256 pendingWithdrawal;
        uint256 _deprecated_withdrawalDelay;
        mapping(address => Withdrawal) withdrawals;
        uint256 availableRewards;
        uint256 lastRewardUpdate; // Timestamp of last reward distribution update
        uint256 totalPower; // Total power of all staked tokens (underlying amount with multiplier applied)
        mapping(address => UserInfo) userInfo;
        uint256 accRewardPerShare;
        uint256 accUnstakeRewardPerShare;
        uint256 availableUnstakeRewards;
    }

    function layout() internal pure returns (Layout storage l) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            l.slot := slot
        }
    }
}