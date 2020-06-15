// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;
import "./PullPayment.sol";

/*--------To do
 *Status 5  - Asset transferred - implies that asset holder is the owner.
 *       must be re-imported by ACadmin through regular onboarding process
 *       no actions besides modify RGT to a new rightsholder can be performed on a statuss 5 asset (no status changes) (Frontend)
 *
 *=Status 0 Default asset creation status,
 *default after FMR, and after status 5 (essentially a FMR) (IN frontend)
 *only type 1 can change a status 0 record
 *
 *Status 1-5 No actions can be performed by type 9 users. (real ACAdmins only can set or unset these statuses) except:
 *Automation can change a 1 or 2 status to any automated status
 *
 *status 6 transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 *status 7 non-transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 *status 8 stolen (automation set)(ONLY ACAdmin can unset)
 *status 9 lost (automation set/unset)(ACAdmin can unset)
 *
 */

interface StorageInterface {
    function newRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external;

    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount
    ) external;

    function modifyIpfs(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs1,
        bytes32 _Ipfs2
    ) external;

    function retrieveCosts(uint16 _assetClass)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

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
        );

    function getUser(bytes32 _userHash) external view returns (uint8, uint16);
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

    address storageAddress;
    address internal mainWallet;
    StorageInterface private Storage; // Set up external contract interface

    event REPORT(string _msg);

    // --------------------------------------ADMIN FUNCTIONS--------------------------------------------//
    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "FE:OO-SSC-ERR: Storage address cannot be zero"
        );

        Storage = StorageInterface(_storageAddress);
    }

    /*
     * @dev Set wallet for contract to direct payments to
     */

    function OO_setMainWallet(address _addr) external onlyOwner {
        mainWallet = _addr;
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
    ) external payable {
        Costs memory cost = getCost(_assetClass);
        User memory callingUser = getUser();

        require(
            callingUser.userType == 1,
             "FE:NR-ERR: User not authorized to create records"
        );
        require(
            callingUser.authorizedAssetClass == _assetClass,
             "FE:NR-ERR: User not authorized to create records in specified asset class"
        );
        require(
            msg.value >= cost.newRecordCost,
            "FE:NR-ERR: tx value too low. Send more eth."
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
        external
        payable
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        Costs memory cost = getCost(rec.assetClass);
        User memory callingUser = getUser();

        require(
            callingUser.userType == 1,
             "FE:FMR-ERR: User not authorized to force modify records"
        );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
             "FE:FMR-ERR: User not authorized to modify records in specified asset class"
        );
        require(
            msg.value >= cost.forceModifyCost,
            "FE:FMR-ERR: Tx value too low. Send more eth."
        );
        require(rec.assetStatus < 200, "FE:FMR-ERR: Record locked");

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;

        writeRecord(_idxHash, rec);

        deductPayment(cost.forceModifyCost);

        return rec.forceModCount;
    }

    /*
     * @dev Reimport **Record**.rightsHolder (no confirmation required, posessor is considered to be owner)
     */
    function $reimportRecord(bytes32 _idxHash, bytes32 _rgtHash)
        external
        payable
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        Costs memory cost = getCost(rec.assetClass);
        User memory callingUser = getUser();

        require(
            callingUser.userType == 1,
             "RR: User not authorized to force modify records"
        );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
             "RR: User not authorized to modify records in specified asset class"
        );
        require(
            rec.assetStatus == 5,
             "RR: Only status 5 assets can be reimported"
        );
        require(
            msg.value >= cost.newRecordCost,
            "RR: tx value too low. Send more eth."
        );
        require(rec.assetStatus < 200, "FMR:ERR-Record locked");

        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;

        writeRecord(_idxHash, rec);

        deductPayment(cost.newRecordCost);

        return rec.assetStatus;
    }


    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function _modStatus(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus
    ) external returns (uint8) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        // require(
        //     callingUser.userType == 1,
        //      "FMR: User not authorized to create records"
        // );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
             "FE:MS-ERR: User not authorized to modify records in specified asset class"
        );

        require(rec.assetStatus < 200, "FE:MS-ERR: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "FE:MS-ERR: Rightsholder does not match supplied data"
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
    ) external returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        // require(
        //     callingUser.userType == 1,
        //      "FMR: User not authorized to create records"
        // );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
             "FE:DC-ERR: User not authorized to modify records in specified asset class"
        );
        require(rec.assetStatus < 200, "FE:DC-ERR: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "FE:DC-ERR: Rightsholder does not match supplied data"
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
    ) external payable returns (uint8) {
        Record memory rec = getRecord(_idxHash);
        Costs memory cost = getCost(rec.assetClass);
        User memory callingUser = getUser();

        // require(
        //     callingUser.userType == 1,
        //      "FMR: User not authorized to create records"
        // );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
             "FE:TA-ERR: User not authorized to modify records in specified asset class"
        );
        require(
            msg.value >= cost.transferAssetCost,
            "FE:TA-ERR: Tx value too low. Send more eth."
        );
        require(rec.assetStatus < 200, "FE:TA-ERR: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "FE:TA-ERR: Rightsholder does not match supplied data"
        );
        require(_newrgtHash != 0, "FE:TA-ERR: New Rightsholder cannot be blank");
        require(
            rec.assetStatus < 3,
            "FE:TA-ERR: Asset assetStatus is not transferrable"
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
    ) external returns (bytes32) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();

        // require(
        //     callingUser.userType == 1,
        //      "FMR: User not authorized to create records"
        // );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
             "FE:MI1-ERR: User not authorized to modify records in specified asset class"
        );

        require(rec.assetStatus < 200, "FE:MI1-ERR: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "FE:MI1-ERR: Rightsholder does not match supplied data"
        );
        require(rec.Ipfs1 != _IpfsHash, "FE:MI1-ERR: New data same as old");

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
    ) external payable returns (bytes32) {
        Record memory rec = getRecord(_idxHash);
        Costs memory cost = getCost(rec.assetClass);
        User memory callingUser = getUser();

        // require(
        //     callingUser.userType == 1,
        //      "FMR: User not authorized to create records"
        // );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
             "FE:MI2-ERR: User not authorized to modify records in specified asset class"
        );
        require(
            msg.value >= cost.createNoteCost,
            "FE:MI2-ERR: Tx value too low. Send more eth."
        );
        require(rec.assetStatus < 200, "FE:MI2-ERR: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "FE:MI2-ERR: Rightsholder does not match supplied data"
        );
        require(
            rec.Ipfs2 == 0,
            "FE:MI2-ERR: Ipfs2 has data already. Overwrite not permitted"
        );

        rec.Ipfs2 = _IpfsHash;

        writeRecordIpfs(_idxHash, rec);

        deductPayment(cost.createNoteCost);

        return rec.Ipfs2;
    }

    /*
     * @dev Get a User Record from Storage @ msg.sender
     */
    function getUser() private view returns (User memory) { //User memory callingUser = getUser();
        User memory user;
        (user.userType, user.authorizedAssetClass) = Storage.getUser(keccak256(abi.encodePacked(msg.sender)));
        return user;
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
    function $withdraw() external virtual payable {
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
