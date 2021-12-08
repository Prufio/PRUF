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

//DPS:NEW:NODE_TKN must have NODE_ADMIN_ROLE in NODE_STOR

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

    address internal NODE_STOR_Address;
    NODE_STOR_Interface internal NODE_STOR;

    uint256 trustedAgentEnabled = 1;

    constructor() ERC721("PRUF Node Token", "PRFN") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //----------------------Modifiers----------------------//

    /** DPS:TEST:NEW
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "NT:MOD-ICA:Calling address does not belong to a contract admin"
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
            "NT:MOD-IM: Calling address !minter"
        );
        _;
    }

    //----------------------Public Functions----------------------//

    /**
     * @dev Universally callable function that sends a node token to the address of its referenced ID token,
     * or removes the bit6 flag if its ID token does not exist.
     */
    function fixOrphanedNode(uint256 _thisNode) public {
        require(_thisNode <= 4294967295, "NT:FON:Node ID out of range");
        uint32 node = uint32(_thisNode);
        uint256 bit6 = NODE_STOR.getSwitchAt(node, 6);

        if (bit6 == 1) {
            ExtendedNodeData memory extendedNodeInfo = NODE_STOR
                .getExtendedNodeData(node); //safe because no node tokens can be minted beyond uint32
            address holderOfIdToken;
            //DPS:TEST:NEW test this by calling it on tokens that dont exist as well as ones that do.
            //NOT SURE THIS WILL WORK AS WRITTEN!!!!
            try
                IERC721(extendedNodeInfo.idProviderAddr).ownerOf(
                    extendedNodeInfo.idProviderTokenId
                )
            returns (address addr) {
                //if the try works, should transfer _thisNode to the address of the ID token
                holderOfIdToken = addr;
                _transfer(ownerOf(_thisNode), holderOfIdToken, _thisNode);
            } catch Error(string memory) {
                //if the try fails (ID token not exist) then clear the bit6 and ID token data from the node
                NODE_STOR.unlinkExternalId(node);
            }
        }
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

    /** DPS:TEST NEW CTS:EXAMINE NOT NEEDED, just need to add NODE_STOR
     * @dev Set storage contract to interface with
     * @param _nodeStorageAddress - Storage contract address
     */
    function setNodeStorageContract(
        address _nodeStorageAddress //CTS:EXAMINE why is this needed?
    ) external isContractAdmin {
        require(
            _nodeStorageAddress != address(0),
            "NT:SNSC:Storage address = 0"
        );
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR = NODE_STOR_Interface(NODE_STOR_Address);
        //^^^^^^^effects^^^^^^^^^
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
        require(_tokenId <= 4294967295); //uint32 cap DPS:TEST:NEW
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

    /** DPS:NEW:TEST
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
