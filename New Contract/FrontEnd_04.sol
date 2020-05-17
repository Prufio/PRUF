pragma solidity ^0.6.0;
//pragma experimental ABIEncoderV2;

import "./PullPayment.sol";


contract StorageInterface {
    function newRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _IPFS1
    ) external {}

    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint8 _status,
        uint256 _countDown,
        uint8 _forceCount
    ) external {}

    function modifyIPFS(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _IPFS1,
        bytes32 _IPFS2
    ) external {}

    function retrieveRecorder(bytes32 _idxHash)
        external
        returns (bytes32, bytes32, bytes32)
    {}

    function retrieveCosts(uint16 _assetClass)
        external
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
    {}

    function retrieveRecord(bytes32 _idxHash)
        external
        returns (bytes32, uint8, uint8, uint16, uint256, uint256, bytes32)
    {}

    function retrieveExtendedData(bytes32 _idxHash)
        external
        returns (bytes32, uint8, uint16, bytes32, bytes32, bytes32)
    {}

    function BlockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint8)
    {}
}


contract FrontEnd is PullPayment, Ownable {
    using SafeMath for uint256;

    struct Record {
        bytes32 recorder; // Address hash of recorder
        bytes32 rightsHolder; // KEK256 Registered  owner
        bytes32 lastRecorder; // Address hash of last non-automation recorder
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 IPFS1; // Publically viewable asset description
        bytes32 IPFS2; // Publically viewable immutable notes
        uint256 timeLock; // Time sensitive mutex
    }

    struct User {
        uint8 userType; // User type: 1 = human, 9 = automated
        uint16 authorizedAssetClass; // Asset class in which user is permitted to transact
    }

    struct Costs {
        uint256 newRecordCost; // Cost to create a new record
        uint256 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        uint256 createNoteCost; // Cost to add a static note to an asset
        uint256 cost4; // Extra
        uint256 cost5; // Extra
        uint256 forceModifyCost; // Cost to brute-force a record transfer
    }

    address internal mainWallet;

    StorageInterface private Storage; // Set up external contract interface

    address storageAddress;

    event REPORT(string _msg);

    /*
     * @dev Set storage contract to interface with
     */
    function _setStorageContract(address _storageAddress) public onlyOwner {
        require(
            _storageAddress != address(0),
            "storage address cannot be zero"
        );

        Storage = StorageInterface(_storageAddress);
    }

    /*
     * @dev Set wallet for contract to direct payments to
     */
    function _setMainWallet(address _addr) public onlyOwner {
        mainWallet = _addr;
    }

    // --------------------------------------TESTING FUNCTIONS--------------------------------------------//
    function getAnyHash(string calldata _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function getBlock() external view returns (bytes32) {
        return keccak256(abi.encodePacked(block.number));
    }

    //--------------------------------------External functions--------------------------------------------//

    /*
     * @dev Wrapper for newRecord
     */
    function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _IPFS
    ) public payable {
        Costs memory cost = getCost(_assetClass);

        require(
            msg.value >= cost.newRecordCost,
            "NR: tx value too low. Send more eth."
        );

        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));

        Storage.newRecord(
            senderHash,
            _idxHash,
            _rgtHash,
            _assetClass,
            _countDownStart,
            _IPFS
        );

        deductPayment(cost.newRecordCost);
    }

    //Write a data thing pattern:
    /*
     * Have data
     * Get a record #hash from Storage using Storage.getHash(idxHash)
     * Get a Record struct using getRecord(idxHash)
     * Check out the record with the new / old data --
     * Make a unuiqe ID from the data being sent
     * Check out the record using newRecordHash = Storage.checkOutRecord(_idxHash, _checkoutID);
     * bytes32 key = keccak256(abi.encodePacked(block.number, checkoutID));
     * Verify that the earlier record #hash hashed with the key matches newRecordHash
     * Write the modified Record struct (_rec) with the recordHash using writeRecord (idxHash, _rec, recordHash)
     */

    /*
     * @dev Modify **Record**.rightsHolder without confirmation required
     */
    function $forceModRecord(bytes32 _idxHash, bytes32 _rgtHash)
        public
        payable
        returns (uint8)
    {
        Record memory costrec = getRecord(
            keccak256(abi.encodePacked(_idxHash))
        );

        Costs memory cost = getCost(costrec.assetClass);

        require(
            msg.value >= cost.forceModifyCost,
            "FMR: tx value too low. Send more eth."
        );

        Record memory rec;

        require(rec.status < 200, "FMR:ERR-Record locked");

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        rec.rightsHolder = _rgtHash;

        writeRecord(_idxHash, rec);

        deductPayment(cost.forceModifyCost);

        return rec.forceModCount;
    }

    /*
     * @dev Modify **Record**.status with confirmation required
     */
    function _modStatus(bytes32 _idxHash, bytes32 _rgtHash, uint8 _status)
        public
        returns (uint8)
    {
        Record memory rec;

        rec = getRecord(_idxHash);

        require(rec.status < 200, "MS:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "MS:ERR-Rightsholder does not match supplied data"
        );

        rec.status = _status;

        writeRecord(_idxHash, rec);

        return rec.status;
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function _decCounter(bytes32 _idxHash, bytes32 _rgtHash, uint256 _decAmount)
        public
        returns (uint256)
    {
        Record memory rec;

        rec = getRecord(_idxHash);

        require(rec.status < 200, "DC:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "DC:ERR--Rightsholder does not match supplied data"
        );

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown.sub(_decAmount);
        } else {
            rec.countDown = 0;
        }

        writeRecord(_idxHash, rec);
        return (rec.countDown);
    }

    /*
     * @dev Transfer Rights to new rightsHolder with confirmation
     */
    function $transferAsset(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _newrgtHash
    ) public payable returns (uint8) {
        Record memory costrec = getRecord(_idxHash);

        Costs memory cost = getCost(costrec.assetClass);

        require(
            msg.value >= cost.transferAssetCost,
            "TA: tx value too low. Send more eth."
        );

        Record memory rec;

        rec = getRecord(_idxHash);

        require(rec.status < 200, "TA:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "DC:ERR-Rightsholder does not match supplied data"
        );

        require(_newrgtHash != 0, "TA:ERR-new Rightsholder cannot be blank");

        require(rec.status < 3, "TA:ERR--Asset status is not transferrable");

        rec.rightsHolder = _newrgtHash;

        writeRecord(_idxHash, rec);

        deductPayment(cost.transferAssetCost);

        return (170);
    }

    /*
     * @dev Modify **Record**.IPFS1 with confirmation
     */
    function _modIPFS1(bytes32 _idxHash, bytes32 _rgtHash, bytes32 _IPFSHash)
        public
        returns (bytes32)
    {
        Record memory rec;

        rec = getExtendedData(_idxHash);

        require(rec.status < 200, "MI1:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "MI1:ERR--Rightsholder does not match supplied data"
        );

        require(rec.IPFS1 != _IPFSHash, "MI1:ERR--New data same as old");

        rec.IPFS1 = _IPFSHash;

        writeRecordIPFS(_idxHash, rec);

        return rec.IPFS1;
    }

    /*
     * @dev Modify **Record**.IPFS2 with confirmation
     */
    function $addIPFS2Note(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IPFSHash
    ) public payable returns (bytes32) {
        Record memory costrec = getRecord(_idxHash);

        Costs memory cost = getCost(costrec.assetClass);

        require(
            msg.value >= cost.createNoteCost,
            "tx value too low. Send more eth."
        );

        Record memory rec;

        rec = getExtendedData(_idxHash);

        require(rec.status < 200, "MI1:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "MI1:ERR--Rightsholder does not match supplied data"
        );

        require(
            rec.IPFS2 == 0,
            "MI1:ERR--IPFS2 has data already. Overwrite not permitted"
        );

        rec.IPFS2 = _IPFSHash;

        writeRecordIPFS(_idxHash, rec);

        deductPayment(cost.createNoteCost);

        return rec.IPFS2;
    }

    /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord(bytes32 _idxHash) private returns (Record memory) {
        bytes32 datahash;
        Record memory rec;

        (
            rec.rightsHolder,
            rec.status,
            rec.forceModCount,
            rec.assetClass,
            rec.countDown,
            rec.countDownStart,
            datahash
        ) = Storage.retrieveRecord(_idxHash); // Get record from storage contract

        return (rec); // Returns Record struct rec and checkout supplied key
    }

    /*
     * @dev Get an IPFS Record from Storage @ idxHash
     */
    function getExtendedData(bytes32 _idxHash) private returns (Record memory) {
        bytes32 datahash;
        Record memory rec;

        (
            rec.rightsHolder,
            rec.status,
            rec.assetClass,
            rec.IPFS1,
            rec.IPFS2,
            datahash
        ) = Storage.retrieveExtendedData(_idxHash); //get record from storage contract

        return (rec); // Returns record struct rec and checkout supplied key
    }

    /*
     * @dev Get recorder data Record from Storage @ idxHash
     */
    function getRecorders(bytes32 _idxHash) private returns (Record memory) {
        bytes32 datahash;
        Record memory rec;

        (rec.lastRecorder, rec.recorder, datahash) = Storage.retrieveRecorder(
            _idxHash
        ); // Get record from storage contract

        return (rec); // Returns record struct rec and checkout supplied key
    }

    /*
     * @dev Compare record.rightsholder from storage with supplied bytes32 rightsholder (writes in blockchain)
     */
    function rightsholderBlockchainVerify(bytes32 _idxHash, bytes32 _rgtHash)
        public
        returns (string memory)
    {
        uint8 response;

        response = Storage.BlockchainVerifyRightsHolder(_idxHash, _rgtHash); // Compare rights holder in storage contract
    
        if (response == 170){
                return "Rights holder match confirmed";
            }else {
                return "Rights holder does not match";
        }
       
    }

    /*
     * @dev Write an IPFS Record to Storage @ idxHash
     */
    function writeRecordIPFS(bytes32 _idxHash, Record memory _rec) private {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging

        Storage.modifyIPFS(userHash, _idxHash, _rec.IPFS1, _rec.IPFS2); // Send data to storage
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec) private {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging

        Storage.modifyRecord(
            userHash,
            _idxHash,
            _rec.rightsHolder,
            _rec.status,
            _rec.countDown,
            _rec.forceModCount
        ); // Send data and writehash to storage
    }

    /*--------------------------------------------------------------------------------------PAYMENT FUNCTIONS
     * @dev Deducts payment from transaction
     */
    function deductPayment(uint256 _amount) private {
        uint256 messageValue = msg.value;
        uint256 change;

        change = messageValue.sub(_amount);

        _asyncTransfer(mainWallet, _amount);
        _asyncTransfer(msg.sender, change);
    }

    /*
     * @dev Withdraws user's Escrow amount
     */
    function $withdraw() public virtual payable {
        withdrawPayments(msg.sender);
    }

    /*
     * @dev Returns cost from database and returns Costs struct
     */
    function getCost(uint16 _class) private returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.cost4,
            cost.cost5,
            cost.forceModifyCost
        ) = Storage.retrieveCosts(_class);

        return (cost);
    }
}
