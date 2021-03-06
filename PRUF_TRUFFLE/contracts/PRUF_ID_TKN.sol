/**--------------------------------------------------------PRüF0.8.0
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

/**-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 * PRUF USER ID NFT CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Context.sol";
import "./Imports/utils/Counters.sol";
import "./Imports/token/ERC721/ERC721.sol";
import "./Imports/token/ERC721/ERC721Burnable.sol";
import "./Imports/token/ERC721/ERC721Pausable.sol";
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
 * The account that deploys the contract will be granted the minter, pauser, and contract admin
 * roles, as well as the default admin role, which will let it grant minter, pauser, and admin
 * roles to other accounts.
 */

contract ID_TKN is
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

    mapping(uint256 => ID) private id; // storage for extended ID data
    mapping(bytes32 => uint256) private tokenIDforName; // storage for name resolution to token ID

    Counters.Counter private _tokenIdTracker;

    constructor() ERC721("PRUF ID Token", "PRID") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

        //_setBaseURI("pruf.io");
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
            "PIDT:MOD-IA: Calling address does not belong to an admin"
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
            "PIDT:MOD-IM: Calling address does not belong to a minter"
        );
        _;
    }

    //----------------------EVENTS----------------------//
    event REPORT(string _msg);

    //----------------------Admin functions / isContractAdmin----------------------//

    /**
     * @dev Mint an Asset token
     * @param _recipientAddress - Address to mint token into
     * @param _tokenId - Token ID to mint
     * @param _tokenURI - URI string to atatch to token
     * returns Token ID of minted token
     */
    function mintPRUF_IDToken(
        address _recipientAddress,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external isMinter nonReentrant whenNotPaused returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        //MAKE URI ASSET SPECIFIC- has to incorporate the token ID
        _safeMint(_recipientAddress, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        return _tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Burn PRUF_ID token
     * @param _tokenId - ID tokenID to burn
     */
    function burnPRUF_ID(uint256 _tokenId)
        external
        isMinter
        nonReentrant
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        _burn(_tokenId);
        delete tokenIDforName[keccak256(abi.encodePacked(_tokenId))]; //remove record from name registry
        delete id[_tokenId]; //remove record from ID registry
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev remint ID Token
     * burns old token
     * @param _recipientAddress - new address for token
     * @param _tokenId - Token ID to teleport
     */
    function reMintPRUF_IDToken(address _recipientAddress, uint256 _tokenId)
        external
        isMinter
        nonReentrant
        whenNotPaused
    {
        require(_exists(_tokenId), "PIDT:RM: Cannot Remint nonexistant token");
        //^^^^^^^checks^^^^^^^^^
        string memory tokenURI = tokenURI(_tokenId);
        _burn(_tokenId);
        _safeMint(_recipientAddress, _tokenId);
        _setTokenURI(_tokenId, tokenURI);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set new token URI String -- string should eventually be a B32 hash of ID info in a standardized format - verifyable against provided ID
     * @param _tokenId - Token ID to set URI
     * @param _tokenURI - Token URI string to set
     * returns token ID
     */
    function setURI(uint256 _tokenId, string calldata _tokenURI)
        external
        isMinter
        nonReentrant
        whenNotPaused
        returns (uint256)
    {
        //^^^^^^^checks^^^^^^^^^

        _setTokenURI(_tokenId, _tokenURI);
        return _tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set new ID mapp user URI String -- string should eventually be a B32 hash of ID info in a standardized format - verifyable against provided ID
     * @param _tokenId - token ID to set URI
     * @param _tokenURI - Token URI to set
     */
    function setIdURI(uint256 _tokenId, bytes32 _tokenURI)
        external
        nonReentrant
        whenNotPaused
    {
        require(
            ownerOf(_tokenId) == _msgSender(),
            "PIDT:RM: Caller does not hold token"
        );
        //^^^^^^^checks^^^^^^^^^

        id[_tokenId].URI = _tokenURI;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set new ID mapp user URI String -- string should eventually be a B32 hash of ID info in a standardized format - verifyable against provided ID //CTS:EXAMINE new comment
     * @param _tokenId - token ID to set URI
     * @param _userName - String for Name
     */
    function setUserName(uint256 _tokenId, string calldata _userName)
        external
        nonReentrant
        whenNotPaused
    {
        require(
            ((ownerOf(_tokenId) == _msgSender()) &&
                (keccak256(abi.encodePacked(id[_tokenId].userName)) ==
                    keccak256(abi.encodePacked("")))),
            // || hasRole(MINTER_ROLE, _msgSender()), // ?DO we want this?
            "PIDT:SUN: Caller !hold token or userName is set"
        );
        bytes32 nameHash = keccak256(abi.encodePacked(_userName));
        require(
            tokenIDforName[nameHash] == 0,
            "PIDT:SUN: userName is already taken"
        );
        //^^^^^^^checks^^^^^^^^^

        tokenIDforName[nameHash] = _tokenId; //store namehash
        id[_tokenId].userName = _userName; //store username
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Set new ID data fields
     * @param _tokenId - ID of token to set trust level
     * @param _trustLevel - _trustLevel to set at token _tokenId
     */
    function setTrustLevel(uint256 _tokenId, uint256 _trustLevel)
        external
        nonReentrant
        whenNotPaused
        isMinter
    {
        //^^^^^^^checks^^^^^^^^^

        id[_tokenId].trustLevel = _trustLevel;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get ID data
     * @param _tokenId - ID token to look up
     * returns ID struct (see interfaces for struct definitions)
     */
    function IdData(uint256 _tokenId) external view returns (ID memory) {
        return id[_tokenId];
    }

    /**
     * @dev get ID trustLevel
     * @param _tokenId - token ID to check
     * returns trust level of token id
     */
    function trustLevel(uint256 _tokenId) external view returns (uint256) {
        return id[_tokenId].trustLevel;
    }

    /**
     * @dev get ID trustLevel by address (token 0 at address)
     * @param _addr - address to look up for trust level
     * returns trust level of address
     */
    function trustedLevelByAddress(address _addr)
        external
        view
        returns (uint256)
    {
        return id[tokenOfOwnerByIndex(_addr, 0)].trustLevel;
    }

    /**
     * @dev See if asset token exists
     * @param tokenId - Token ID to set URI
     * returns 170 if token exists, otherwise 0
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
            "PIDT:TF: transfer caller is not owner nor approved"
        );
        require(
            _to == _from,
            "PIDT:TF: Token not tra_nsferrable with standard ERC721 protocol. Must be reminted by admin to new address"
        );
        //^^^^^^^checks^^^^^^^^

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
    ) public override {
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
            "PIDT:STF: Transfer caller !owner nor approved"
        );
        require(
            _to == _from,
            "PIDT:STF: Token not transferrable with standard ERC721 protocol. Must be reminted by admin to new address"
        );

        //^^^^^^^checks^^^^^^^^^

        _safeTransfer(_from, _from, _tokenId, _data);
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
            "PIDT:P: ERC721PresetMinterPauserAutoId: must have pauser role to pause"
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
            "PIDT:UP: ERC721PresetMinterPauserAutoId: must have pauser role to unpause"
        );
        //^^^^^^^checks^^^^^^^^
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
