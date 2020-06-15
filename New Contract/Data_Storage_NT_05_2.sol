// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./Ownable.sol";

contract Storage is Ownable {
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
    }

    struct User {
        uint8 userType; // Human / Automated / Unauthorized
        uint16 authorizedAssetClass; // User authorized for specific asset class
    }

    struct Costs {
        uint256 cost1;
        uint256 cost2;
        uint256 cost3;
        uint256 cost4;
        uint256 cost5;
        uint256 cost6;
    }

    mapping(bytes32 => uint8) private authorizedAdresses; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNames; // Authorized contract addresses, indexed by name
    mapping(bytes32 => Record) private database; // Main Data Storage


    /*  NOTES:---------------------------------------------------------------------------------------//
     * Authorized external Contract / address types:   authorizedAdresses[]
     *
     * 0   --NONE
     * 1   --E
     * 2   --RE
     * 3   --RWE
     * 4  --ADMIN (isAdmin)
     * >4 NONE
     * Owner (onlyOwner)
     * other = unauth
     *
     *
     * Record status field key
     *
        * 0 = no status, Non transferrable. Default asset creation status
        *       default after FMR, and after status 5 (essentially a FMR) (IN frontend)
        * 1 = transferrable
        * 2 = nontransferrable
        * 3 = stolen
        * 4 = lost
        * 5 = transferred but not reImported (no new rghtsholder information) implies that asset posessor is the owner.
        *       must be re-imported by ACadmin through regular onboarding process
        *       no actions besides modify RGT to a new rightsholder can be performed on a statuss 5 asset (no status changes) (Frontend)
        * 6 = in escrow, locked until timelock expires, but can be set to lost or stolen
        *       Status 1-6 Actions cannot be performed by automation.
        *       only ACAdmins can set or unset these statuses, except 5 which can be set by automation
        *
        * 7 = transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
        * 8 = non-transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
        ********status 9 stolen (automation set)(ONLY ACAdmin can unset)
        * 10 = lost (automation set/unset)(ACAdmin can unset)
        * 11 = asset transferred automation set/unset (secret confirmed)(ACAdmin can unset)
        * 12 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
        *
        * escrow status = lock time set to a time instead of a block number
     *
     *
     * Authorized User Types   registeredUsers[]
     *
     * 1 = Standard User
     * 9 = Robot
     * 99 = ADMIN (isAdmin)
     * Other = unauth
     *
     * rgtHash = K256(abiPacked(idxHash,rgtHash))
     */

    //----------------------------------------------Modifiers----------------------------------------------//

    /*
     * @dev Check msg.sender against authorized adresses
     * msg.sender
     *      (Exists in registeredUsers as a usertype 99
     *      and
     *      Exists in authorizedAddress as a contract type 4)
     *      or
     *      Is owner from ownable
     *
     */
    modifier isAdmin() {
        require(
            (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] == 4) ||
            (owner() == msg.sender),
            "address does not belong to an Admin"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     *
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 or 9
     *      Is authorized for asset class
     */
    modifier onlyAuthAddr() {
        require(
            (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >=
                3) &&
                (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <=
                    4),
            "MOD-OAA-Contract not authorized or improperly permissioned"
        );
        _;
    }

    /*
     * @dev Check record _idxHash exists and is not locked
     */
    modifier unlocked(bytes32 _idxHash) {
        require(
            ((database[_idxHash].assetStatus != 6 ) &&
             (database[_idxHash].assetStatus != 12)) ||
             database[_idxHash].timeLock < now, //Since time here is +/1 a day or so, now can be used as per the 15 second rule (consensys)
             "MOD-U-record Locked");
        _;
    }

    /*
     * @dev Check record exists in database
     */
    modifier exists(bytes32 _idxHash) {
        require(
            database[_idxHash].rightsHolder != 0,
            "MOD-E-record does not exist"
        );
        _;
    }

    /*
     * @dev Check record isn't time locked
     */
    modifier notTimeLocked(bytes32 _idxHash) {
        //this modifier makes the bold assumption the block number will "never" be reset. hopefully, this is true...
        require(
            database[_idxHash].timeLock < block.number,
            "MOD-NTL-record time locked"
        );
        _;
    }

    //-----------------------------------------------Events------------------------------------------------//

    event REPORT(string _msg);

    //--------------------------------Internal Admin functions / onlyowner or isAdmin---------------------------------//

   
    /*
     * @dev Authorize / Deauthorize / Authorize ADRESSES permitted to make record modifications
     */
    function OO_addContract(
        string calldata _name,
        address _addr,
        uint8 _contractAuthLevel
    ) external onlyOwner {
        require(_contractAuthLevel <= 4, "AC:ER-13 Invalid user type");
        emit REPORT("internal user database access!"); //report access to the internal user database

        authorizedAdresses[keccak256(
            abi.encodePacked(_addr)
        )] = _contractAuthLevel;
        contractNames[_name] = _addr;
    }


    /*
     * @dev Allows Admin to reset force mod count
     */
    function ADMIN_resetFMC(bytes32 _idxHash)
        external
        //isAdmin
        onlyAuthAddr
        exists(_idxHash)
    {
        database[_idxHash].forceModCount = 0; //set to unspecified assetStatus
    }

    //--------------------------------External "write" contract functions / authuser---------------------------------//

    /*
     * @dev Make a new record in the database  *read fullHash, write rightsHolder, recorders, assetClass,countDownStart --new_record
     */
    function newRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external {

        require(
            database[_idxHash].rightsHolder == 0,
            "NR:ERR-Record already exists"
        );
        require(_rgt != 0, "NR:ERR-Rightsholder cannot be blank");

        Record memory _record;

        _record.assetClass = _assetClass;
        _record.countDownStart = _countDownStart;
        _record.countDown = _countDownStart;
        _record.recorder = _userHash;
        _record.rightsHolder = _rgt;
        _record.lastRecorder = _userHash;
        _record.forceModCount = 0;
        _record.Ipfs1 = _Ipfs1;

        database[_idxHash] = _record;

        emit REPORT("New record created");
    }

    /*
     * @dev Modify a record in the database  *read fullHash, write rightsHolder, update recorder, assetClass,countDown update recorder....
     *  prohibit changes to rightsholder / tokenID above assetClass 49999,
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount
    )
        external
        onlyAuthAddr
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {
        bytes32 idxHash = _idxHash;
        bytes32 rgtHash = _rgtHash;

        require(rgtHash != 0, "MR:ERR-Rightsholder cannot be blank");
        require( //prohibit increasing the countdown value
            _countDown <= database[idxHash].countDown,
            "MR:ERR-new countDown exceeds original countDown"
        );
        require(
            _forceCount >= database[idxHash].forceModCount,
            "MR:ERR-new forceModCount less than original forceModCount"
        );
        require(
            _assetStatus < 200,
            "MR:ERR-assetStatus over 199 cannot be set by user"
        );

        database[idxHash].timeLock = block.number;

        Record memory _record;
        _record = database[idxHash];

        _record.rightsHolder = rgtHash;

        if (_record.countDown >= _countDown) {
            _record.countDown = _countDown;
        }

        if (_assetStatus < 200) {
            _record.assetStatus = _assetStatus;
        }

        if (_record.forceModCount <= _forceCount) {
            _record.forceModCount = _forceCount;
        }


        database[idxHash] = _record;
        emit REPORT("Record modified");
    }

    function setStolenOrLost(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus
    )
        external
        onlyAuthAddr
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {
        bytes32 idxHash = _idxHash;
        bytes32 rgtHash = _rgtHash;

        require(rgtHash != 0, "MR:ERR-Rightsholder cannot be blank");
        require(
            (_assetStatus == 3) || (_assetStatus == 4) || (_assetStatus == 9) || (_assetStatus == 10),
            "MR:ERR-Must set to a lost or stolen status"
        );
        require(
            (database[idxHash].assetStatus != 5),
            "MR:ERR-Transferred status cannot be set to lost or stolen."
        );

        database[idxHash].timeLock = block.number;

        Record memory _record;
        _record = database[idxHash];

        _record.rightsHolder = rgtHash;

        if (_assetStatus < 200) {
            _record.assetStatus = _assetStatus;
        }

        database[idxHash] = _record;
        emit REPORT("Record modified");
    }

    /*
     * @dev Modify record Ipfs data
     */
    function modifyIpfs(
        bytes32 _idxHash,
        bytes32 _Ipfs1,
        bytes32 _Ipfs2
    )
        external
        onlyAuthAddr
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {
        string memory retMessage = "No modifications made";

        database[_idxHash].timeLock = block.number;

        Record memory _record = database[_idxHash];

        if (_record.Ipfs1 != _Ipfs1) {
            _record.Ipfs1 = _Ipfs1;
            retMessage = "Description Updated";
        }

        if (_record.Ipfs2 == 0) {
            _record.Ipfs2 = _Ipfs2;
            retMessage = "Note Added";
        }

        database[_idxHash] = _record;
        emit REPORT(retMessage);
    }

    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//
    /*
     * @dev return a complete record from the database
     */
    function retrieveRecord(bytes32 _idxHash)
        external
        view
        exists(_idxHash)
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
    {
        Record memory rec = database[_idxHash];

        return (
            rec.recorder,
            rec.rightsHolder,
            rec.lastRecorder,
            rec.assetStatus,
            rec.forceModCount,
            rec.assetClass,
            rec.countDown,
            rec.countDownStart,
            rec.Ipfs1,
            rec.Ipfs2
        );
    }

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     */
    function _verifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        view
        returns (uint256)
    {
        if (_rgtHash == database[_idxHash].rightsHolder) {
            return 170;
        } else {
            return 0;
        }
    }

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder (writes in blockchain)
     */
    function blockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint8)
    {
        if (_rgtHash == database[_idxHash].rightsHolder) {
            emit REPORT("Rights holder match confirmed");
            return 170;
        } else {
            emit REPORT("Rights holder does not match supplied data");
            return 0;
        }
    }

    /*
     * @dev Compare record.rightsholder with a hashed string  ///////////////TESTING ONLY REMOVE!
     */
    function ADMIN_compare_rgt(string calldata _idx, string calldata _rgt)
        external
        view
        isAdmin
        returns (string memory)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        bytes32 rgtHash = keccak256(abi.encodePacked(_rgt));
        rgtHash = keccak256(abi.encodePacked(idxHash, rgtHash));

        if (
            rgtHash == database[keccak256(abi.encodePacked(_idx))].rightsHolder
        ) {
            return "Rights holder match confirmed";
        } else {
            return "Rights holder does not match supplied data";
        }
    }

    /*
     * @dev //returns the address of a contract with name _name. This is for web3 implementations to find the right contract to interact with
     * example :  Frontend = ****** so web 3 first asks storage where to find frontend, then calls for frontend functions.
     */
    function resolveContractAddress(string calldata _name)
        external
        view
        returns (address)
    {
        return contractNames[_name];
    }


    //-----------------------------------------------Private functions------------------------------------------------//

    /*
     * @dev Update lastRecorder
     */
    function storeRecorder(
        bytes32 _idxHash,
        bytes32 _recorder
    ) external {

        if ( database[_idxHash].recorder != _recorder ){
            database[_idxHash].lastRecorder = database[_idxHash].recorder;
            database[_idxHash].recorder = _recorder;
        }
    }
}
