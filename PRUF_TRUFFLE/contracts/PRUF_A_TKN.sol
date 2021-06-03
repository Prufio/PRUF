/**--------------------------------------------------------PRüF0.8.0
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
 * Check and see if A_TKN can be permitted in all AC's to prevent safeTransferFrom->writeRecord conflict due to it not being a default authorized contract for AC's
 *-----------------------------------------------------------------
 * PRUF ASSET NFT CONTRACT
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

contract A_TKN is
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
    bytes32 public constant TRUSTED_AGENT_ROLE =
        keccak256("TRUSTED_AGENT_ROLE");

    uint256 trustedAgentEnabled = 1;

    mapping(address => uint256) private coldWallet;

    address internal STOR_Address;
    address internal RCLR_Address;
    address internal AC_MGR_Address;
    address internal AC_TKN_Address;
    STOR_Interface internal STOR;
    RCLR_Interface internal RCLR;
    AC_MGR_Interface internal AC_MGR;
    AC_TKN_Interface internal AC_TKN;

    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    Counters.Counter private _tokenIdTracker;

    constructor() ERC721("PRUF Asset Token", "PRAT") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender()); //ALL CONTRACTS THAT MINT ASSET TOKENS
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    event REPORT(string _msg);

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
     *      has TRUSTED_AGENT_ROLE and TA role is not disabled
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
    function adminKillTrustedAgent(uint256 _key) external isContractAdmin {
        if (_key == 170) {
            trustedAgentEnabled = 0; // !!! THIS IS A PERMANENT ACTION AND CANNOT BE UNDONE
        }
    }

    /**
     * @dev Set storage contract to interface with
     * @param _storageAddress - Storage contract address to set
     */
    function Admin_setStorageContract(address _storageAddress)
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
    function Admin_resolveContractAddresses() external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        RCLR_Address = STOR.resolveContractAddress("RCLR");
        RCLR = RCLR_Interface(RCLR_Address);

        AC_MGR_Address = STOR.resolveContractAddress("AC_MGR");
        AC_MGR = AC_MGR_Interface(AC_MGR_Address);

        AC_TKN_Address = STOR.resolveContractAddress("AC_TKN");
        AC_TKN = AC_TKN_Interface(AC_TKN_Address);
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

    /**
     * @dev Mint an Asset token
     * @param _recipientAddress - Address to mint token into
     * @param _tokenId - Token ID to mint
     * @param _tokenURI - URI string to atatch to token
     * returns Token ID of minted token
     */
    function mintAssetToken(
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
        bytes32 _idxHash = bytes32(tokenId);
        Record memory rec = getRecord(_idxHash);

        if (AC_MGR.getSwitchAt(rec.assetClass, 1) == 1) {
            //if switch at bit 1 (0) is set
            string memory tokenURI = tokenURI(tokenId);

            require(
                bytes(tokenURI).length == 0,
                "AT:SURI:URI is set, and immutable"
            );

            require(
                AC_TKN.ownerOf(rec.assetClass) == _msgSender(),
                "AT:SURI:Caller !ACTH"
            );
        }

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
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
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
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        _safeTransfer(_from, _to, _tokenId, _data);
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
    ) public nonReentrant whenNotPaused isTrustedAgent {
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
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        _transfer(_from, _to, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
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
     * @param tokenId - Token ID to discard
     */
    function discard(uint256 tokenId) external nonReentrant whenNotPaused {
        bytes32 _idxHash = bytes32(tokenId);
        //Record memory rec = getRecord(_idxHash);

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "AT:D:Transfer caller !owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^

        RCLR.discard(_idxHash, _msgSender());
        _burn(tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Write a Record to Storage @ idxHash, clears price information
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
            _rec.modCount,
            _rec.numberOfTransfers
        ); // Send data and writehash to storage

        STOR.clearPrice(_idxHash); //sets price and currency of a record to zero
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Get a Record from Storage @ idxHash and return a Record Struct
     * @param _idxHash - Asset Index
     * returns Record Struct (see interfaces for struct definitions)
     */
    function getRecord(bytes32 _idxHash) internal returns (Record memory) {
        //^^^^^^^checks^^^^^^^^^

        Record memory rec = STOR.retrieveRecord(_idxHash);
        //^^^^^^^effects^^^^^^^^^

        return rec; // Returns Record struct rec
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
    function unpause() public virtual {
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
