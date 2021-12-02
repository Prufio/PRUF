/*--------------------------------------------------------PRüF0.8.8
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

/**-----------------------------------------------------------------
 * PRUF NODE_TKN
 * Node token contract. PRüF Node tokens grant permissions for node management and asset minting.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

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
contract NODE_TKN is
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
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    address internal STOR_Address;
    STOR_Interface internal STOR;

    address internal NODE_STOR_Address;
    NODE_STOR_Interface internal NODE_STOR;

    uint256 trustedAgentEnabled = 1;

    constructor() ERC721("PRUF Node Token", "PRFN") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
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
            "AT:MOD-ICA:Calling address does not belong to a contract admin"
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

    //----------------------Public Functions----------------------//

    !!!!WRITE A UNIVERSALLY CALLABLE FUNCTION THAT TX's a bit6 node token to its verifying ID token address

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
        require(_exists(tokenId), "NT:TU: URI query for nonexistent token");
        //^^^^^^^checks^^^^^^^^^

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
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     * @param interfaceId - ID of interface
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
        //^^^^^^^interactions^^^^^^^^^
    }

    //----------------------External Functions----------------------//

    /** DPS:TEST NEW
     * @dev Set storage contract to interface with
     * @param _storageAddress - Storage contract address
     */
    function setStorageContract(address _storageAddress)
        external
        isContractAdmin
    {
        require(_storageAddress != address(0), "AT:SSC:Storage address = 0");
        //^^^^^^^checks^^^^^^^^^

        STOR = STOR_Interface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /** DPS:TEST NEW
     * @dev Address Setters  - resolves addresses from storage and sets local interfaces
     */
    function resolveContractAddresses() external isContractAdmin {
        //CTS:Only needs these contracts as deployed
        //^^^^^^^checks^^^^^^^^^
        NODE_STOR_Address = STOR.resolveContractAddress("NODE_STOR");
        NODE_STOR = NODE_STOR_Interface(NODE_STOR_Address);
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /**
     * @dev Mint a Node token
     * @param _recipientAddress - Address to mint token into
     * @param _tokenId - Token ID to mint
     * @param _tokenURI - URI string to atatch to token
     * @return Token ID of minted token
     */
    function mintNodeToken(
        address _recipientAddress,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external isMinter nonReentrant returns (uint256) {
        require (_tokenId <= 4294967295); //uint32 cap DPS:TEST:NEW
        //^^^^^^^checks^^^^^^^^^

        _safeMint(_recipientAddress, _tokenId);
        _setTokenURI(_tokenId, _tokenURI);
        //^^^^^^^effects^^^^^^^^^

        return _tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev See if node token exists
     * @param tokenId - Token ID to set URI
     * @return 170 or 0 (true or false)
     */
    function tokenExists(uint256 tokenId) external view returns (uint256) {
        if (_exists(tokenId)) {
            return 170;
        } else {
            return 0;
        }
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
    function pause() external virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "NT:P: Caller !have pauser role"
        );
        //^^^^^^^checks^^^^^^^^^

        _pause();
        //^^^^^^^effects^^^^^^^^^
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
            "NT:UP: Caller !have pauser role"
        );
        //^^^^^^^checks^^^^^^^^^

        _unpause();
        //^^^^^^^effects^^^^^^^^^
    }

    //----------------------Internal Functions----------------------//

    /**
     * @dev returns base URI of NODE_TKN(s)
     * @return default URI of NODE_TKN(s)
     */
    function _baseURI() internal view virtual override returns (string memory) {
        //^^^^^^^checks^^^^^^^^^

        return _baseTokenURI;
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
        uint256 bit6 = NODE_STOR.getSwitchAt(uint32(tokenId), 6); //safe because no nodes can be minted above uint32

        if (bit6 == 1) { //DPS:NEW TEST
            ExtendedNodeData memory extendedNodeInfo = NODE_STOR
                .getExtendedNodeData(uint32(tokenId)); //safe because no nodes can be minted above uint32

            require(
                (to ==
                    IERC721(extendedNodeInfo.idProviderAddr).ownerOf(
                        extendedNodeInfo.idProviderTokenId
                    )), // if switch6 = 1 verify that token is being sent to the IDroot token address
                "NT:BTT: Token can only be sent to the address that holds the root-of-identity token."
            );
        }
        //^^^^^^^checks^^^^^^^^^

        super._beforeTokenTransfer(from, to, tokenId);
        //^^^^^^^effects^^^^^^^^^
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
        require(_exists(tokenId), "NT:STU: URI set of nonexistent token");
        //^^^^^^^checks^^^^^^^^^

        _tokenURIs[tokenId] = _tokenURI;
        //^^^^^^^effects^^^^^^^^^
    }
}
