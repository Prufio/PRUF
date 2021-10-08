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
 * PRUF A_TKN
 * ASSET NFT CONTRACT - PRüF Asset tokens. Supports trusted agent role.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Imports/token/ERC721/extensions/ERC721Enumerable.sol";
import "../Imports/token/ERC721/extensions/ERC721Burnable.sol";
import "../Imports/token/ERC721/extensions/ERC721Pausable.sol";
import "../Imports/token/ERC721/extensions/ERC721URIStorage.sol";
import "../Imports/access/AccessControlEnumerable.sol";
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
contract A_TKN is
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
    address internal NODE_STOR_Address;
    address internal NODE_TKN_Address;
    STOR_Interface internal STOR;
    RCLR_Interface internal RCLR;
    NODE_MGR_Interface internal NODE_MGR;
    NODE_STOR_Interface internal NODE_STOR;
    NODE_TKN_Interface internal NODE_TKN;

    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    constructor() ERC721("PRUF Asset Token", "PRAT") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //---------------------------------------Modifiers-------------------------------

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

    //---------------------------------------Public Functions-------------------------------

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     * @param tokenId - token to have URI checked
     * @return URI of token
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "AT:TU: URI query for nonexistent token");
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
    ) public override nonReentrant {
        bytes32 _idxHash = bytes32(_tokenId);
        Record memory rec = getRecord(_idxHash);

        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "AT:TF:Transfer caller is not owner nor approved"
        );
        require(
            rec.assetStatus == 51,
            "AT:TF:Asset not in transferrable status"
        );
        //^^^^^^^checks^^^^^^^^

        rec.numberOfTransfers = 170;

        rec.rightsHolder = B320xF_;

        writeRecord(_idxHash, rec);
        _transfer(_from, _to, _tokenId);
        //^^^^^^^effects^^^^^^^^^
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
        //^^^^^^^checks^^^^^^^^

        safeTransferFrom(_from, _to, _tokenId, "");
        //^^^^^^^effects^^^^^^^^^
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
    ) public virtual override nonReentrant {
        bytes32 _idxHash = bytes32(_tokenId);
        Record memory rec = getRecord(_idxHash);
        (uint8 isAuth, ) = STOR.ContractInfoHash(_to, 0); // trailing comma because does not use the returned hash

        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "AT:STF:Transfer caller !owner nor approved"
        );
        require( // ensure that status 70 assets are only sent to an actual PRUF contract
            (rec.assetStatus != 70) || (isAuth > 0),
            "AT:STF:Cannot send status 70 asset to unauthorized address"
        );
        require(
            (rec.assetStatus == 51) || (rec.assetStatus == 70),
            "AT:STF:Asset !in transferrable status"
        );
        require(
            _to != address(0),
            "AT:STF:Cannot transfer asset to zero address. Use discard."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.numberOfTransfers = 170;
        rec.rightsHolder = B320xF_;

        writeRecord(_idxHash, rec);
        _safeTransfer(_from, _to, _tokenId, _data);
        //^^^^^^^effects^^^^^^^^^
    }

    //---------------------------------------External Functions-------------------------------

    /**
     * @dev !!! PERMANANTLY !!!  Kills trusted agent and payable functions
     * this will break the functionality of current payment mechanisms.
     *
     * The workaround for this is to create an allowance for pruf contracts for a single or multiple payments,
     * either ahead of time "loading up your PRUF account" or on demand with an operation. On demand will use quite a bit more gas.
     * "preloading" should be pretty gas efficient, but will add an extra step to the workflow, requiring users to have sufficient
     * PRuF "banked" in an allowance for use in the system.
     * @param _key - set to 170 to PERMENANTLY REMOVE TRUSTED AGENT CAPABILITY
     */
    function killTrustedAgent(uint256 _key) external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        if (_key == 170) {
            trustedAgentEnabled = 0; // !!! THIS IS A PERMANENT ACTION AND CANNOT BE UNDONE
        }
        //^^^^^^^effects^^^^^^^^^
    }

    /**
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
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /**
     * @dev return an adresses "cold wallet" status
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS
     * @param _addr - address to check
     * @return 170 if adress is set to "cold wallet" status
     */
    function isColdWallet(address _addr) public view returns (uint256) {
        return coldWallet[_addr];
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set calling wallet to a "cold Wallet" that cannot be manipulated by TRUSTED_AGENT or PAYABLE permissioned functions
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS and must be unset from cold before it can interact with
     * contract functions.
     */
    function setColdWallet() external {
        coldWallet[_msgSender()] = 170;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev un-set calling wallet to a "cold Wallet", enabling manipulation by TRUSTED_AGENT and PAYABLE permissioned functions
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS and must be unset from cold before it can interact with
     * contract functions.
     */
    function unSetColdWallet() external {
        //^^^^^^^checks^^^^^^^^^

        coldWallet[_msgSender()] = 0;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Mint an Asset token (may mint only to node holder depending on flags)
     * @param _recipientAddress - Address to mint token into
     * @param _tokenId - Token ID to mint
     * @return Token ID of minted token
     */
    function mintAssetToken(address _recipientAddress, uint256 _tokenId)
        external
        isMinter
        nonReentrant
        returns (uint256)
    {
        //^^^^^^^checks^^^^^^^^^

        _safeMint(_recipientAddress, _tokenId);
        //^^^^^^^effects^^^^^^^^^

        return (_tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set new token URI String
     * @param _tokenId - Token ID to set URI
     * @param _tokenURI - URI string to atatch to token
     * @return tokenId
     */
    function setURI(uint256 _tokenId, string calldata _tokenURI)
        external
        returns (uint256)
    {
        bytes32 _idxHash = bytes32(_tokenId);
        Record memory rec = getRecord(_idxHash);

        if (NODE_STOR.getSwitchAt(rec.node, 1) == 1) {
            //if switch at bit 1 (0) is set
            string memory oldTokenURI = tokenURI(_tokenId);

            require(
                bytes(oldTokenURI).length == 0,
                "AT:SU:URI is set, and immutable"
            );

            require(
                NODE_TKN.ownerOf(rec.node) == _msgSender(),
                "AT:SU:Caller !NTH"
            );
        }

        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "AT:SU:Caller !owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^

        _setTokenURI(_tokenId, _tokenURI);
        return _tokenId;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev See if asset token exists
     * @param tokenId - Token ID to set URI
     * @return 170 if token exists, otherwise 0
     */
    function tokenExists(uint256 tokenId) external view returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        if (_exists(tokenId)) {
            return 170;
        } else {
            return 0;
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address by a TRUSTED_AGENT.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the _msgSender() to be the owner, approved, or operator.
     * @param _from current owner of the token
     * @param _to address to receive the ownership of the given token ID
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function trustedAgentTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external nonReentrant isTrustedAgent {
        bytes32 _idxHash = bytes32(_tokenId);
        Record memory rec = getRecord(_idxHash);

        require(
            rec.assetStatus == 51,
            "AT:TATF:Asset not in transferrable status"
        );
        require(
            isColdWallet(ownerOf(_tokenId)) != 170,
            "AT:TATF:Holder is cold Wallet"
        );
        //^^^^^^^checks^^^^^^^^

        rec.numberOfTransfers = 170;

        rec.rightsHolder = B320xF_;

        writeRecord(_idxHash, rec);
        _transfer(_from, _to, _tokenId);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Safely burns an asset token
     * @param _tokenId - Token ID to Burn
     */
    function trustedAgentBurn(uint256 _tokenId)
        external
        nonReentrant
        whenNotPaused
        isTrustedAgent
    {
        require(
            isColdWallet(ownerOf(_tokenId)) != 170,
            "AT:TAB:Holder is cold Wallet"
        );
        //^^^^^^^checks^^^^^^^^^

        _burn(_tokenId);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Safely burns a token and sets the corresponding RGT to zero in storage.
     * @param _tokenId - Token ID to discard
     */
    function discard(uint256 _tokenId) external nonReentrant whenNotPaused {
        bytes32 _idxHash = bytes32(_tokenId);
        //Record memory rec = getRecord(_idxHash);

        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "AT:D:Transfer caller !owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^

        RCLR.discard(_idxHash, _msgSender());
        //^^^^^^^interactions^^^^^^^^^

        _burn(_tokenId);
        //^^^^^^^effects^^^^^^^^^ (out of order here, but verified and necescary)
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
            "AT:P: Caller !have pauser role"
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
            "AT:UP: Caller !have pauser role"
        );
        //^^^^^^^checks^^^^^^^^^

        _unpause();
        //^^^^^^^effects^^^^^^^^^
    }

    //---------------------------------------Internal Functions-------------------------------

    /**
     * @dev Get a Record from Storage @ idxHash and return a Record Struct
     * @param _idxHash - Asset Index
     * @return Record Struct (see interfaces for struct definitions)
     */
    function getRecord(bytes32 _idxHash) internal view returns (Record memory) {
        //^^^^^^^checks^^^^^^^^^

        Record memory rec = STOR.retrieveRecord(_idxHash);

        return rec; // Returns Record struct rec
        //^^^^^^^Interactions^^^^^^^^^
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
    ) internal virtual override(ERC721, ERC721Enumerable, ERC721Pausable) {
        super._beforeTokenTransfer(_from, _to, _tokenId);
    }

    /**
     * @dev Destroys `tokenId`.
     * @param tokenId - token to be burned
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
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     * @param tokenId - token URI will be added to
     * @param _tokenURI - URI of token
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(_exists(tokenId), "AT:STU: URI set of nonexistent token");
        //^^^^^^^checks^^^^^^^^^

        _tokenURIs[tokenId] = _tokenURI;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev returns set base URI of asset tokens
     * @return base URI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     * @return supported interfaceId
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

    //---------------------------------------Private Functions-------------------------------

    /**
     * @dev Write a Record to Storage @ idxHash
     * @param _idxHash - Asset Index
     * @param _rec - Complete Record Struct (see interfaces for struct definitions)
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        private
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        STOR.modifyRecord(
            _idxHash,
            _rec.rightsHolder,
            _rec.assetStatus,
            _rec.countDown,
            _rec.int32temp,
            _rec.modCount,
            _rec.numberOfTransfers
        ); // Send data and writehash to storage
        //^^^^^^^interactions^^^^^^^^^
    }
}
