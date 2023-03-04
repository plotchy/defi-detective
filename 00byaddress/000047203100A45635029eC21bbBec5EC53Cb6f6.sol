// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
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
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Address.sol)

pragma solidity ^0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/cryptography/MerkleProof.sol)

pragma solidity ^0.8.0;

/**
 * @dev These functions deal with verification of Merkle Trees proofs.
 *
 * The proofs can be generated using the JavaScript library
 * https://github.com/miguelmota/merkletreejs[merkletreejs].
 * Note: the hashing algorithm should be keccak256 and pair sorting should be enabled.
 *
 * See `test/utils/cryptography/MerkleProof.test.js` for some examples.
 */
library MerkleProof {
    /**
     * @dev Returns true if a `leaf` can be proved to be a part of a Merkle tree
     * defined by `root`. For this, a `proof` must be provided, containing
     * sibling hashes on the branch from the leaf to the root of the tree. Each
     * pair of leaves and each pair of pre-images are assumed to be sorted.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        return processProof(proof, leaf) == root;
    }

    /**
     * @dev Returns the rebuilt hash obtained by traversing a Merklee tree up
     * from `leaf` using `proof`. A `proof` is valid if and only if the rebuilt
     * hash matches the root of the tree. When processing the proof, the pairs
     * of leafs & pre-images are assumed to be sorted.
     *
     * _Available since v4.4._
     */
    function processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash;
    }
}

pragma solidity >=0.8.0 <0.9.0;
// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SaleManager is ReentrancyGuard {
  using SafeERC20 for IERC20;

  AggregatorV3Interface priceOracle;
  IERC20 public immutable paymentToken;
  uint8 public immutable paymentTokenDecimals;

  struct Sale {
    address payable seller; // the address that will receive sale proceeds
    bytes32 merkleRoot; // the merkle root used for proving access
    address claimManager; // address where purchased tokens can be claimed (optional)
    uint256 saleBuyLimit;  // max tokens that can be spent in total
    uint256 userBuyLimit;  // max tokens that can be spent per user
    uint startTime; // the time at which the sale starts
    uint endTime; // the time at which the sale will end, regardless of tokens raised
    string name; // the name of the asset being sold, e.g. "New Crypto Token"
    string symbol; // the symbol of the asset being sold, e.g. "NCT"
    uint256 price; // the price of the asset (eg if 1.0 NCT == $1.23 of USDC: 1230000)
    uint8 decimals; // the number of decimals in the asset being sold, e.g. 18
    uint256 totalSpent; // total purchases denominated in payment token
    uint256 maxQueueTime; // what is the maximum length of time a user could wait in the queue after the sale starts?
    uint160 randomValue; // reasonably random value: xor of merkle root and blockhash for transaction setting merkle root
    mapping(address => uint256) spent;
  }

  mapping (bytes32 => Sale) public sales;

  // global metrics
  uint256 public saleCount = 0;
  uint256 public totalSpent = 0;

  event NewSale(
    bytes32 indexed saleId,
    bytes32 indexed merkleRoot,
    address indexed seller,
    uint256 saleBuyLimit,
    uint256 userBuyLimit,
    uint256 maxQueueTime,
    uint startTime,
    uint endTime,
    string name,
    string symbol,
    uint256 price,
    uint8 decimals
  );

  event UpdateStart(bytes32 indexed saleId, uint startTime);
  event UpdateEnd(bytes32 indexed saleId, uint endTime);
  event UpdateMerkleRoot(bytes32 indexed saleId, bytes32 merkleRoot);
  event UpdateMaxQueueTime(bytes32 indexed saleId, uint256 maxQueueTime);
  event Buy(bytes32 indexed saleId, address indexed buyer, uint256 value, bool native, bytes32[] proof);
  event RegisterClaimManager(bytes32 indexed saleId, address indexed claimManager);

  constructor(
    address _paymentToken,
    uint8 _paymentTokenDecimals,
    address _priceOracle
  ) {
    paymentToken = IERC20(_paymentToken);
    paymentTokenDecimals = _paymentTokenDecimals;
    priceOracle = AggregatorV3Interface(_priceOracle);
  }

  modifier validSale (bytes32 saleId) {
    // if the seller is address(0) there is no sale struct at this saleId
    require(
      sales[saleId].seller != address(0),
      "invalid sale id"
    );
    _;
  }

  modifier isSeller(bytes32 saleId) {
    // msg.sender is never address(0) so this handles uninitialized sales
    require(
      sales[saleId].seller == msg.sender,
      "must be seller"
    );
    _;
  }

  modifier canAccessSale(bytes32 saleId, bytes32[] calldata proof) {
    // make sure the buyer is an EOA
    require((msg.sender == tx.origin), "Must buy with an EOA");

    // If the merkle root is non-zero this is a private sale and requires a valid proof
    if (sales[saleId].merkleRoot != bytes32(0)) {
      require(
        this._isAllowed(
          sales[saleId].merkleRoot,
          msg.sender,
          proof
        ) == true,
        "bad merkle proof for sale"
      );
    }

    // Reduce congestion by randomly assigning each user a delay time in a virtual queue based on comparing their address and a random value
    // if sale.maxQueueTime == 0 the delay is 0
    require(block.timestamp - sales[saleId].startTime > getFairQueueTime(saleId, msg.sender), "not your turn yet");

    _;
  }

  modifier requireOpen(bytes32 saleId) {
    require(block.timestamp > sales[saleId].startTime, "sale not started yet");
    require(block.timestamp < sales[saleId].endTime, "sale ended");
    require(sales[saleId].totalSpent < sales[saleId].saleBuyLimit, "sale over");
    _;
  }

  // Get current price from chainlink oracle
  function getLatestPrice() public view returns (uint) {
    (
        uint80 roundID,
        int price,
        uint startedAt,
        uint timeStamp,
        uint80 answeredInRound
    ) = priceOracle.latestRoundData();

    require(price > 0, "negative price");
    return uint(price);
  }

  // Accessor functions
  function getSeller(bytes32 saleId) public validSale(saleId) view returns(address) {
    return(sales[saleId].seller);
  }

  function getMerkleRoot(bytes32 saleId) public validSale(saleId) view returns(bytes32) {
    return(sales[saleId].merkleRoot);
  }

  function getPriceOracle() public view returns(address) {
    return address(priceOracle);
  }

  function getClaimManager(bytes32 saleId) public validSale(saleId) view returns(address) {
    return (sales[saleId].claimManager);
  }


  function getSaleBuyLimit(bytes32 saleId) public validSale(saleId) view returns(uint256) {
    return(sales[saleId].saleBuyLimit);
  }

  function getUserBuyLimit(bytes32 saleId) public validSale(saleId) view returns(uint256) {
    return(sales[saleId].userBuyLimit);
  }

  function getStartTime(bytes32 saleId) public validSale(saleId) view returns(uint) {
    return(sales[saleId].startTime);
  }

  function getEndTime(bytes32 saleId) public validSale(saleId) view returns(uint) {
    return(sales[saleId].endTime);
  }

  function getName(bytes32 saleId) public validSale(saleId) view returns(string memory) {
    return(sales[saleId].name);
  }

  function getSymbol(bytes32 saleId) public validSale(saleId) view returns(string memory) {
    return(sales[saleId].symbol);
  }

  function getPrice(bytes32 saleId) public validSale(saleId) view returns(uint) {
    return(sales[saleId].price);
  }

  function getDecimals(bytes32 saleId) public validSale(saleId) view returns(uint256) {
    return (sales[saleId].decimals);
  }

  function getTotalSpent(bytes32 saleId) public validSale(saleId) view returns(uint256) {
    return (sales[saleId].totalSpent);
  }

  function getRandomValue(bytes32 saleId) public validSale(saleId) view returns(uint160) {
    return sales[saleId].randomValue;
  }

  function getMaxQueueTime(bytes32 saleId) public validSale(saleId) view returns(uint256) {
    return sales[saleId].maxQueueTime;
  }

  function generateRandomishValue(bytes32 merkleRoot) public view returns(uint160) {
    /**
      This is not a truly random value:
      - miners can alter the block hash
      - sellers can repeatedly call setMerkleRoot()
    */
    return uint160(uint256(blockhash(0))) ^ uint160(uint256(merkleRoot));
  }

  function getFairQueueTime(bytes32 saleId, address buyer) public validSale(saleId) view returns(uint) {
    /**
      Get the delay in seconds that a specific buyer must wait after the sale begins in order to buy tokens in the sale

      Buyers cannot exploit the fair queue when:
      - The sale is private (merkle root != bytes32(0))
      - Each eligible buyer gets exactly one address in the merkle root

      Although miners and sellers can minimize the delay for an arbitrary address, these are not significant threats
      - the economic opportunity to miners is zero or relatively small (only specific addresses can participate in private sales, and a better queue postion does not imply high returns)
      - sellers can repeatedly set merkle roots (but sellers already control the tokens being sold!)

    */
    if (sales[saleId].maxQueueTime == 0) {
      // there is no delay: all addresses may participate immediately
      return 0;
    }

    // calculate a distance between the random value and the user's address using the XOR distance metric (c.f. Kademlia)
    uint160 distance = uint160(buyer) ^ sales[saleId].randomValue;

    // calculate a speed at which the queue is exhausted such that all users complete the queue by sale.maxQueueTime
    uint160 distancePerSecond = type(uint160).max / uint160(sales[saleId].maxQueueTime);
    // return the delay (seconds)
    return distance / distancePerSecond;
  }

  function spentToBought(bytes32 saleId, uint256 spent) public view returns (uint256) {
    // Convert tokens spent (e.g. 10,000,000 USDC = $10) to tokens bought (e.g. 8.13e18) at a price of $1.23/NCT
    // convert an integer value of tokens spent to an integer value of tokens bought
    return (spent * 10 ** sales[saleId].decimals ) / (sales[saleId].price);
  }

  function nativeToPaymentToken(uint256 nativeValue) public view returns (uint256) {
    // convert a payment in the native token (eg ETH) to an integer value of the payment token
    return (nativeValue * getLatestPrice() * 10 ** paymentTokenDecimals) / (10 ** (priceOracle.decimals() + 18));
  }

  function getSpent(
      bytes32 saleId,
      address userAddress
    ) public validSale(saleId) view returns(uint256) {
    // returns the amount spent by this user in paymentToken
    return(sales[saleId].spent[userAddress]);
  }

  function getBought(
      bytes32 saleId,
      address userAddress
    ) public validSale(saleId) view returns(uint256) {
    // returns the amount bought by this user in the new token being sold
    return(spentToBought(saleId, sales[saleId].spent[userAddress]));
  }

  function isOpen(bytes32 saleId) public validSale(saleId) view returns(bool) {
    // is the sale currently open?
    return(
      block.timestamp > sales[saleId].startTime
      && block.timestamp < sales[saleId].endTime
      && sales[saleId].totalSpent < sales[saleId].saleBuyLimit
    );
  }

  function isOver(bytes32 saleId) public validSale(saleId) view returns(bool) {
    // is the sale permanently over?
    return(
      block.timestamp >= sales[saleId].endTime || sales[saleId].totalSpent >= sales[saleId].saleBuyLimit
    );
  }

  /**
  sale setup and config
  - the address calling this method is the seller: all payments are sent to this address
  - only the seller can change sale configuration
  */
  function newSale(
    bytes32 merkleRoot,
    uint256 saleBuyLimit,
    uint256 userBuyLimit,
    uint startTime,
    uint endTime,
    uint160 maxQueueTime,
    string calldata name,
    string calldata symbol,
    uint256 price,
    uint8 decimals
  ) public returns(bytes32) {
    require(startTime <= 4102444800, "max: 4102444800 (Jan 1 2100)");
    require(endTime <= 4102444800, "max: 4102444800 (Jan 1 2100)");
    require(startTime < endTime, "sale must start before it ends");
    require(endTime > block.timestamp, "sale must end in future");
    require(userBuyLimit <= saleBuyLimit, "userBuyLimit cannot exceed saleBuyLimit");
    require(userBuyLimit > 0, "userBuyLimit must be > 0");
    require(saleBuyLimit > 0, "saleBuyLimit must be > 0");
    require(endTime - startTime > maxQueueTime, "sale must be open for longer than max queue time");

    // Generate a reorg-resistant sale ID
    bytes32 saleId = keccak256(abi.encodePacked(
      merkleRoot,
      msg.sender,
      saleBuyLimit,
      userBuyLimit,
      startTime,
      endTime,
      name,
      symbol,
      price,
      decimals
    ));

    // This ensures the Sale struct wasn't already created (msg.sender will never be the zero address)
    require(sales[saleId].seller == address(0), "a sale with these parameters already exists");

    Sale storage s = sales[saleId];

    s.merkleRoot = merkleRoot;
    s.seller = payable(msg.sender);
    s.saleBuyLimit = saleBuyLimit;
    s.userBuyLimit = userBuyLimit;
    s.startTime = startTime;
    s.endTime = endTime;
    s.name = name;
    s.symbol = symbol;
    s.price = price;
    s.decimals = decimals;
    s.maxQueueTime = maxQueueTime;
    s.randomValue = generateRandomishValue(merkleRoot);

    saleCount++;

    emit NewSale(saleId,
      s.merkleRoot,
      s.seller,
      s.saleBuyLimit,
      s.userBuyLimit,
      s.maxQueueTime,
      s.startTime,
      s.endTime,
      s.name,
      s.symbol,
      s.price,
      s.decimals
    );

    return saleId;
  }

  function setStart(bytes32 saleId, uint startTime) public validSale(saleId) isSeller(saleId) {
    // seller can update start time until the sale starts
    require(block.timestamp < sales[saleId].endTime, "disabled after sale close");
    require(startTime < sales[saleId].endTime, "sale start must precede end");
    require(startTime <= 4102444800, "max: 4102444800 (Jan 1 2100)");
    require(sales[saleId].endTime - startTime > sales[saleId].maxQueueTime, "sale must be open for longer than max queue time");

    sales[saleId].startTime = startTime;
    emit UpdateStart(saleId, startTime);
  }

  function setEnd(bytes32 saleId, uint endTime) public validSale(saleId) isSeller(saleId){
    // seller can update end time until the sale ends
    require(block.timestamp < sales[saleId].endTime, "disabled after sale closes");
    require(endTime > block.timestamp, "sale must end in future");
    require(endTime <= 4102444800, "max: 4102444800 (Jan 1 2100)");
    require(sales[saleId].startTime < endTime, "sale must start before it ends");
    require(endTime - sales[saleId].startTime > sales[saleId].maxQueueTime, "sale must be open for longer than max queue time");

    sales[saleId].endTime = endTime;
    emit UpdateEnd(saleId, endTime);
  }

  function setMerkleRoot(bytes32 saleId, bytes32 merkleRoot) public validSale(saleId) isSeller(saleId){
    require(!isOpen(saleId) && !isOver(saleId), "cannot set merkle root once sale opens");
    sales[saleId].merkleRoot = merkleRoot;
    sales[saleId].randomValue = generateRandomishValue(merkleRoot);
    emit UpdateMerkleRoot(saleId, merkleRoot);
  }

  function setMaxQueueTime(bytes32 saleId, uint160 maxQueueTime) public validSale(saleId) isSeller(saleId) {
    // the queue time may be adjusted after the sale begins
    require(sales[saleId].endTime > block.timestamp, "cannot adjust max queue time after sale ends");
    sales[saleId].maxQueueTime = maxQueueTime;
    emit UpdateMaxQueueTime(saleId, maxQueueTime);
  }

  function _isAllowed(
      bytes32 root,
      address account,
      bytes32[] calldata proof
  ) external pure returns (bool) {
    // check if the account is in the merkle tree
    bytes32 leaf = keccak256(abi.encodePacked(account));
    if (MerkleProof.verify(proof, root, leaf)) {
      return true;
    }
    return false;
  }

  // pay with the payment token (eg USDC)
  function buy(
    bytes32 saleId,
    uint256 tokenQuantity,
    bytes32[] calldata proof
  ) public validSale(saleId) requireOpen(saleId) canAccessSale(saleId, proof) nonReentrant {
    // make sure the purchase would not break any sale limits
    require(
      tokenQuantity + sales[saleId].spent[msg.sender] <= sales[saleId].userBuyLimit,
      "purchase exceeds your limit"
    );

    require(
      tokenQuantity + sales[saleId].totalSpent <= sales[saleId].saleBuyLimit,
      "purchase exceeds sale limit"
    );

    require(paymentToken.allowance(msg.sender, address(this)) >= tokenQuantity, "allowance too low");

    // move the funds
    paymentToken.safeTransferFrom(msg.sender, sales[saleId].seller, tokenQuantity);

    // effects after interaction: we need a reentrancy guard
    sales[saleId].spent[msg.sender] += tokenQuantity;
    sales[saleId].totalSpent += tokenQuantity;
    totalSpent += tokenQuantity;

    emit Buy(saleId, msg.sender, tokenQuantity, false, proof);
  }

  // pay with the native token
  function buy(
    bytes32 saleId,
    bytes32[] calldata proof
  ) public payable validSale(saleId) requireOpen(saleId) canAccessSale(saleId, proof) nonReentrant {
    // convert to the equivalent payment token value from wei
    uint256 tokenQuantity = nativeToPaymentToken(msg.value);

    // make sure the purchase would not break any sale limits
    require(
      tokenQuantity + sales[saleId].spent[msg.sender] <= sales[saleId].userBuyLimit,
      "purchase exceeds your limit"
    );

    require(
      tokenQuantity + sales[saleId].totalSpent <= sales[saleId].saleBuyLimit,
      "purchase exceeds sale limit"
    );

    // forward the eth to the seller
    sales[saleId].seller.transfer(msg.value);

    // account for the purchase in equivalent payment token value
    sales[saleId].spent[msg.sender] += tokenQuantity;
    sales[saleId].totalSpent += tokenQuantity;
    totalSpent += tokenQuantity;

    // flag this payment as using the native token
    emit Buy(saleId, msg.sender, tokenQuantity, true, proof);
  }

  // Tell users where they can claim tokens
  function registerClaimManager(bytes32 saleId, address claimManager) public validSale(saleId) isSeller(saleId) {
    require(claimManager != address(0), "Claim manager must be a non-zero address");
    sales[saleId].claimManager = claimManager;
    emit RegisterClaimManager(saleId, claimManager);
  }

  function recoverERC20(bytes32 saleId, address tokenAddress, uint256 tokenAmount) public isSeller(saleId) {
    IERC20(tokenAddress).transfer(msg.sender, tokenAmount);
  }
}