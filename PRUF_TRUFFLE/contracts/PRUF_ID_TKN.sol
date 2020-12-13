/*--------------------------------------------------------PRuF0.7.1
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 * PRUF USER ID NFT CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./Imports/access/AccessControl.sol";
import "./Imports/GSN/Context.sol";
import "./Imports/utils/Counters.sol";
import "./Imports/token/ERC721/ERC721.sol";
import "./Imports/token/ERC721/ERC721Burnable.sol";
import "./Imports/token/ERC721/ERC721Pausable.sol";
//import "./Imports/access/Ownable.sol";
import "./PRUF_INTERFACES.sol";
import "./Imports/utils/ReentrancyGuard.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */

contract ID_TKN is
    ReentrancyGuard,
    Context,
    AccessControl,
    ERC721Burnable,
    ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    constructor() public ERC721("PRüF ID Token", "PRID") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender()); //ALL CONTRACTS THAT MINT ASSET TOKENS
        _setupRole(PAUSER_ROLE, _msgSender());

        //_setBaseURI("pruf.io");
    }

    event REPORT(string _msg);

    modifier isAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "AT:MOD-IA:Calling address does not belong to an admin"
        );
        _;
    }

    modifier isMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "AT:MOD-IA:Calling address does not belong to a minter"
        );
        _;
    }

    //----------------------Admin functions / isAdmin----------------------//

    /*
     * @dev Mint new PRUF_ID token
     */
    function mintPRUF_IDToken(address _recipientAddress, uint256 tokenId)
        external
        isMinter
        nonReentrant
        whenNotPaused
        returns (uint256)
    {
        //^^^^^^^checks^^^^^^^^^

        //MAKE URI ASSET SPECIFIC- has to incorporate the token ID
        _safeMint(_recipientAddress, tokenId);
        _setTokenURI(tokenId, "https://pruf.io/ID");
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remint Asset Token
     * must set a new and unuiqe rgtHash
     * burns old token
     * Sends new token to original Caller
     */
    function reMintPRUF_IDToken(address _recipientAddress, uint256 tokenId)
        external
        isMinter
        nonReentrant
        whenNotPaused
        returns (uint256)
    {
        require(_exists(tokenId), "PIDT:RM:Cannot Remint nonexistant token");
        //^^^^^^^checks^^^^^^^^^
        string memory tokenURI = tokenURI(tokenId);
        _burn(tokenId);
        _safeMint(_recipientAddress, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set new token URI String -- string should eventually be a B32 hash of ID info in a standardized format - verifyable against provided ID
     */
    function setURI(uint256 tokenId, string calldata _tokenURI)
        external
        isMinter
        nonReentrant
        whenNotPaused
        returns (uint256)
    {
        //^^^^^^^checks^^^^^^^^^

        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev See if token exists
     */
    function tokenExists(uint256 tokenId) external view returns (uint8) {
        if (_exists(tokenId)) {
            return 170;
        } else {
            return 0;
        }
    }

    /**
     * @dev Blocks the transfer of a given token ID to another address
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the _msgSender() to be the owner, approved, or operator.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override nonReentrant whenNotPaused {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "PIDT:TF:transfer caller is not owner nor approved"
        );
        require(
            to == from,
            "PIDT:TF:Token not transferrable with standard ERC721 protocol. Must be reminted by admin to new address"
        );
        //^^^^^^^checks^^^^^^^^

        _transfer(from, to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely blocks the transfer of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely blocks the transfer of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override nonReentrant whenNotPaused {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "PIDT:STF: transfer caller is not owner nor approved"
        );
        require(
            to == from,
            "PIDT:STF:Token not transferrable with standard ERC721 protocol. Must be reminted by admin to new address"
        );

        //^^^^^^^checks^^^^^^^^^

        _safeTransfer(from, from, tokenId, _data);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have pauser role to pause"
        );
        //^^^^^^^checks^^^^^^^^
        _pause();
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have pauser role to unpause"
        );
        //^^^^^^^checks^^^^^^^^
        _unpause();
        //^^^^^^^interactions^^^^^^^^^
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
