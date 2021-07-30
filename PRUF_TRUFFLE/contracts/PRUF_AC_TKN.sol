/*--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 * PRUF ASSET CLASS NODE NFT CONTRACT
 *-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Context.sol";
import "./Imports/utils/Counters.sol";
import "./Imports/token/ERC721/ERC721.sol";
import "./Imports/token/ERC721/ERC721Burnable.sol";
import "./Imports/token/ERC721/ERC721Pausable.sol";
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
 * The account that deploys the contract will be granted the minter, pauser, and contract admin
 * roles, as well as the default admin role, which will let it grant minter, pauser, and admin
 * roles to other accounts.
 */

contract AC_TKN is
    ReentrancyGuard,
    Context,
    AccessControl,
    ERC721Burnable,
    ERC721Pausable
{
    using Counters for Counters.Counter;

    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    constructor() ERC721("PRUF Asset Class Node Token", "PRFN") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //----------------------Modifiers----------------------//

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "AT:MOD-IA: Calling address !contract admin"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has MINTER_ROLE
     */
    modifier isMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "AT:MOD-IM: Calling address !minter"
        );
        _;
    }

    //----------------------Admin functions - isContractAdmin or isMinter----------------------//

    /**
     * @dev Mint a Node token
     * @param _recipientAddress - Address to mint token into
     * @param _tokenId - Token ID to mint
     * @param _tokenURI - URI string to atatch to token
     *
     * @return Token ID of minted token
     */
    function mintACToken(
        address _recipientAddress,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external isMinter nonReentrant returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        _safeMint(_recipientAddress, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        return _tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev remint Asset Class Token - must be minter
     * burns old token
     * Sends new token to specified address
     * @param _recipientAddress - new address for token
     * @param _tokenId - Token ID to teleport
     * @param _tokenURI - URI to check match for safety
     */
    function teleportACToken(
        address _recipientAddress,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external isMinter nonReentrant {
        require(_exists(_tokenId), "ACT:RM: AC !exist");
        require(
            keccak256(abi.encodePacked(_tokenURI)) ==
                keccak256(abi.encodePacked(tokenURI(_tokenId))),
            "ACT:RM:New token URI != URI"
        );
        //^^^^^^^checks^^^^^^^^^

        _burn(_tokenId);
        _safeMint(_recipientAddress, _tokenId);
        _setTokenURI(_tokenId, tokenURI(_tokenId));
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev See if node token exists
     * @param tokenId - Token ID to set URI
     *
     * @return 170 or 0 (true or false)
     */
    function tokenExists(uint256 tokenId) external view returns (uint256) {
        if (_exists(tokenId)) {
            return 170;
        } else {
            return 0;
        }
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the _msgSender() to be the owner, approved, or operator.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override nonReentrant whenNotPaused {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ACT:TF: Caller !ApprovedOrOwner"
        );
        //^^^^^^^checks^^^^^^^^^

        _transfer(_from, _to, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public override whenNotPaused {
        //^^^^^^^checks^^^^^^^^^

        safeTransferFrom(_from, _to, _tokenId, "");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the _msgSender() to be the owner, approved, or operator
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory _data
    ) public virtual override nonReentrant whenNotPaused {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ACT:STF: Caller !ApprovedOrOwner"
        );
        //^^^^^^^checks^^^^^^^^^

        _safeTransfer(_from, _to, _tokenId, _data);
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
            "ACT:P: Caller !have pauser role"
        );
        //^^^^^^^checks^^^^^^^^^
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
            "ACT:UP: Caller !have pauser role"
        );
        //^^^^^^^checks^^^^^^^^^
        _unpause();
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev all paused functions are blocked here (inside ERC720Pausable.sol)
     * @param _from - from address
     * @param _to - to address
     * @param _tokenId - token ID to transfer
     */
    function _beforeTokenTransfer(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal virtual override(ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }
}
