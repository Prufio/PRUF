/*-----------------------------------------------------------------
 *  TO DO
 *
 *-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./_ERC721/ERC721.sol";
import "./_ERC721/Ownable.sol";
import "./PRUF_interfaces_067.sol";
import "./Imports/ReentrancyGuard.sol";

contract AssetToken is Ownable, ReentrancyGuard, ERC721 {
    struct Record {
        bytes32 recorder; // Address hash of recorder
        bytes32 rightsHolder; // KEK256 Registered owner
        bytes32 lastRecorder; // Address hash of last non-automation recorder
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        uint256 timeLock; // Time sensitive mutex
        uint16 numberOfTransfers; //number of transfers and forcemods
    }

    constructor() public ERC721("PRüF Asset Token", "PAT") {}

    address internal T_PrufAppAddress; //isAdmin
    address internal PrufAppAddress; //isAdmin
    address internal storageAddress;
    StorageInterface internal Storage; // Set up external contract interface
    address internal recyclerAddress;
    RecyclerInterface internal Recycler;

    event REPORT(string _msg);

    modifier isAdmin() {
        require(
            (msg.sender == PrufAppAddress) ||
            (msg.sender == T_PrufAppAddress) ||
            (msg.sender == recyclerAddress) ||
            (msg.sender == owner()),
            "PAT:IA:Calling address does not belong to an Admin"
        );
        _;
    }

    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "PAT:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage = StorageInterface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Address Setters
     */
    function OO_ResolveContractAddresses() external nonReentrant onlyOwner {
        //^^^^^^^checks^^^^^^^^^

        T_PrufAppAddress = Storage.resolveContractAddress("T_PRUF_APP");
        PrufAppAddress = Storage.resolveContractAddress("PRUF_APP");

        recyclerAddress = Storage.resolveContractAddress("PRUF_recycler");
        Recycler = RecyclerInterface(recyclerAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint new token
     *
     */
    function mintAssetToken(
        address _recipientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        //MAKE URI ASSET SPECIFIC- has to incorporate the token ID
        _safeMint(_recipientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set new token URI String
     */
    function setURI(
        uint256 tokenId,
        string calldata _tokenURI
    ) external returns (uint256) {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "PAT:TF:transfer caller is not owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^

        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev See if token exists
     */
    function tokenExists(uint256 tokenId) external view returns (uint8) {
        if(_exists(tokenId)){
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
    ) public override nonReentrant {
        bytes32 _idxHash = bytes32(tokenId);
        Record memory rec = getRecord(_idxHash);

        require(
            rec.assetStatus != 70,
            "PAT:TF:Use authAddressTransfer for status 70"
        );
        require(
            rec.assetStatus == 51,
            "PAT:TF:Asset not in transferrable status"
        );
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "PAT:TF:transfer caller is not owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }

        rec
            .rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
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
    ) public override nonReentrant {
        bytes32 _idxHash = bytes32(tokenId);
        Record memory rec = getRecord(_idxHash);

        //^^^^^^^checks^^^^^^^^^

        rec
            .rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
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
    ) public virtual override {
        bytes32 _idxHash = bytes32(tokenId);
        Record memory rec = getRecord(_idxHash);

        require(
            (rec.assetStatus != 70) || (Storage.ContractAuthType(to) > 0),
            "PAT:STF:Cannot send status 70 asset to unauthorized address"
        );
        require(
            (rec.assetStatus == 51) || (rec.assetStatus == 70),
            "PAT:STF:Asset not in transferrable status"
        );
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "PAT:STF: transfer caller is not owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }

        rec
            .rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        _safeTransfer(from, to, tokenId, _data);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Safely burns a token and sets the corresponding RGT to zero in storage.
     */
    function discard(uint256 tokenId) external nonReentrant isAdmin {
        bytes32 _idxHash = bytes32(tokenId);
        Record memory rec = getRecord(_idxHash);
        require(_exists(tokenId), "PAT:D:Cannot Burn nonexistant token");
        require(
            (rec.assetStatus == 59),
            "PAT:D:Asset must be in status 59 (discardable) to be burned"
        );
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "PAT:D:transfer caller is not owner nor approved"
        );
        //^^^^^^^checks^^^^^^^^^
        Recycler.discard(_idxHash);
        _burn(tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * Authorizations?
     * @dev remint Asset Token
     * must set a new and unuiqe rgtHash
     * burns old token
     * Sends new token to original Caller
     */
    function reMintAssetToken(
        address _recipientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external isAdmin nonReentrant returns (uint256) {
        require(_exists(tokenId), "PAT:RM:Cannot Remint nonexistant token");
        //^^^^^^^checks^^^^^^^^^
        _burn(tokenId);
        _safeMint(_recipientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec) private {
        //^^^^^^^checks^^^^^^^^^
        //bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging
        //^^^^^^^effects^^^^^^^^^
        Storage.modifyRecord(
            //userHash,
            _idxHash,
            _rec.rightsHolder,
            _rec.assetStatus,
            _rec.countDown,
            _rec.forceModCount,
            _rec.numberOfTransfers
        ); // Send data and writehash to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord(bytes32 _idxHash) private returns (Record memory) {
        Record memory rec;
        //^^^^^^^checks^^^^^^^^^

        {
            //Start of scope limit for stack depth
            (
                //bytes32 _recorder,
                bytes32 _rightsHolder,
                //bytes32 _lastRecorder,
                uint8 _assetStatus,
                uint8 _forceModCount,
                uint16 _assetClass,
                uint256 _countDown,
                uint256 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2,
                uint16 _numberOfTransfers
            ) = Storage.retrieveRecord(_idxHash); // Get record from storage contract

            //rec.recorder = _recorder;
            rec.rightsHolder = _rightsHolder;
            //rec.lastRecorder = _lastRecorder;
            rec.assetStatus = _assetStatus;
            rec.forceModCount = _forceModCount;
            rec.assetClass = _assetClass;
            rec.countDown = _countDown;
            rec.countDownStart = _countDownStart;
            rec.Ipfs1 = _Ipfs1;
            rec.Ipfs2 = _Ipfs2;
            rec.numberOfTransfers = _numberOfTransfers;
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
        //^^^^^^^interactions^^^^^^^^^
    }
}
