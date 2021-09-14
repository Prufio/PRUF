/**--------------------------------------------------------PRüF0.8.6
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
 * Check and see if A_TKN can be permitted in all nodes to prevent safeTransferFrom->writeRecord conflict due to it not being a default authorized contract for node s
 *-----------------------------------------------------------------
 * PRUF ASSET NFT CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Imports/token/ERC721/ERC721.sol";
import "./Imports/token/ERC721/extensions/ERC721Enumerable.sol";
import "./Imports/token/ERC721/extensions/ERC721Burnable.sol";
import "./Imports/token/ERC721/extensions/ERC721Pausable.sol";
import "./Imports/token/ERC721/extensions/ERC721URIStorage.sol";
import "./Imports/access/AccessControlEnumerable.sol";
import "./Imports/utils/Context.sol";
import "./Imports/utils/Counters.sol";
import "./Imports/security/ReentrancyGuard.sol";

import "./RESOURCE_PRUF_INTERFACES.sol";
import "./RESOURCE_PRUF_TKN_INTERFACES.sol";

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
contract ERC721MinterPauserAutoId is
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
    bytes32 public constant TRUSTED_AGENT_ROLE =
        keccak256("TRUSTED_AGENT_ROLE");

    uint256 trustedAgentEnabled = 1;

    mapping(address => uint256) private coldWallet;

    address internal STOR_Address;
    address internal RCLR_Address;
    address internal NODE_MGR_Address;
    address internal NODE_TKN_Address;
    STOR_Interface internal STOR;
    RCLR_Interface internal RCLR;
    NODE_MGR_Interface internal NODE_MGR;
    NODE_TKN_Interface internal NODE_TKN;

    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    constructor() ERC721("PRUF Asset Token", "PRAT") {
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

    //----------------------Admin functions / isContractAdmin ----------------------//

    /**
     * @dev ----------------------------------------PERMANANTLY !!!  Kills trusted agent and payable functions
     * this will break the functionality of current payment mechanisms.
     *
     * The workaround for this is to create an allowance for pruf contracts for a single or multiple payments,
     * either ahead of time "loading up your PRUF account" or on demand with an operation. On demand will use quite a bit more gas.
     * "preloading" should be pretty gas efficient, but will add an extra step to the workflow, requiring users to have sufficient
     * PRuF "banked" in an allowance for use in the system.
     * @param _key - set to 170 to PERMENANTLY REMOVE TRUSTED AGENT CAPABILITY
     */
    function killTrustedAgent(uint256 _key) external isContractAdmin {
        if (_key == 170) {
            trustedAgentEnabled = 0; // !!! THIS IS A PERMANENT ACTION AND CANNOT BE UNDONE
        }
    }

    /**
     * @dev Set storage contract to interface with
     * @param _storageAddress - Storage contract address to set
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

    /**
     * @dev Address Setters  - resolves addresses from storage and sets local interfaces
     */
    function resolveContractAddresses() external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        RCLR_Address = STOR.resolveContractAddress("RCLR");
        RCLR = RCLR_Interface(RCLR_Address);

        NODE_MGR_Address = STOR.resolveContractAddress("NODE_MGR");
        NODE_MGR = NODE_MGR_Interface(NODE_MGR_Address);

        NODE_TKN_Address = STOR.resolveContractAddress("NODE_TKN");
        NODE_TKN = NODE_TKN_Interface(NODE_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    ////----------------------Regular operations----------------------//

    /**
     * @dev Set calling wallet to a "cold Wallet" that cannot be manipulated by TRUSTED_AGENT or PAYABLE permissioned functions
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS and must be unset from cold before it can interact with
     * contract functions.
     */
    function setColdWallet() external {
        coldWallet[_msgSender()] = 170;
    }

    /**
     * @dev un-set calling wallet to a "cold Wallet", enabling manipulation by TRUSTED_AGENT and PAYABLE permissioned functions
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS and must be unset from cold before it can interact with
     * contract functions.
     */
    function unSetColdWallet() external {
        coldWallet[_msgSender()] = 0;
    }

    /**
     * @dev return an adresses "cold wallet" status
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS
     * @param _addr - address to check
     * returns 170 if adress is set to "cold wallet" status
     */
    function isColdWallet(address _addr) public view returns (uint256) {
        return coldWallet[_addr];
    }

    event REPORT(string _msg);

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
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

    // /**
    //  * @dev Creates a new token for `to`. Its token ID will be automatically
    //  * assigned (and available on the emitted {IERC721-Transfer} event), and the token
    //  * URI autogenerated based on the base URI passed at construction.
    //  *
    //  * See {ERC721-_mint}.
    //  *
    //  * Requirements:
    //  *
    //  * - the caller must have the `MINTER_ROLE`.
    //  */
    // function mint(address to) public virtual {
    //     require(hasRole(MINTER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have minter role to mint");

    //     // We cannot just use balanceOf to create the new tokenId because tokens
    //     // can be burned (destroyed), so we need a separate counter.
    //     _mint(to, _tokenIdTracker.current());
    //     _tokenIdTracker.increment();
    // }

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
        _pause();
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
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
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
