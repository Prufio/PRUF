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
 * PRUF ASSET NFT CONTRACT
 *---------------------------------------------------------------*/


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./Imports/access/AccessControl.sol";
import "./Imports/GSN/Context.sol";
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
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */



contract A_TKN is ReentrancyGuard, Context, AccessControl, ERC721Burnable, ERC721Pausable {
    using Counters for Counters.Counter;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    Counters.Counter private _tokenIdTracker;

    struct Record {
        bytes32 rightsHolder; // KEK256 Registered owner
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint256 incrementForceModCount; // increment flag for Number of times asset has been forceModded.
        uint32 assetClass; // Type of asset
        uint32 countDown; // Variable that can only be dencreased from countDownStart
        uint32 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        uint256 incrementNumberOfTransfers; //increment flag for number of transfers and forcemods
    }

    constructor() public ERC721("PRüF Asset Token", "PRAT") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender()); //ALL CONTRACTS THAT MINT ASSET TOKENS
        _setupRole(PAUSER_ROLE, _msgSender());

        //_setBaseURI("pruf.io");
    }


    address internal STOR_Address;
    address internal RCLR_Address;
    STOR_Interface internal STOR;
    RCLR_Interface internal RCLR;

    event REPORT(string _msg);


    modifier isAdmin() {
        require (hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "AT:MOD-IA:Calling address does not belong to an admin"
        );
        _;
    }

    modifier isMinter() {
        require (hasRole(MINTER_ROLE, _msgSender()),
            "AT:MOD-IA:Calling address does not belong to a minter"
        );
        _;
    }

    //----------------------Admin functions / isAdmin or isTrusted----------------------//

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external isAdmin {
        require(
            _storageAddress != address(0),
            "AT:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR = STOR_Interface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Address Setters
     */
    function OO_resolveContractAddresses() external isAdmin {
        //^^^^^^^checks^^^^^^^^^

        RCLR_Address = STOR.resolveContractAddress("RCLR");
        RCLR = RCLR_Interface(RCLR_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint new token
     */
    function mintAssetToken(
        address _recipientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external isMinter nonReentrant returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        //MAKE URI ASSET SPECIFIC- has to incorporate the token ID
        _safeMint(_recipientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    // /*
    //  * @dev remint Asset Token
    //  * must set a new and unuiqe rgtHash
    //  * burns old token
    //  * Sends new token to original Caller
    //  */
    // function reMintAssetToken(address _recipientAddress, uint256 tokenId)
    //     external
    //     isMinter
    //     nonReentrant
    //     returns (uint256)
    // {
    //     require(_exists(tokenId), "AT:RM:Cannot Remint nonexistant token");
    //     //^^^^^^^checks^^^^^^^^^
    //     string memory tokenURI = tokenURI(tokenId);
    //     _burn(tokenId);
    //     _safeMint(_recipientAddress, tokenId);
    //     _setTokenURI(tokenId, tokenURI);
    //     return tokenId;
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    /*
     * @dev Set new token URI String
     */
    function setURI(uint256 tokenId, string calldata _tokenURI)
        external
        returns (uint256)
    {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "AT:SURI:caller is not owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^

        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Reassures user that token is minted in the PRUF system
     */
    function validatePipToken(
        uint256 tokenId,
        uint32 _assetClass,
        string calldata _authCode
    ) external view {
        bytes32 _hashedAuthCode = keccak256(abi.encodePacked(_authCode));
        bytes32 b32URI = keccak256(
            abi.encodePacked(_hashedAuthCode, _assetClass)
        );
        string memory authString = uint256toString(uint256(b32URI));
        string memory URI = tokenURI(tokenId);

        require(
            keccak256(abi.encodePacked(URI)) ==
                keccak256(abi.encodePacked(authString)),
            "AT:VNT:Supplied authCode and assetclass do not match token URI"
        );
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
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override nonReentrant whenNotPaused {
        bytes32 _idxHash = bytes32(tokenId);
        Record memory rec = getRecord(_idxHash);

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "AT:TF:transfer caller is not owner nor approved"
        );
        require(
            rec.assetStatus == 51,
            "AT:TF:Asset not in transferrable status"
        );

        //^^^^^^^checks^^^^^^^^

        rec.incrementNumberOfTransfers = 170;

        rec.rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        _transfer(from, to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        //writeRecord(_idxHash, rec);
        safeTransferFrom(from, to, tokenId, "");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
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
        bytes32 _idxHash = bytes32(tokenId);
        Record memory rec = getRecord(_idxHash);
        (uint8 isAuth, ) = STOR.ContractInfoHash(to, 0); // trailing comma because does not use the returned hash

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "AT:STF: transfer caller is not owner nor approved"
        );
        require( // ensure that status 70 assets are only sent to an actual PRUF contract
            (rec.assetStatus != 70) || (isAuth > 0),
            "AT:STF:Cannot send status 70 asset to unauthorized address"
        );
        require(
            (rec.assetStatus == 51) || (rec.assetStatus == 70),
            "AT:STF:Asset not in transferrable status"
        );
        require(
            to != address(0),
            "AT:STF:Cannot transfer asset to zero address. Use discard."
        );

        //^^^^^^^checks^^^^^^^^^

        rec.incrementNumberOfTransfers = 170;
        rec.rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        _safeTransfer(from, to, tokenId, _data);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely burns a token and sets the corresponding RGT to zero in storage.
     */
    function discard(uint256 tokenId) external nonReentrant whenNotPaused {
        bytes32 _idxHash = bytes32(tokenId);
        //Record memory rec = getRecord(_idxHash);

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "AT:D:transfer caller is not owner nor approved"
        );

        //^^^^^^^checks^^^^^^^^^
        //^^^^^^^effects^^^^^^^^^

        RCLR.discard(_idxHash, msg.sender);
        _burn(tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec) private whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        //^^^^^^^effects^^^^^^^^^
        STOR.modifyRecord(
            _idxHash,
            _rec.rightsHolder,
            _rec.assetStatus,
            _rec.countDown,
            _rec.incrementForceModCount,
            _rec.incrementNumberOfTransfers
        ); // Send data and writehash to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord(bytes32 _idxHash) private view returns (Record memory) {
        Record memory rec;
        //^^^^^^^checks^^^^^^^^^
        //^^^^^^^effects^^^^^^^^^

        {
            //Start of scope limit for stack depth
            (
                bytes32 _rightsHolder,
                uint8 _assetStatus,
                uint32 _assetClass,
                uint32 _countDown,
                uint32 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2
            ) = STOR.retrieveRecord(_idxHash); // Get record from storage contract

            rec.rightsHolder = _rightsHolder;
            rec.assetStatus = _assetStatus;
            rec.assetClass = _assetClass;
            rec.countDown = _countDown;
            rec.countDownStart = _countDownStart;
            rec.Ipfs1 = _Ipfs1;
            rec.Ipfs2 = _Ipfs2;
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
        //^^^^^^^interactions^^^^^^^^^
    }

    function uint256toString(uint256 number)
        public
        pure
        returns (string memory)
    {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        // shamelessly jacked straight outa OpenZepplin  openzepplin.org

        if (number == 0) {
            return "0";
        }
        uint256 temp = number;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = number;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
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
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to pause");
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
        require(hasRole(PAUSER_ROLE, _msgSender()), "ERC721PresetMinterPauserAutoId: must have pauser role to unpause");
        //^^^^^^^checks^^^^^^^^^
        _unpause();
        //^^^^^^^interactions^^^^^^^^^
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override(ERC721, ERC721Pausable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
