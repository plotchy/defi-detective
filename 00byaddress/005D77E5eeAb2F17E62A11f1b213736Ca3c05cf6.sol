/*
  ･
   *　★
      ･ ｡
        　･　ﾟ☆ ｡
  　　　 *　★ ﾟ･｡ *  ｡
          　　* ☆ ｡･ﾟ*.｡
      　　　ﾟ *.｡☆｡★　･
​
                      `                     .-:::::-.`              `-::---...```
                     `-:`               .:+ssssoooo++//:.`       .-/+shhhhhhhhhhhhhyyyssooo:
                    .--::.            .+ossso+/////++/:://-`   .////+shhhhhhhhhhhhhhhhhhhhhy
                  `-----::.         `/+////+++///+++/:--:/+/-  -////+shhhhhhhhhhhhhhhhhhhhhy
                 `------:::-`      `//-.``.-/+ooosso+:-.-/oso- -////+shhhhhhhhhhhhhhhhhhhhhy
                .--------:::-`     :+:.`  .-/osyyyyyyso++syhyo.-////+shhhhhhhhhhhhhhhhhhhhhy
              `-----------:::-.    +o+:-.-:/oyhhhhhhdhhhhhdddy:-////+shhhhhhhhhhhhhhhhhhhhhy
             .------------::::--  `oys+/::/+shhhhhhhdddddddddy/-////+shhhhhhhhhhhhhhhhhhhhhy
            .--------------:::::-` +ys+////+yhhhhhhhddddddddhy:-////+yhhhhhhhhhhhhhhhhhhhhhy
          `----------------::::::-`.ss+/:::+oyhhhhhhhhhhhhhhho`-////+shhhhhhhhhhhhhhhhhhhhhy
         .------------------:::::::.-so//::/+osyyyhhhhhhhhhys` -////+shhhhhhhhhhhhhhhhhhhhhy
       `.-------------------::/:::::..+o+////+oosssyyyyyyys+`  .////+shhhhhhhhhhhhhhhhhhhhhy
       .--------------------::/:::.`   -+o++++++oooosssss/.     `-//+shhhhhhhhhhhhhhhhhhhhyo
     .-------   ``````.......--`        `-/+ooooosso+/-`          `./++++///:::--...``hhhhyo
                                              `````
   *　
      ･ ｡
　　　　･　　ﾟ☆ ｡
  　　　 *　★ ﾟ･｡ *  ｡
          　　* ☆ ｡･ﾟ*.｡
      　　　ﾟ *.｡☆｡★　･
    *　　ﾟ｡·*･｡ ﾟ*
  　　　☆ﾟ･｡°*. ﾟ
　 ･ ﾟ*｡･ﾟ★｡
　　･ *ﾟ｡　　 *
　･ﾟ*｡★･
 ☆∴｡　*
･ ｡
*/

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;
pragma abicoder v2; // solhint-disable-line

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./mixins/FoundationTreasuryNode.sol";
import "./mixins/roles/FoundationAdminRole.sol";
import "./mixins/roles/FoundationOperatorRole.sol";
import "./mixins/NFTMarketCore.sol";
import "./mixins/SendValueWithFallbackWithdraw.sol";
import "./mixins/NFTMarketCreators.sol";
import "./mixins/NFTMarketFees.sol";
import "./mixins/NFTMarketAuction.sol";
import "./mixins/NFTMarketReserveAuction.sol";
import "./mixins/AccountMigration.sol";
import "./mixins/NFTMarketPrivateSale.sol";

/**
 * @title A market for NFTs on Foundation.
 * @dev This top level file holds no data directly to ease future upgrades.
 */
contract FNDNFTMarket is
  FoundationTreasuryNode,
  FoundationAdminRole,
  FoundationOperatorRole,
  AccountMigration,
  NFTMarketCore,
  ReentrancyGuardUpgradeable,
  NFTMarketCreators,
  SendValueWithFallbackWithdraw,
  NFTMarketFees,
  NFTMarketAuction,
  NFTMarketReserveAuction,
  NFTMarketPrivateSale
{
  /**
   * @notice Called once to configure the contract after the initial deployment.
   * @dev This farms the initialize call out to inherited contracts as needed.
   */
  function initialize(address payable treasury) public initializer {
    FoundationTreasuryNode._initializeFoundationTreasuryNode(treasury);
    NFTMarketAuction._initializeNFTMarketAuction();
    NFTMarketReserveAuction._initializeNFTMarketReserveAuction();
  }

  /**
   * @notice Allows Foundation to update the market configuration.
   */
  function adminUpdateConfig(
    uint256 minPercentIncrementInBasisPoints,
    uint256 duration,
    uint256 primaryF8nFeeBasisPoints,
    uint256 secondaryF8nFeeBasisPoints,
    uint256 secondaryCreatorFeeBasisPoints
  ) public onlyFoundationAdmin {
    // It's okay to call _reinitialize multiple times, but it must be called at least once after upgrade
    _reinitialize();
    _updateReserveAuctionConfig(minPercentIncrementInBasisPoints, duration);
    _updateMarketFees(primaryF8nFeeBasisPoints, secondaryF8nFeeBasisPoints, secondaryCreatorFeeBasisPoints);
  }

  /**
   * @dev Checks who the seller for an NFT is, this will check escrow or return the current owner if not in escrow.
   * This is a no-op function required to avoid compile errors.
   */
  function _getSellerFor(address nftContract, uint256 tokenId)
    internal
    view
    virtual
    override(NFTMarketCore, NFTMarketReserveAuction)
    returns (address payable)
  {
    return super._getSellerFor(nftContract, tokenId);
  }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;
import "../proxy/Initializable.sol";

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
abstract contract ReentrancyGuardUpgradeable is Initializable {
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

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
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
    uint256[49] private __gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

/**
 * @notice A mixin that stores a reference to the Foundation treasury contract.
 */
abstract contract FoundationTreasuryNode is Initializable {
  using AddressUpgradeable for address payable;

  address payable private treasury;

  /**
   * @dev Called once after the initial deployment to set the Foundation treasury address.
   */
  function _initializeFoundationTreasuryNode(address payable _treasury) internal initializer {
    require(_treasury.isContract(), "FoundationTreasuryNode: Address is not a contract");
    treasury = _treasury;
  }

  /**
   * @notice Returns the address of the Foundation treasury.
   */
  function getFoundationTreasury() public view returns (address payable) {
    return treasury;
  }

  // `______gap` is added to each mixin to allow adding new data slots or additional mixins in an upgrade-safe way.
  uint256[2000] private __gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "../../interfaces/IAdminRole.sol";

import "../FoundationTreasuryNode.sol";

/**
 * @notice Allows a contract to leverage the admin role defined by the Foundation treasury.
 */
abstract contract FoundationAdminRole is FoundationTreasuryNode {
  // This file uses 0 data slots (other than what's included via FoundationTreasuryNode)

  modifier onlyFoundationAdmin() {
    require(_isFoundationAdmin(), "FoundationAdminRole: caller does not have the Admin role");
    _;
  }

  function _isFoundationAdmin() internal view returns (bool) {
    return IAdminRole(getFoundationTreasury()).isAdmin(msg.sender);
  }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "../../interfaces/IOperatorRole.sol";

import "../FoundationTreasuryNode.sol";

/**
 * @notice Allows a contract to leverage the operator role defined by the Foundation treasury.
 */
abstract contract FoundationOperatorRole is FoundationTreasuryNode {
  // This file uses 0 data slots (other than what's included via FoundationTreasuryNode)

  function _isFoundationOperator() internal view returns (bool) {
    return IOperatorRole(getFoundationTreasury()).isOperator(msg.sender);
  }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

/**
 * @notice A place for common modifiers and functions used by various NFTMarket mixins, if any.
 * @dev This also leaves a gap which can be used to add a new mixin to the top of the inheritance tree.
 */
abstract contract NFTMarketCore {
  /**
   * @dev If the auction did not have an escrowed seller to return, this falls back to return the current owner.
   * This allows functions to calculate the correct fees before the NFT has been listed in auction.
   */
  function _getSellerFor(address nftContract, uint256 tokenId) internal view virtual returns (address payable) {
    return payable(IERC721Upgradeable(nftContract).ownerOf(tokenId));
  }

  // 50 slots were consumed by adding ReentrancyGuardUpgradeable
  uint256[950] private ______gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

/**
 * @notice Attempt to send ETH and if the transfer fails or runs out of gas, store the balance
 * for future withdrawal instead.
 */
abstract contract SendValueWithFallbackWithdraw is ReentrancyGuardUpgradeable {
  using AddressUpgradeable for address payable;
  using SafeMathUpgradeable for uint256;

  mapping(address => uint256) private pendingWithdrawals;

  event WithdrawPending(address indexed user, uint256 amount);
  event Withdrawal(address indexed user, uint256 amount);

  /**
   * @notice Returns how much funds are available for manual withdraw due to failed transfers.
   */
  function getPendingWithdrawal(address user) public view returns (uint256) {
    return pendingWithdrawals[user];
  }

  /**
   * @notice Allows a user to manually withdraw funds which originally failed to transfer to themselves.
   */
  function withdraw() public {
    withdrawFor(msg.sender);
  }

  /**
   * @notice Allows anyone to manually trigger a withdrawal of funds which originally failed to transfer for a user.
   */
  function withdrawFor(address payable user) public nonReentrant {
    uint256 amount = pendingWithdrawals[user];
    require(amount > 0, "No funds are pending withdrawal");
    pendingWithdrawals[user] = 0;
    user.sendValue(amount);
    emit Withdrawal(user, amount);
  }

  /**
   * @dev Attempt to send a user ETH with a reasonably low gas limit of 20k,
   * which is enough to send to contracts as well.
   */
  function _sendValueWithFallbackWithdrawWithLowGasLimit(address payable user, uint256 amount) internal {
    _sendValueWithFallbackWithdraw(user, amount, 20000);
  }

  /**
   * @dev Attempt to send a user or contract ETH with a moderate gas limit of 90k,
   * which is enough for a 5-way split.
   */
  function _sendValueWithFallbackWithdrawWithMediumGasLimit(address payable user, uint256 amount) internal {
    _sendValueWithFallbackWithdraw(user, amount, 210000);
  }

  /**
   * @dev Attempt to send a user or contract ETH and if it fails store the amount owned for later withdrawal.
   */
  function _sendValueWithFallbackWithdraw(
    address payable user,
    uint256 amount,
    uint256 gasLimit
  ) private {
    if (amount == 0) {
      return;
    }
    // Cap the gas to prevent consuming all available gas to block a tx from completing successfully
    // solhint-disable-next-line avoid-low-level-calls
    (bool success, ) = user.call{ value: amount, gas: gasLimit }("");
    if (!success) {
      // Record failed sends for a withdrawal later
      // Transfers could fail if sent to a multisig with non-trivial receiver logic
      // solhint-disable-next-line reentrancy
      pendingWithdrawals[user] = pendingWithdrawals[user].add(amount);
      emit WithdrawPending(user, amount);
    }
  }

  uint256[499] private ______gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "../interfaces/IFNDNFT721.sol";
import "../interfaces/ITokenCreatorPaymentAddress.sol";
import "../interfaces/ITokenCreator.sol";
import "../interfaces/IGetRoyalties.sol";
import "../interfaces/IHasSecondarySaleFees.sol";
import "../interfaces/IOwnable.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./OZ/ERC165Checker.sol";

import "./Constants.sol";

/**
 * @notice A mixin for associating creators to NFTs.
 * @dev In the future this may store creators directly in order to support NFTs created on a different platform.
 */
abstract contract NFTMarketCreators is
  Constants,
  ReentrancyGuardUpgradeable // Adding this unused mixin to help with linearization
{
  using ERC165Checker for address;

  /**
   * @dev Returns the destination address for any payments to the creator,
   * or address(0) if the destination is unknown.
   * It also checks if the current seller is the creator for isPrimary checks.
   */
  // solhint-disable-next-line code-complexity
  function _getCreatorPaymentInfo(
    address nftContract,
    uint256 tokenId,
    address seller
  )
    internal
    view
    returns (
      address payable[] memory recipients,
      uint256[] memory splitPerRecipientInBasisPoints,
      bool isCreator
    )
  {
    // All NFTs implement 165 so we skip that check, individual interfaces should return false if 165 is not implemented

    // 1st priority: getTokenCreatorPaymentAddress w/ 165
    if (nftContract.supportsERC165Interface(type(ITokenCreatorPaymentAddress).interfaceId)) {
      try
        ITokenCreatorPaymentAddress(nftContract).getTokenCreatorPaymentAddress{ gas: READ_ONLY_GAS_LIMIT }(tokenId)
      returns (address payable tokenCreatorPaymentAddress) {
        if (tokenCreatorPaymentAddress != address(0)) {
          recipients = new address payable[](1);
          recipients[0] = tokenCreatorPaymentAddress;
          if (tokenCreatorPaymentAddress == seller) {
            // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
            return (recipients, splitPerRecipientInBasisPoints, true);
          }
          // else persist recipients but look for other isCreator definitions
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    // 2nd priority: tokenCreator w/ 165
    if (nftContract.supportsERC165Interface(type(ITokenCreator).interfaceId)) {
      try IFNDNFT721(nftContract).tokenCreator{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (address payable _creator) {
        if (_creator != address(0)) {
          if (recipients.length == 0) {
            // Only pay the tokenCreator if there wasn't a tokenCreatorPaymentAddress defined
            recipients = new address payable[](1);
            recipients[0] = _creator;
          }
          // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
          return (recipients, splitPerRecipientInBasisPoints, _creator == seller);
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    // 3rd priority: getRoyalties
    if (recipients.length == 0 && nftContract.supportsERC165Interface(type(IGetRoyalties).interfaceId)) {
      try IGetRoyalties(nftContract).getRoyalties{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
        address payable[] memory _recipients,
        uint256[] memory recipientBasisPoints
      ) {
        if (_recipients.length > 0 && _recipients.length == recipientBasisPoints.length) {
          bool hasRecipient = false;
          for (uint256 i = 0; i < _recipients.length; i++) {
            if (_recipients[i] != address(0)) {
              hasRecipient = true;
              if (_recipients[i] == seller) {
                isCreator = true;
              }
            }
          }
          if (hasRecipient) {
            return (_recipients, recipientBasisPoints, isCreator);
          }
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    // 4th priority: getFee*
    if (recipients.length == 0 && nftContract.supportsERC165Interface(type(IHasSecondarySaleFees).interfaceId)) {
      try IHasSecondarySaleFees(nftContract).getFeeRecipients{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
        address payable[] memory _recipients
      ) {
        if (_recipients.length > 0) {
          try IHasSecondarySaleFees(nftContract).getFeeBps{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (
            uint256[] memory recipientBasisPoints
          ) {
            if (_recipients.length == recipientBasisPoints.length) {
              bool hasRecipient = false;
              for (uint256 i = 0; i < _recipients.length; i++) {
                if (_recipients[i] != address(0)) {
                  hasRecipient = true;
                  if (_recipients[i] == seller) {
                    isCreator = true;
                  }
                }
              }
              if (hasRecipient) {
                return (_recipients, recipientBasisPoints, isCreator);
              }
            }
          } catch // solhint-disable-next-line no-empty-blocks
          {
            // Fall through
          }
        }
      } catch // solhint-disable-next-line no-empty-blocks
      {
        // Fall through
      }
    }

    // 5th priority: owner
    try IOwnable(nftContract).owner{ gas: READ_ONLY_GAS_LIMIT }() returns (address owner) {
      if (owner != address(0)) {
        if (recipients.length == 0) {
          // Only pay the owner if there wasn't a tokenCreatorPaymentAddress defined
          recipients = new address payable[](1);
          recipients[0] = payable(owner);
        }
        // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
        return (recipients, splitPerRecipientInBasisPoints, owner == seller);
      }
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Fall through
    }

    // 6th priority: tokenCreator w/o requiring 165
    try IFNDNFT721(nftContract).tokenCreator{ gas: READ_ONLY_GAS_LIMIT }(tokenId) returns (address payable _creator) {
      if (_creator != address(0)) {
        if (recipients.length == 0) {
          // Only pay the tokenCreator if there wasn't a tokenCreatorPaymentAddress defined
          recipients = new address payable[](1);
          recipients[0] = _creator;
        }
        // splitPerRecipientInBasisPoints is not relevant when only 1 recipient is defined
        return (recipients, splitPerRecipientInBasisPoints, _creator == seller);
      }
    } catch // solhint-disable-next-line no-empty-blocks
    {
      // Fall through
    }

    // If no valid payment address or creator is found, return 0 recipients
  }

  // 500 slots were added via the new SendValueWithFallbackWithdraw mixin
  uint256[500] private ______gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

import "./FoundationTreasuryNode.sol";
import "./Constants.sol";
import "./NFTMarketCore.sol";
import "./NFTMarketCreators.sol";
import "./SendValueWithFallbackWithdraw.sol";

/**
 * @notice A mixin to distribute funds when an NFT is sold.
 */
abstract contract NFTMarketFees is
  Constants,
  Initializable,
  FoundationTreasuryNode,
  NFTMarketCore,
  NFTMarketCreators,
  SendValueWithFallbackWithdraw
{
  using SafeMathUpgradeable for uint256;

  uint256 private _primaryFoundationFeeBasisPoints;
  uint256 private _secondaryFoundationFeeBasisPoints;
  uint256 private _secondaryCreatorFeeBasisPoints;

  mapping(address => mapping(uint256 => bool)) private nftContractToTokenIdToFirstSaleCompleted;

  event MarketFeesUpdated(
    uint256 primaryFoundationFeeBasisPoints,
    uint256 secondaryFoundationFeeBasisPoints,
    uint256 secondaryCreatorFeeBasisPoints
  );

  /**
   * @notice Returns true if the given NFT has not been sold in this market previously and is being sold by the creator.
   */
  function getIsPrimary(address nftContract, uint256 tokenId) public view returns (bool isPrimary) {
    address payable seller = _getSellerFor(nftContract, tokenId);
    bool isCreator;
    (, , isCreator) = _getCreatorPaymentInfo(nftContract, tokenId, seller);
    isPrimary = isCreator && !nftContractToTokenIdToFirstSaleCompleted[nftContract][tokenId];
  }

  /**
   * @notice Returns the current fee configuration in basis points.
   */
  function getFeeConfig()
    public
    view
    returns (
      uint256 primaryFoundationFeeBasisPoints,
      uint256 secondaryFoundationFeeBasisPoints,
      uint256 secondaryCreatorFeeBasisPoints
    )
  {
    return (_primaryFoundationFeeBasisPoints, _secondaryFoundationFeeBasisPoints, _secondaryCreatorFeeBasisPoints);
  }

  /**
   * @notice Returns how funds will be distributed for an Auction sale at the given price point.
   * @dev This is required for backwards compatibility with subgraph.
   */
  function getFees(
    address nftContract,
    uint256 tokenId,
    uint256 price
  )
    public
    view
    returns (
      uint256 foundationFee,
      uint256 creatorRev,
      uint256 ownerRev
    )
  {
    address payable seller = _getSellerFor(nftContract, tokenId);
    (foundationFee, , , creatorRev, , ownerRev) = _getFees(nftContract, tokenId, seller, price);
  }

  /**
   * @dev Calculates how funds should be distributed for the given sale details.
   */
  function _getFees(
    address nftContract,
    uint256 tokenId,
    address payable seller,
    uint256 price
  )
    private
    view
    returns (
      uint256 foundationFee,
      address payable[] memory creatorRecipients,
      uint256[] memory creatorShares,
      uint256 creatorRev,
      address payable ownerRevTo,
      uint256 ownerRev
    )
  {
    bool isCreator;
    (creatorRecipients, creatorShares, isCreator) = _getCreatorPaymentInfo(nftContract, tokenId, seller);
    bool isPrimary = isCreator && !nftContractToTokenIdToFirstSaleCompleted[nftContract][tokenId];

    // The SafeMath usage below should only be applicable if a huge (unrealistic) price is used
    // or fees are misconfigured.

    // Calculate the Foundation fee
    foundationFee =
      price.mul(isPrimary ? _primaryFoundationFeeBasisPoints : _secondaryFoundationFeeBasisPoints) /
      BASIS_POINTS;

    // Calculate the Creator revenue.
    if (isPrimary) {
      creatorRev = price.sub(foundationFee);
      // The owner is the creator so ownerRev is not broken out here.
    } else {
      if (creatorRecipients.length > 0) {
        if (isCreator) {
          // Non-primary sales by the creator should go to the payment address.
          creatorRev = price.sub(foundationFee);
        } else {
          creatorRev = price.mul(_secondaryCreatorFeeBasisPoints) / BASIS_POINTS;
          // If a secondary sale, calculate the owner revenue.
          ownerRevTo = seller;
          ownerRev = price.sub(foundationFee).sub(creatorRev);
        }
      } else {
        // If a secondary sale, calculate the owner revenue.
        ownerRevTo = seller;
        ownerRev = price.sub(foundationFee);
      }
    }
  }

  /**
   * @dev Distributes funds to foundation, creator, and NFT owner after a sale.
   * This call will respect the creator's payment address if defined.
   */
  // solhint-disable-next-line code-complexity
  function _distributeFunds(
    address nftContract,
    uint256 tokenId,
    address payable seller,
    uint256 price
  )
    internal
    returns (
      uint256 foundationFee,
      uint256 creatorFee,
      uint256 ownerRev
    )
  {
    address payable[] memory creatorRecipients;
    uint256[] memory creatorShares;

    address payable ownerRevTo;
    (foundationFee, creatorRecipients, creatorShares, creatorFee, ownerRevTo, ownerRev) = _getFees(
      nftContract,
      tokenId,
      seller,
      price
    );

    // Anytime fees are distributed that indicates the first sale is complete,
    // which will not change state during a secondary sale.
    // This must come after the `_getFees` call above as this state is considered in the function.
    nftContractToTokenIdToFirstSaleCompleted[nftContract][tokenId] = true;

    _sendValueWithFallbackWithdrawWithLowGasLimit(getFoundationTreasury(), foundationFee);

    if (creatorFee > 0) {
      if (creatorRecipients.length > 1) {
        uint256 maxCreatorIndex = creatorRecipients.length - 1;
        if (maxCreatorIndex > MAX_CREATOR_INDEX) {
          maxCreatorIndex = MAX_CREATOR_INDEX;
        }

        // Determine the total shares defined so it can be leveraged to distribute below
        uint256 totalShares;
        for (uint256 i = 0; i <= maxCreatorIndex; i++) {
          if (creatorShares[i] > BASIS_POINTS) {
            // If the numbers are >100% we ignore the fee recipients and pay just the first instead
            maxCreatorIndex = 0;
            break;
          }
          totalShares = totalShares.add(creatorShares[i]);
        }
        if (totalShares == 0) {
          maxCreatorIndex = 0;
        }

        // Send payouts to each additional recipient if more than 1 was defined
        uint256 totalDistributed;
        for (uint256 i = 1; i <= maxCreatorIndex; i++) {
          uint256 share = (creatorFee.mul(creatorShares[i])) / totalShares;
          totalDistributed = totalDistributed.add(share);
          _sendValueWithFallbackWithdrawWithMediumGasLimit(creatorRecipients[i], share);
        }

        // Send the remainder to the 1st creator, rounding in their favor
        _sendValueWithFallbackWithdrawWithMediumGasLimit(creatorRecipients[0], creatorFee.sub(totalDistributed));
      } else {
        _sendValueWithFallbackWithdrawWithMediumGasLimit(creatorRecipients[0], creatorFee);
      }
    }
    _sendValueWithFallbackWithdrawWithMediumGasLimit(ownerRevTo, ownerRev);
  }

  /**
   * @notice Allows Foundation to change the market fees.
   */
  function _updateMarketFees(
    uint256 primaryFoundationFeeBasisPoints,
    uint256 secondaryFoundationFeeBasisPoints,
    uint256 secondaryCreatorFeeBasisPoints
  ) internal {
    require(primaryFoundationFeeBasisPoints < BASIS_POINTS, "NFTMarketFees: Fees >= 100%");
    require(
      secondaryFoundationFeeBasisPoints.add(secondaryCreatorFeeBasisPoints) < BASIS_POINTS,
      "NFTMarketFees: Fees >= 100%"
    );
    _primaryFoundationFeeBasisPoints = primaryFoundationFeeBasisPoints;
    _secondaryFoundationFeeBasisPoints = secondaryFoundationFeeBasisPoints;
    _secondaryCreatorFeeBasisPoints = secondaryCreatorFeeBasisPoints;

    emit MarketFeesUpdated(
      primaryFoundationFeeBasisPoints,
      secondaryFoundationFeeBasisPoints,
      secondaryCreatorFeeBasisPoints
    );
  }

  uint256[1000] private ______gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

/**
 * @notice An abstraction layer for auctions.
 * @dev This contract can be expanded with reusable calls and data as more auction types are added.
 */
abstract contract NFTMarketAuction {
  /**
   * @dev A global id for auctions of any type.
   */
  uint256 private nextAuctionId;

  function _initializeNFTMarketAuction() internal {
    nextAuctionId = 1;
  }

  function _getNextAndIncrementAuctionId() internal returns (uint256) {
    return nextAuctionId++;
  }

  uint256[1000] private ______gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;
pragma abicoder v2; // solhint-disable-line

import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import "./Constants.sol";
import "./NFTMarketCore.sol";
import "./NFTMarketFees.sol";
import "./SendValueWithFallbackWithdraw.sol";
import "./NFTMarketAuction.sol";
import "./roles/FoundationAdminRole.sol";
import "./AccountMigration.sol";

/**
 * @notice Manages a reserve price auction for NFTs.
 */
abstract contract NFTMarketReserveAuction is
  Constants,
  FoundationAdminRole,
  AccountMigration,
  NFTMarketCore,
  ReentrancyGuardUpgradeable,
  SendValueWithFallbackWithdraw,
  NFTMarketFees,
  NFTMarketAuction
{
  using SafeMathUpgradeable for uint256;

  struct ReserveAuction {
    address nftContract;
    uint256 tokenId;
    address payable seller;
    uint256 duration;
    uint256 extensionDuration;
    uint256 endTime;
    address payable bidder;
    uint256 amount;
  }

  mapping(address => mapping(uint256 => uint256)) private nftContractToTokenIdToAuctionId;
  mapping(uint256 => ReserveAuction) private auctionIdToAuction;

  uint256 private _minPercentIncrementInBasisPoints;

  // This variable was used in an older version of the contract, left here as a gap to ensure upgrade compatibility
  uint256 private ______gap_was_maxBidIncrementRequirement;

  uint256 private _duration;

  // These variables were used in an older version of the contract, left here as gaps to ensure upgrade compatibility
  uint256 private ______gap_was_extensionDuration;
  uint256 private ______gap_was_goLiveDate;

  // Cap the max duration so that overflows will not occur
  uint256 private constant MAX_MAX_DURATION = 1000 days;

  uint256 private constant EXTENSION_DURATION = 15 minutes;

  event ReserveAuctionConfigUpdated(
    uint256 minPercentIncrementInBasisPoints,
    uint256 maxBidIncrementRequirement,
    uint256 duration,
    uint256 extensionDuration,
    uint256 goLiveDate
  );

  event ReserveAuctionCreated(
    address indexed seller,
    address indexed nftContract,
    uint256 indexed tokenId,
    uint256 duration,
    uint256 extensionDuration,
    uint256 reservePrice,
    uint256 auctionId
  );
  event ReserveAuctionUpdated(uint256 indexed auctionId, uint256 reservePrice);
  event ReserveAuctionCanceled(uint256 indexed auctionId);
  event ReserveAuctionBidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount, uint256 endTime);
  event ReserveAuctionFinalized(
    uint256 indexed auctionId,
    address indexed seller,
    address indexed bidder,
    uint256 f8nFee,
    uint256 creatorFee,
    uint256 ownerRev
  );
  event ReserveAuctionCanceledByAdmin(uint256 indexed auctionId, string reason);
  event ReserveAuctionSellerMigrated(
    uint256 indexed auctionId,
    address indexed originalSellerAddress,
    address indexed newSellerAddress
  );

  modifier onlyValidAuctionConfig(uint256 reservePrice) {
    require(reservePrice > 0, "NFTMarketReserveAuction: Reserve price must be at least 1 wei");
    _;
  }

  /**
   * @notice Returns auction details for a given auctionId.
   */
  function getReserveAuction(uint256 auctionId) public view returns (ReserveAuction memory) {
    return auctionIdToAuction[auctionId];
  }

  /**
   * @notice Returns the auctionId for a given NFT, or 0 if no auction is found.
   * @dev If an auction is canceled, it will not be returned. However the auction may be over and pending finalization.
   */
  function getReserveAuctionIdFor(address nftContract, uint256 tokenId) public view returns (uint256) {
    return nftContractToTokenIdToAuctionId[nftContract][tokenId];
  }

  /**
   * @dev Returns the seller that put a given NFT into escrow,
   * or bubbles the call up to check the current owner if the NFT is not currently in escrow.
   */
  function _getSellerFor(address nftContract, uint256 tokenId)
    internal
    view
    virtual
    override
    returns (address payable seller)
  {
    seller = auctionIdToAuction[nftContractToTokenIdToAuctionId[nftContract][tokenId]].seller;
    if (seller == address(0)) {
      return super._getSellerFor(nftContract, tokenId);
    }
  }

  /**
   * @notice Returns the current configuration for reserve auctions.
   */
  function getReserveAuctionConfig() public view returns (uint256 minPercentIncrementInBasisPoints, uint256 duration) {
    minPercentIncrementInBasisPoints = _minPercentIncrementInBasisPoints;
    duration = _duration;
  }

  function _initializeNFTMarketReserveAuction() internal {
    _duration = 24 hours; // A sensible default value
  }

  function _updateReserveAuctionConfig(uint256 minPercentIncrementInBasisPoints, uint256 duration) internal {
    require(minPercentIncrementInBasisPoints <= BASIS_POINTS, "NFTMarketReserveAuction: Min increment must be <= 100%");
    // Cap the max duration so that overflows will not occur
    require(duration <= MAX_MAX_DURATION, "NFTMarketReserveAuction: Duration must be <= 1000 days");
    require(duration >= EXTENSION_DURATION, "NFTMarketReserveAuction: Duration must be >= EXTENSION_DURATION");
    _minPercentIncrementInBasisPoints = minPercentIncrementInBasisPoints;
    _duration = duration;

    // We continue to emit unused configuration variables to simplify the subgraph integration.
    emit ReserveAuctionConfigUpdated(minPercentIncrementInBasisPoints, 0, duration, EXTENSION_DURATION, 0);
  }

  /**
   * @notice Creates an auction for the given NFT.
   * The NFT is held in escrow until the auction is finalized or canceled.
   */
  function createReserveAuction(
    address nftContract,
    uint256 tokenId,
    uint256 reservePrice
  ) public onlyValidAuctionConfig(reservePrice) nonReentrant {
    // If an auction is already in progress then the NFT would be in escrow and the modifier would have failed
    uint256 auctionId = _getNextAndIncrementAuctionId();
    nftContractToTokenIdToAuctionId[nftContract][tokenId] = auctionId;
    auctionIdToAuction[auctionId] = ReserveAuction(
      nftContract,
      tokenId,
      msg.sender,
      _duration,
      EXTENSION_DURATION,
      0, // endTime is only known once the reserve price is met
      address(0), // bidder is only known once a bid has been placed
      reservePrice
    );

    IERC721Upgradeable(nftContract).transferFrom(msg.sender, address(this), tokenId);

    emit ReserveAuctionCreated(
      msg.sender,
      nftContract,
      tokenId,
      _duration,
      EXTENSION_DURATION,
      reservePrice,
      auctionId
    );
  }

  /**
   * @notice If an auction has been created but has not yet received bids, the configuration
   * such as the reservePrice may be changed by the seller.
   */
  function updateReserveAuction(uint256 auctionId, uint256 reservePrice) public onlyValidAuctionConfig(reservePrice) {
    ReserveAuction storage auction = auctionIdToAuction[auctionId];
    require(auction.seller == msg.sender, "NFTMarketReserveAuction: Not your auction");
    require(auction.endTime == 0, "NFTMarketReserveAuction: Auction in progress");

    auction.amount = reservePrice;

    emit ReserveAuctionUpdated(auctionId, reservePrice);
  }

  /**
   * @notice If an auction has been created but has not yet received bids, it may be canceled by the seller.
   * The NFT is returned to the seller from escrow.
   */
  function cancelReserveAuction(uint256 auctionId) public nonReentrant {
    ReserveAuction memory auction = auctionIdToAuction[auctionId];
    require(auction.seller == msg.sender, "NFTMarketReserveAuction: Not your auction");
    require(auction.endTime == 0, "NFTMarketReserveAuction: Auction in progress");

    delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
    delete auctionIdToAuction[auctionId];

    IERC721Upgradeable(auction.nftContract).transferFrom(address(this), auction.seller, auction.tokenId);

    emit ReserveAuctionCanceled(auctionId);
  }

  /**
   * @notice A bidder may place a bid which is at least the value defined by `getMinBidAmount`.
   * If this is the first bid on the auction, the countdown will begin.
   * If there is already an outstanding bid, the previous bidder will be refunded at this time
   * and if the bid is placed in the final moments of the auction, the countdown may be extended.
   */
  function placeBid(uint256 auctionId) public payable nonReentrant {
    ReserveAuction storage auction = auctionIdToAuction[auctionId];
    require(auction.amount != 0, "NFTMarketReserveAuction: Auction not found");

    if (auction.endTime == 0) {
      // If this is the first bid, ensure it's >= the reserve price
      require(auction.amount <= msg.value, "NFTMarketReserveAuction: Bid must be at least the reserve price");
    } else {
      // If this bid outbids another, confirm that the bid is at least x% greater than the last
      require(auction.endTime >= block.timestamp, "NFTMarketReserveAuction: Auction is over");
      require(auction.bidder != msg.sender, "NFTMarketReserveAuction: You already have an outstanding bid");
      uint256 minAmount = _getMinBidAmountForReserveAuction(auction.amount);
      require(msg.value >= minAmount, "NFTMarketReserveAuction: Bid amount too low");
    }

    if (auction.endTime == 0) {
      auction.amount = msg.value;
      auction.bidder = msg.sender;
      // On the first bid, the endTime is now + duration
      auction.endTime = block.timestamp + auction.duration;
    } else {
      // Cache and update bidder state before a possible reentrancy (via the value transfer)
      uint256 originalAmount = auction.amount;
      address payable originalBidder = auction.bidder;
      auction.amount = msg.value;
      auction.bidder = msg.sender;

      // When a bid outbids another, check to see if a time extension should apply.
      if (auction.endTime - block.timestamp < auction.extensionDuration) {
        auction.endTime = block.timestamp + auction.extensionDuration;
      }

      // Refund the previous bidder
      _sendValueWithFallbackWithdrawWithLowGasLimit(originalBidder, originalAmount);
    }

    emit ReserveAuctionBidPlaced(auctionId, msg.sender, msg.value, auction.endTime);
  }

  /**
   * @notice Once the countdown has expired for an auction, anyone can settle the auction.
   * This will send the NFT to the highest bidder and distribute funds.
   */
  function finalizeReserveAuction(uint256 auctionId) public nonReentrant {
    ReserveAuction memory auction = auctionIdToAuction[auctionId];
    require(auction.endTime > 0, "NFTMarketReserveAuction: Auction was already settled");
    require(auction.endTime < block.timestamp, "NFTMarketReserveAuction: Auction still in progress");

    delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
    delete auctionIdToAuction[auctionId];

    IERC721Upgradeable(auction.nftContract).transferFrom(address(this), auction.bidder, auction.tokenId);

    (uint256 f8nFee, uint256 creatorFee, uint256 ownerRev) = _distributeFunds(
      auction.nftContract,
      auction.tokenId,
      auction.seller,
      auction.amount
    );

    emit ReserveAuctionFinalized(auctionId, auction.seller, auction.bidder, f8nFee, creatorFee, ownerRev);
  }

  /**
   * @notice Returns the minimum amount a bidder must spend to participate in an auction.
   */
  function getMinBidAmount(uint256 auctionId) public view returns (uint256) {
    ReserveAuction storage auction = auctionIdToAuction[auctionId];
    if (auction.endTime == 0) {
      return auction.amount;
    }
    return _getMinBidAmountForReserveAuction(auction.amount);
  }

  /**
   * @dev Determines the minimum bid amount when outbidding another user.
   */
  function _getMinBidAmountForReserveAuction(uint256 currentBidAmount) private view returns (uint256) {
    uint256 minIncrement = currentBidAmount.mul(_minPercentIncrementInBasisPoints) / BASIS_POINTS;
    if (minIncrement == 0) {
      // The next bid must be at least 1 wei greater than the current.
      return currentBidAmount.add(1);
    }
    return minIncrement.add(currentBidAmount);
  }

  /**
   * @notice Allows Foundation to cancel an auction, refunding the bidder and returning the NFT to the seller.
   * This should only be used for extreme cases such as DMCA takedown requests. The reason should always be provided.
   */
  function adminCancelReserveAuction(uint256 auctionId, string memory reason) public onlyFoundationAdmin {
    require(bytes(reason).length > 0, "NFTMarketReserveAuction: Include a reason for this cancellation");
    ReserveAuction memory auction = auctionIdToAuction[auctionId];
    require(auction.amount > 0, "NFTMarketReserveAuction: Auction not found");

    delete nftContractToTokenIdToAuctionId[auction.nftContract][auction.tokenId];
    delete auctionIdToAuction[auctionId];

    IERC721Upgradeable(auction.nftContract).transferFrom(address(this), auction.seller, auction.tokenId);
    if (auction.bidder != address(0)) {
      _sendValueWithFallbackWithdrawWithMediumGasLimit(auction.bidder, auction.amount);
    }

    emit ReserveAuctionCanceledByAdmin(auctionId, reason);
  }

  /**
   * @notice Allows an NFT owner and Foundation to work together in order to update the seller
   * for auctions they have listed to a new account.
   * @param signature Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}`
   * signed by the original account.
   * @dev This will gracefully skip any auctions that have already been finalized.
   */
  function adminAccountMigration(
    uint256[] calldata listedAuctionIds,
    address originalAddress,
    address payable newAddress,
    bytes calldata signature
  ) public onlyAuthorizedAccountMigration(originalAddress, newAddress, signature) {
    for (uint256 i = 0; i < listedAuctionIds.length; i++) {
      uint256 auctionId = listedAuctionIds[i];
      ReserveAuction storage auction = auctionIdToAuction[auctionId];
      // The seller would be 0 if it was finalized before this call
      if (auction.seller != address(0)) {
        require(auction.seller == originalAddress, "NFTMarketReserveAuction: Auction not created by that address");
        auction.seller = newAddress;
        emit ReserveAuctionSellerMigrated(auctionId, originalAddress, newAddress);
      }
    }
  }

  uint256[1000] private ______gap;
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./roles/FoundationOperatorRole.sol";
import "../interfaces/IERC1271.sol";

/**
 * @notice Checks for a valid signature authorizing the migration of an account to a new address.
 * @dev This is shared by both the FNDNFT721 and FNDNFTMarket, and the same signature authorizes both.
 */
abstract contract AccountMigration is FoundationOperatorRole {
  // From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/utils/cryptography
  function _isValidSignatureNow(
    address signer,
    bytes32 hash,
    bytes memory signature
  ) private view returns (bool) {
    if (Address.isContract(signer)) {
      try IERC1271(signer).isValidSignature(hash, signature) returns (bytes4 magicValue) {
        return magicValue == IERC1271(signer).isValidSignature.selector;
      } catch {
        return false;
      }
    } else {
      return ECDSA.recover(hash, signature) == signer;
    }
  }

  // From https://ethereum.stackexchange.com/questions/8346/convert-address-to-string
  function _toAsciiString(address x) private pure returns (string memory) {
    bytes memory s = new bytes(42);
    s[0] = "0";
    s[1] = "x";
    for (uint256 i = 0; i < 20; i++) {
      bytes1 b = bytes1(uint8(uint256(uint160(x)) / (2**(8 * (19 - i)))));
      bytes1 hi = bytes1(uint8(b) / 16);
      bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
      s[2 * i + 2] = _char(hi);
      s[2 * i + 3] = _char(lo);
    }
    return string(s);
  }

  function _char(bytes1 b) private pure returns (bytes1 c) {
    if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
    else return bytes1(uint8(b) + 0x57);
  }

  // From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/utils/cryptography/ECDSA.sol
  // Modified to accept messages (instead of the message hash)
  function _toEthSignedMessage(bytes memory message) private pure returns (bytes32) {
    return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(message.length), message));
  }

  /**
   * @dev Confirms the msg.sender is a Foundation operator and that the signature provided is valid.
   * @param signature Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}`
   * signed by the original account.
   */
  modifier onlyAuthorizedAccountMigration(
    address originalAddress,
    address newAddress,
    bytes memory signature
  ) {
    require(_isFoundationOperator(), "AccountMigration: Caller is not an operator");
    require(originalAddress != newAddress, "AccountMigration: Cannot migrate to the same account");
    bytes32 hash = _toEthSignedMessage(
      abi.encodePacked("I authorize Foundation to migrate my account to ", _toAsciiString(newAddress))
    );
    require(
      _isValidSignatureNow(originalAddress, hash, signature),
      "AccountMigration: Signature must be from the original account"
    );
    _;
  }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";

import "./NFTMarketFees.sol";

/**
 * @notice Adds support for a private sale of an NFT directly between two parties.
 */
abstract contract NFTMarketPrivateSale is NFTMarketFees {
  /**
   * @dev This name is used in the EIP-712 domain.
   * If multiple classes use EIP-712 signatures in the future this can move to the shared constants file.
   */
  string private constant NAME = "FNDNFTMarket";
  /**
   * @dev This is a hash of the method signature used in the EIP-712 signature for private sales.
   */
  bytes32 private constant BUY_FROM_PRIVATE_SALE_TYPEHASH =
    keccak256("BuyFromPrivateSale(address nftContract,uint256 tokenId,address buyer,uint256 price,uint256 deadline)");

  /**
   * @dev This is the domain used in EIP-712 signatures.
   * It is not a constant so that the chainId can be determined dynamically.
   * If multiple classes use EIP-712 signatures in the future this can move to a shared file.
   */
  bytes32 private DOMAIN_SEPARATOR;

  event PrivateSaleFinalized(
    address indexed nftContract,
    uint256 indexed tokenId,
    address indexed seller,
    address buyer,
    uint256 f8nFee,
    uint256 creatorFee,
    uint256 ownerRev,
    uint256 deadline
  );

  /**
   * @dev This function must be called at least once before signatures will work as expected.
   * It's okay to call this function many times. Subsequent calls will have no impact.
   */
  function _reinitialize() internal {
    uint256 chainId;
    // solhint-disable-next-line no-inline-assembly
    assembly {
      chainId := chainid()
    }
    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
        keccak256(bytes(NAME)),
        keccak256(bytes("1")),
        chainId,
        address(this)
      )
    );
  }

  /**
   * @notice Allow two parties to execute a private sale.
   * @dev The seller signs a message approving the sale, and then the buyer calls this function
   * with the msg.value equal to the agreed upon price.
   * The sale is executed in this single on-chain call including the transfer of funds and the NFT.
   */
  function buyFromPrivateSale(
    IERC721Upgradeable nftContract,
    uint256 tokenId,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public payable {
    // The signed message from the seller is only valid for a limited time.
    require(deadline >= block.timestamp, "NFTMarketPrivateSale: EXPIRED");
    // The seller must have the NFT in their wallet when this function is called.
    address payable seller = payable(nftContract.ownerOf(tokenId));

    // Scoping this block to avoid a stack too deep error
    {
      bytes32 digest = keccak256(
        abi.encodePacked(
          "\x19\x01",
          DOMAIN_SEPARATOR,
          keccak256(abi.encode(BUY_FROM_PRIVATE_SALE_TYPEHASH, nftContract, tokenId, msg.sender, msg.value, deadline))
        )
      );
      // Revert if the signature is invalid, the terms are not as expected, or if the seller transferred the NFT.
      require(ecrecover(digest, v, r, s) == seller, "NFTMarketPrivateSale: INVALID_SIGNATURE");
    }

    // This will revert if the seller has not given the market contract approval.
    nftContract.transferFrom(seller, msg.sender, tokenId);
    // Pay the seller, creator, and Foundation as appropriate.
    (uint256 f8nFee, uint256 creatorFee, uint256 ownerRev) = _distributeFunds(
      address(nftContract),
      tokenId,
      seller,
      msg.value
    );

    emit PrivateSaleFinalized(
      address(nftContract),
      tokenId,
      seller,
      msg.sender,
      f8nFee,
      creatorFee,
      ownerRev,
      deadline
    );
  }

  uint256[1000] private ______gap;
}

// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity >=0.4.24 <0.8.0;

import "../utils/AddressUpgradeable.sol";

/**
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Collection of functions related to the address type
 */
library AddressUpgradeable {
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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

/**
 * @notice Interface for AdminRole which wraps the default admin role from
 * OpenZeppelin's AccessControl for easy integration.
 */
interface IAdminRole {
  function isAdmin(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

/**
 * @notice Interface for OperatorRole which wraps a role from
 * OpenZeppelin's AccessControl for easy integration.
 */
interface IOperatorRole {
  function isOperator(address account) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../../introspection/IERC165Upgradeable.sol";

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721Upgradeable is IERC165Upgradeable {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 tokenId) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);

    /**
      * @dev Safely transfers `tokenId` token from `from` to `to`.
      *
      * Requirements:
      *
      * - `from` cannot be the zero address.
      * - `to` cannot be the zero address.
      * - `tokenId` token must exist and be owned by `from`.
      * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
      * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
      *
      * Emits a {Transfer} event.
      */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165Upgradeable {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMathUpgradeable {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT OR Apache-2.0
// solhint-disable

pragma solidity ^0.7.0;

interface IFNDNFT721 {
  function tokenCreator(uint256 tokenId) external view returns (address payable);

  function getTokenCreatorPaymentAddress(uint256 tokenId) external view returns (address payable);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

interface ITokenCreatorPaymentAddress {
  function getTokenCreatorPaymentAddress(uint256 tokenId)
    external
    view
    returns (address payable tokenCreatorPaymentAddress);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

interface ITokenCreator {
  function tokenCreator(uint256 tokenId) external view returns (address payable);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

interface IGetRoyalties {
  function getRoyalties(uint256 tokenId)
    external
    view
    returns (address payable[] memory recipients, uint256[] memory feesInBasisPoints);
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

/**
 * @notice An interface for communicating fees to 3rd party marketplaces.
 * @dev Originally implemented in mainnet contract 0x44d6e8933f8271abcf253c72f9ed7e0e4c0323b3
 */
interface IHasSecondarySaleFees {
  function getFeeRecipients(uint256 id) external view returns (address payable[] memory);

  function getFeeBps(uint256 id) external view returns (uint256[] memory);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

interface IOwnable {
  /**
   * @dev Returns the address of the current owner.
   */
  function owner() external view returns (address);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
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
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/utils/introspection/ERC165.sol
 * Modified to support Solidity 0.7 and allow checking multiple interfaces w/o checking general 165 support.
 */

import "./IERC165.sol";

/**
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library ERC165Checker {
  // As per the EIP-165 spec, no interface should ever match 0xffffffff
  bytes4 private constant _INTERFACE_ID_INVALID = 0xffffffff;

  /**
   * @dev Returns true if `account` supports the {IERC165} interface,
   */
  function supportsERC165(address account) internal view returns (bool) {
    // Any contract that implements ERC165 must explicitly indicate support of
    // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
    return
      supportsERC165Interface(account, type(IERC165).interfaceId) &&
      !supportsERC165Interface(account, _INTERFACE_ID_INVALID);
  }

  /**
   * @dev Returns true if `account` supports the interface defined by
   * `interfaceId`. Support for {IERC165} itself is queried automatically.
   *
   * See {IERC165-supportsInterface}.
   */
  function supportsInterface(address account, bytes4 interfaceId) internal view returns (bool) {
    // query support of both ERC165 as per the spec and support of _interfaceId
    return supportsERC165(account) && supportsERC165Interface(account, interfaceId);
  }

  /**
   * @dev Returns a boolean array where each value corresponds to the
   * interfaces passed in and whether they're supported or not. This allows
   * you to batch check interfaces for a contract where your expectation
   * is that some interfaces may not be supported.
   *
   * See {IERC165-supportsInterface}.
   *
   * _Available since v3.4._
   */
  function getSupportedInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool[] memory) {
    // an array of booleans corresponding to interfaceIds and whether they're supported or not
    bool[] memory interfaceIdsSupported = new bool[](interfaceIds.length);

    // query support of ERC165 itself
    if (supportsERC165(account)) {
      // query support of each interface in interfaceIds
      for (uint256 i = 0; i < interfaceIds.length; i++) {
        interfaceIdsSupported[i] = supportsERC165Interface(account, interfaceIds[i]);
      }
    }

    return interfaceIdsSupported;
  }

  /**
   * @dev Returns true if `account` supports all the interfaces defined in
   * `interfaceIds`. Support for {IERC165} itself is queried automatically.
   *
   * Batch-querying can lead to gas savings by skipping repeated checks for
   * {IERC165} support.
   *
   * See {IERC165-supportsInterface}.
   */
  function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) internal view returns (bool) {
    // query support of ERC165 itself
    if (!supportsERC165(account)) {
      return false;
    }

    // query support of each interface in _interfaceIds
    for (uint256 i = 0; i < interfaceIds.length; i++) {
      if (!supportsERC165Interface(account, interfaceIds[i])) {
        return false;
      }
    }

    // all interfaces supported
    return true;
  }

  /**
   * @notice Query if a contract implements an interface, does not check ERC165 support
   * @param account The address of the contract to query for support of an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @return true if the contract at account indicates support of the interface with
   * identifier interfaceId, false otherwise
   * @dev Assumes that account contains a contract that supports ERC165, otherwise
   * the behavior of this method is undefined. This precondition can be checked
   * with {supportsERC165}.
   * Interface identification is specified in ERC-165.
   */
  function supportsERC165Interface(address account, bytes4 interfaceId) internal view returns (bool) {
    bytes memory encodedParams = abi.encodeWithSelector(IERC165(account).supportsInterface.selector, interfaceId);
    (bool success, bytes memory result) = account.staticcall{ gas: 30000 }(encodedParams);
    if (result.length < 32) return false;
    return success && abi.decode(result, (bool));
  }
}

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.7.0;

/**
 * @dev Constant values shared across mixins.
 */
abstract contract Constants {
  uint256 internal constant BASIS_POINTS = 10000;

  uint256 internal constant READ_ONLY_GAS_LIMIT = 40000;

  /**
   * @dev Support up to 5 royalty recipients. A cap is required to ensure gas costs are not too high
   * when an auction is finalized.
   */
  uint256 internal constant MAX_CREATOR_INDEX = 4;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

/**
 * From https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.2.0/contracts/utils/introspection/IERC165.sol
 * Modified to support Solidity 0.7
 */

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
  /**
   * @dev Returns true if this contract implements the interface defined by
   * `interfaceId`. See the corresponding
   * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
   * to learn more about how these ids are created.
   *
   * This function call must use less than 30 000 gas.
   */
  function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Elliptic Curve Digital Signature Algorithm (ECDSA) operations.
 *
 * These functions can be used to verify that a message was signed by the holder
 * of the private keys of a given address.
 */
library ECDSA {
    /**
     * @dev Returns the address that signed a hashed message (`hash`) with
     * `signature`. This address can then be used for verification purposes.
     *
     * The `ecrecover` EVM opcode allows for malleable (non-unique) signatures:
     * this function rejects them by requiring the `s` value to be in the lower
     * half order, and the `v` value to be either 27 or 28.
     *
     * IMPORTANT: `hash` _must_ be the result of a hash operation for the
     * verification to be secure: it is possible to craft signatures that
     * recover to arbitrary addresses for non-hashed data. A safe way to ensure
     * this is by receiving a hash of the original message (which may otherwise
     * be too long), and then calling {toEthSignedMessageHash} on it.
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    /**
     * @dev Overload of {ECDSA-recover-bytes32-bytes-} that receives the `v`,
     * `r` and `s` signature fields separately.
     */
    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {
        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    /**
     * @dev Returns an Ethereum Signed Message, created from a `hash`. This
     * replicates the behavior of the
     * https://github.com/ethereum/wiki/wiki/JSON-RPC#eth_sign[`eth_sign`]
     * JSON-RPC method.
     *
     * See {recover}.
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

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
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
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

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
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
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
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
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
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
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
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

pragma solidity ^0.7.0;

/**
 * @dev String operations.
 */
library Strings {
    /**
     * @dev Converts a `uint256` to its ASCII `string` representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + temp % 10));
            temp /= 10;
        }
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

/**
 * @dev Interface of the ERC1271 standard signature validation method for
 * contracts as defined in https://eips.ethereum.org/EIPS/eip-1271[ERC-1271].
 *
 * from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.1.0/contracts/interfaces/IERC1271.sol
 */
interface IERC1271 {
  /**
   * @dev Should return whether the signature provided is valid for the provided data
   * @param hash      Hash of the data to be signed
   * @param signature Signature byte array associated with _data
   */
  function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}

