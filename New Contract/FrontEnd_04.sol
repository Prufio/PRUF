// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./PullPayment.sol";


contract StorageInterface {
    function newRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external {}

    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount
    ) external {}

    function modifyIpfs(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs1,
        bytes32 _Ipfs2
    ) external {}

    function retrieveCosts(uint16 _assetClass)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {}

    function retrieveRecord(bytes32 _idxHash)
        external
        returns (
            bytes32,
            bytes32,
            bytes32,
            uint8,
            uint8,
            uint16,
            uint256,
            uint256,
            bytes32,
            bytes32
        )
    {}
}


contract FrontEnd is PullPayment, Ownable {
    using SafeMath for uint256;

    struct Record {
        bytes32 recorder; // Address hash of recorder
        bytes32 rightsHolder; // KEK256 Registered  owner
        bytes32 lastRecorder; // Address hash of last non-automation recorder
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
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
            "ADMIN: storage address cannot be zero"
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

    function getBlock() external view returns (uint256) {
        return (block.number);
    }

    function getAnyHash(string calldata _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function getIdxHash(
        string memory _idx_type,
        string memory _idx_mfg,
        string memory _idx_mod,
        string memory _idx_ser
    ) public pure returns (bytes32) {
        bytes32 idxHash;
        idxHash = keccak256(
            abi.encodePacked(_idx_type, _idx_mfg, _idx_mod, _idx_ser)
        );
        return (idxHash);
    }

    function getRgtHash(
        bytes32 _idxHash,
        string memory _rgt_first,
        string memory _rgt_mid,
        string memory _rgt_last,
        string memory _rgt_ID,
        string memory _rgt_secret
    ) public pure returns (bytes32, bytes32) {
        bytes32 rawRgtHash;

        rawRgtHash = keccak256(
            abi.encodePacked(
                _rgt_first,
                _rgt_mid,
                _rgt_last,
                _rgt_ID,
                _rgt_secret
            )
        );
        return (rawRgtHash, keccak256(abi.encodePacked(_idxHash, rawRgtHash)));
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
        bytes32 _Ipfs
    ) public payable {
        Costs memory cost = getCost(_assetClass);

        require(
            msg.value >= cost.newRecordCost,
            "NR: tx value too low. Send more eth."
        );

        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));

        Storage.newRecord(
            userHash,
            _idxHash,
            _rgtHash,
            _assetClass,
            _countDownStart,
            _Ipfs
        );

        deductPayment(cost.newRecordCost);
    }

    /*
     * @dev Modify **Record**.rightsHolder without confirmation required
     */
    function $forceModRecord(bytes32 _idxHash, bytes32 _rgtHash)
        public
        payable
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);

        Costs memory cost = getCost(rec.assetClass);

        require(
            msg.value >= cost.forceModifyCost,
            "FMR: tx value too low. Send more eth."
        );

        require(rec.assetStatus < 200, "FMR:ERR-Record locked");

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        rec.rightsHolder = _rgtHash;

        writeRecord(_idxHash, rec);

        deductPayment(cost.forceModifyCost);

        return rec.forceModCount;
    }

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function _modStatus(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus
    ) public returns (uint8) {
        Record memory rec = getRecord(_idxHash);

        require(rec.assetStatus < 200, "MS:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "MS:ERR-Rightsholder does not match supplied data"
        );

        rec.assetStatus = _assetStatus;

        writeRecord(_idxHash, rec);

        return rec.assetStatus;
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function _decCounter(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint256 _decAmount
    ) public returns (uint256) {
        Record memory rec = getRecord(_idxHash);

        require(rec.assetStatus < 200, "DC:ERR-Record locked");

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
        Record memory rec = getRecord(_idxHash);

        Costs memory cost = getCost(rec.assetClass);

        require(
            msg.value >= cost.transferAssetCost,
            "TA: tx value too low. Send more eth."
        );

        require(rec.assetStatus < 200, "TA:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "TA:ERR-Rightsholder does not match supplied data"
        );

        require(_newrgtHash != 0, "TA:ERR-new Rightsholder cannot be blank");

        require(
            rec.assetStatus < 3,
            "TA:ERR--Asset assetStatus is not transferrable"
        );

        rec.rightsHolder = _newrgtHash;

        writeRecord(_idxHash, rec);

        deductPayment(cost.transferAssetCost);

        return (170);
    }

    /*
     * @dev Modify **Record**.Ipfs1 with confirmation
     */
    function _modIpfs1(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    ) public returns (bytes32) {
        Record memory rec = getRecord(_idxHash);

        require(rec.assetStatus < 200, "MI1:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "MI1:ERR--Rightsholder does not match supplied data"
        );

        require(rec.Ipfs1 != _IpfsHash, "MI1:ERR--New data same as old");

        rec.Ipfs1 = _IpfsHash;

        writeRecordIpfs(_idxHash, rec);

        return rec.Ipfs1;
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     */
    function $addIpfs2Note(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    ) public payable returns (bytes32) {
        Record memory costrec = getRecord(_idxHash);
        Costs memory cost = getCost(costrec.assetClass);

        require(
            msg.value >= cost.createNoteCost,
            "tx value too low. Send more eth."
        );

        Record memory rec;

        rec = getRecord(_idxHash);

        require(rec.assetStatus < 200, "MI2:ERR-Record locked");

        require(
            rec.rightsHolder == _rgtHash,
            "MI2:ERR--Rightsholder does not match supplied data"
        );

        require(
            rec.Ipfs2 == 0,
            "MI2:ERR--Ipfs2 has data already. Overwrite not permitted"
        );

        rec.Ipfs2 = _IpfsHash;

        writeRecordIpfs(_idxHash, rec);

        deductPayment(cost.createNoteCost);

        return rec.Ipfs2;
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
                bytes32 _Ipfs2
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
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
    }

    /*
     * @dev Write an Ipfs Record to Storage @ idxHash
     */
    function writeRecordIpfs(bytes32 _idxHash, Record memory _rec) private {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging

        Storage.modifyIpfs(userHash, _idxHash, _rec.Ipfs1, _rec.Ipfs2); // Send data to storage
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
            _rec.assetStatus,
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
