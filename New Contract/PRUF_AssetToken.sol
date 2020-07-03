//TODO: REMINT!!!

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "./_ERC721/ERC721.sol";
import "./_ERC721/Ownable.sol";
import "./PRUF_interfaces.sol";
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

    constructor() public ERC721("BulletProof Asset Token", "BPXA") {}

    address internal PrufAppAddress;
    PrufAppInterface internal PrufAppContract; //erc721_token prototype initialization
    address internal storageAddress;
    StorageInterface internal Storage; // Set up external contract interface

    event REPORT(string _msg);

    modifier isAdmin() {
        require(
            (msg.sender == PrufAppAddress) || (msg.sender == owner()),
            "Calling address does not belong to an Admin"
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
            "PC:SSC: storage address cannot be zero"
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

        PrufAppAddress = Storage.resolveContractAddress("PRUF_APP");
        PrufAppContract = PrufAppInterface(PrufAppAddress);
        //^^^^^^^effects^^^^^^^^^
    }


    /*
     * must be isAdmin
     *
     */
    function mintAssetToken(
        address _reciepientAddress,
        bytes32 _idxHash,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^checks^^^^^^^^^
                                            //MAKE URI ASSET SPECIFIC- has to incorporate the token ID
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev transfer Asset Token
     * set rgt to nonremintable 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
     *
     */
    function transferAssetToken(
        address from,
        address to,
        bytes32 _idxHash
    ) external nonReentrant {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);

        require(
            ownerOf(tokenId) == msg.sender,
            "Caller does not hold token"
        );
        require(
            rec.assetStatus == 51,
            "Asset not in transferrable status"
        );

        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        safeTransferFrom(from, to, tokenId);
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
        address _reciepientAddress,
        bytes32 _idxHash,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        uint256 tokenId = uint256(_idxHash);
        require(_exists(tokenId), "Cannot Remint nonexistant token");
        //^^^^^^^checks^^^^^^^^^
        _burn(tokenId);
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec) private
    {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging

        Storage.modifyRecord(
            userHash,
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

        {
            //Start of scope limit for stack depth
            (
                bytes32 _recorder,
                bytes32 _rightsHolder,
                bytes32 _lastRecorder,
                uint8 _assetStatus,
                uint8 _forceModCount,
                uint16 _assetClass,
                uint256 _countDown,
                uint256 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2,
                uint16 _numberOfTransfers
            ) = Storage.retrieveRecord(_idxHash); // Get record from storage contract

            rec.recorder = _recorder;
            rec.rightsHolder = _rightsHolder;
            rec.lastRecorder = _lastRecorder;
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
