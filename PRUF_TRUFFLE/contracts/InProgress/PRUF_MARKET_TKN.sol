/**--------------------------------------------------------PRüF0.8.7
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 * PRUF CONSIGNMENT NFT CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../Imports/token/ERC721/ERC721.sol";
import "../Imports/token/ERC721/extensions/ERC721Enumerable.sol";
import "../Imports/token/ERC721/extensions/ERC721Burnable.sol";
import "../Imports/token/ERC721/extensions/ERC721Pausable.sol";
import "../Imports/token/ERC721/extensions/ERC721URIStorage.sol";
import "../Imports/access/AccessControlEnumerable.sol";
import "../Imports/utils/Context.sol";
import "../Imports/utils/Counters.sol";
import "../Imports/security/ReentrancyGuard.sol";

import "../Resources/RESOURCE_PRUF_INTERFACES.sol";
import "../Resources/RESOURCE_PRUF_TKN_INTERFACES.sol";

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

contract MARKET_TKN is
    ReentrancyGuard,
    Context,
    AccessControlEnumerable,
    ERC721Enumerable,
    ERC721Burnable,
    ERC721Pausable
{
    using Counters for Counters.Counter;
    using Strings for uint256;

    //mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    Counters.Counter private _tokenIdTracker;

    string private _baseTokenURI;

    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TAG_ADMIN_ROLE = keccak256("TAG_ADMIN_ROLE");
    bytes32 public constant TRUSTED_AGENT_ROLE =
        keccak256("TRUSTED_AGENT_ROLE");

    uint256 trustedAgentEnabled = 1;

    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    constructor() ERC721("PRUF Consignment Token", "PRCT") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "AT:MOD-IA:Calling address does not belong to a contract admin"
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
            "AT:MOD-IM:Calling address does not belong to a minter"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has TRUSTED_AGENT_ROLE and Trusted Agent role is not disabled
     */
    modifier isTrustedAgent() {
        require(
            hasRole(TRUSTED_AGENT_ROLE, _msgSender()),
            "AT:MOD-ITA:Must have TRUSTED_AGENT_ROLE"
        );
        require(
            trustedAgentEnabled == 1,
            "AT:MOD-ITA:Trusted Agent function permanently disabled - use allowance / transferFrom pattern"
        );
        _;
    }

    ////----------------------Regular operations----------------------//

    event REPORT(string _msg);

    /**
     * @dev Mint new consignment Tag token, store consignment data
     * @param _recipientAddress - Address to mint token into
     * @param _tokenId - Token ID to mint
     * @param _tokenURI - URI string to atatch to token
     * returns Token ID of minted token
     */
    function mintConsignmentToken(
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
     * @dev Set new token URI String
     * @param tokenId - Token ID to set URI
     * @param _tokenURI - URI string to atatch to token
     * returns Token ID
     */
    function setURI(uint256 tokenId, string calldata _tokenURI)
        external
        returns (uint256)
    {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "AT:SURI:Caller !owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^

        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev See if consignment token exists
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

    // /**
    //  * @dev Transfers the ownership of a given token ID to another address.
    //  * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
    //  * Requires the _msgSender() to be the owner, approved, or operator.
    //  * @param _from current owner of the token
    //  * @param _to address to receive the ownership of the given token ID
    //  * @param _tokenId uint256 ID of the token to be transferred
    //  */
    // function transferFrom(
    //     address _from,
    //     address _to,
    //     uint256 _tokenId
    // ) public override nonReentrant {
    //     require(
    //         _isApprovedOrOwner(_msgSender(), _tokenId),
    //         "AT:TF:Transfer caller is not owner nor approved"
    //     );

    //     //^^^^^^^checks^^^^^^^^
    //     _transfer(_from, _to, _tokenId);
    //     //^^^^^^^effects^^^^^^^^^
    // }

    // /**
    //  * @dev Safely transfers the ownership of a given token ID to another address
    //  * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
    //  * which is called upon a safe transfer, and return the magic value
    //  * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    //  * the transfer is reverted.
    //  * Requires the _msgSender() to be the owner, approved, or operator
    //  * @param _from current owner of the token
    //  * @param _to address to receive the ownership of the given token ID
    //  * @param _tokenId uint256 ID of the token to be transferred
    //  */
    // function safeTransferFrom(
    //     address _from,
    //     address _to,
    //     uint256 _tokenId
    // ) public override {
    //     safeTransferFrom(_from, _to, _tokenId, "");
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    // /**
    //  * @dev Safely transfers the ownership of a given token ID to another address
    //  * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
    //  * which is called upon a safe transfer, and return the magic value
    //  * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
    //  * the transfer is reverted.
    //  * Requires the _msgSender() to be the owner, approved, or operator
    //  * @param _from current owner of the token
    //  * @param _to address to receive the ownership of the given token ID
    //  * @param _tokenId uint256 ID of the token to be transferred
    //  * @param _data bytes data to send along with a safe transfer check
    //  */
    // function safeTransferFrom(
    //     address _from,
    //     address _to,
    //     uint256 _tokenId,
    //     bytes memory _data
    // ) public virtual override nonReentrant {
    //     require(
    //         _isApprovedOrOwner(_msgSender(), _tokenId),
    //         "AT:STF:Transfer caller !owner nor approved"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     //^^^^^^^effects^^^^^^^^^
    //     _safeTransfer(_from, _to, _tokenId, _data);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    /**
     * @dev Safely burns an consignment token, consignment data
     * @param _tokenId - Token ID to Burn
     */
    function trustedAgentBurn(uint256 _tokenId)
        external
        nonReentrant
        whenNotPaused
        isTrustedAgent
    {
        //^^^^^^^checks^^^^^^^^^
        if (_exists(_tokenId)) {
            _burn(_tokenId);
        }

        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI query for nonexistent token"
        );

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
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
    function pause() external virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "A:P: Caller !have pauser role"
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
    function unpause() external virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "A:UP: Caller !have pauser role"
        );
        //^^^^^^^checks^^^^^^^^^

        _unpause();
        //^^^^^^^interactions^^^^^^^^^
    }
    
    /**
     * @dev all paused functions are blocked here (inside ERC720Pausable.sol)
     * @param from - from address
     * @param to - to address
     * @param tokenId - token ID to transfer
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    /**
     * @dev gets baseURI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
