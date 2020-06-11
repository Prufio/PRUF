// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./Ownable.sol";

/*--------To do
 *Status 5  - Asset transferred - implies that asset holder is the owner.
 *       must be re-imported by ACadmin through regular onboarding process
 *       no actions besides modify RGT to a new rightsholder can be performed on a statuss 5 asset (no status changes) (Frontend)
 *
 * =Status 0 Default asset creation status,
 * default after FMR, and after status 5 (essentially a FMR) (IN frontend)
 * only type 1 can change a status 0 record
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
    mapping(bytes32 => User) private registeredUsers; // Authorized recorder database
    mapping(uint16 => Costs) private cost; // Cost per function by asset class

    /*  NOTES:---------------------------------------------------------------------------------------//
     * Authorized external Contract / address types:   authorizedAdresses[]
     * no user authorization required above asset class 8192
     * no contract authorization required above asset class 32768 - authentication done by ERC721 token only
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
     * 0 = no status, transferrable
     * 1 = transferrable
     * 2 = nontransferrable
     * 3 = stolen
     * 4 = lost
     * 255 = record locked (contract will not modify record without this first being unlocked by origin)
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
            ((authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] ==
                4) &&
                (registeredUsers[keccak256(abi.encodePacked(msg.sender))]
                    .userType == 99)) || (owner() == msg.sender),
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
    modifier userAuth(bytes32 _senderHash, bytes32 _idxHash) {
        uint8 senderType = registeredUsers[_senderHash].userType;

        require(
            (senderType == 1) || (senderType == 9),
            "MOD-UA-User not registered"
        );

        require(
            (database[_idxHash].assetClass ==
                registeredUsers[_senderHash].authorizedAssetClass),
            "MOD-UA-User not registered for asset type"
        );

        require(
            (database[_idxHash].assetStatus != 0) ||
                (registeredUsers[_senderHash].userType == 1),
            "MOD-UA-Non type 1 user cannot make changes to status 0 asset"
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
        require((database[_idxHash].assetStatus < 200), "MOD-U-record Locked");
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
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function OO_addUser(
        address _authAddr,
        uint8 _userType,
        uint16 _authorizedAssetClass
    ) external onlyOwner {
        require(
            (_userType == 0) ||
                (_userType == 1) ||
                (_userType == 9) ||
                (_userType == 99),
            "AU:ER-13 Invalid user type"
        );
        // require(
        //     _authorizedAssetClass < 32768,
        //     "AU:ERR--Auth by user prohibited in class 32768 or higher"
        // );

        bytes32 hash;
        hash = keccak256(abi.encodePacked(_authAddr));

        emit REPORT("internal user database access!"); //report access to the internal user database
        registeredUsers[hash].userType = _userType;
        registeredUsers[hash].authorizedAssetClass = _authorizedAssetClass;
    }

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
     * @dev Set function costs per asset class, in Wei
     */
    function OO_setCosts(
        uint16 _class,
        uint256 _newRecordCost,
        uint256 _transferRecordCost,
        uint256 _createNoteCost,
        uint256 _cost4,
        uint256 _cost5,
        uint256 _forceModCost
    ) external onlyOwner {
        require(
            _class < 32768,
            "ASc:ERR--Costs prohibited in class 32768 or higher"
        );
        cost[_class].cost1 = _newRecordCost;
        cost[_class].cost2 = _transferRecordCost;
        cost[_class].cost3 = _createNoteCost;
        cost[_class].cost4 = _cost4;
        cost[_class].cost5 = _cost5;
        cost[_class].cost6 = _forceModCost;
    }

    /*
     * @dev Allows Admin to set lock on asset
     */
    function ADMIN_lockStatus(bytes32 _idxHash, uint8 _stat)
        external
        isAdmin
        exists(_idxHash)
    {
        require(
            _stat > 199,
            "AL:ERR--locking requires setting assetStatus > 199"
        );
        database[_idxHash].assetStatus = _stat;
    }

    /*
     * @dev Allows Admin to unlock asset
     */
    function ADMIN_unlock(bytes32 _idxHash) external isAdmin exists(_idxHash) {
        database[_idxHash].assetStatus = 0; //set to unspecified assetStatus
    }

    /*
     * @dev Allows Admin to set time lock
     */
    function ADMIN_setTimelock(bytes32 _idxHash, uint256 _blockNumber)
        external
        isAdmin
        exists(_idxHash)
    {
        database[_idxHash].timeLock = _blockNumber; //set lock to expiration blocknumber
    }

    /*
     * @dev Allows Admin to reset force mod count
     */
    function ADMIN_resetFMC(bytes32 _idxHash)
        external
        isAdmin
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
            registeredUsers[_userHash].userType == 1, //cannot use userAuth because record[idx] doesnt exist yet
            "NR:ERR-User not registered"
        );
        require(
            (_assetClass == registeredUsers[_userHash].authorizedAssetClass), //cannot use userAuth because record[idx] doesnt exist yet,
            "NR:ERR-User not registered for asset class"
        );
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
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount
    )
        external
        onlyAuthAddr
        userAuth(_userHash, _idxHash)
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {
        bytes32 idxHash = _idxHash;
        bytes32 userHash = _userHash;
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

        (_record.recorder, _record.lastRecorder) = newRecorder(
            userHash,
            _record.recorder,
            _record.lastRecorder
        );

        database[idxHash] = _record;
        //database[_idxHash].timeLock = 0;
        emit REPORT("Record modified");
    }

    /*
     * @dev Modify record Ipfs data
     */
    function modifyIpfs(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs1,
        bytes32 _Ipfs2
    )
        external
        onlyAuthAddr
        userAuth(_userHash, _idxHash)
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {
        // uint256 tokenID = uint256(database[_idxHash].rightsHolder); //tokenID set to the uint256 of the rightsHolder hash at _idx
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

        (_record.recorder, _record.lastRecorder) = newRecorder(
            _userHash,
            _record.recorder,
            _record.lastRecorder
        );

        database[_idxHash] = _record;
        //database[_idxHash].timeLock = 0;
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
        uint8 senderType = registeredUsers[keccak256( //check for authorized user or automation agent  -- but no idx
            abi.encodePacked(msg.sender)
        )]
            .userType;

        require(
            (senderType == 1) || (senderType == 9),
            "Resolver:ERR - User not registered - contract resolution denied"
        );
        return contractNames[_name];
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function retrieveCosts(uint16 _assetClass)
        external
        view
        onlyAuthAddr
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            cost[_assetClass].cost1,
            cost[_assetClass].cost2,
            cost[_assetClass].cost3,
            cost[_assetClass].cost4,
            cost[_assetClass].cost5,
            cost[_assetClass].cost6
        );
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getUser(bytes32 _userHash)
        internal
        view
        onlyAuthAddr
        returns (
            uint8, // Human / Automated / Unauthorized
            uint16 // User authorized for specific asset class
        )
    {
        return (
            registeredUsers[_userHash].userType,
            registeredUsers[_userHash].userType
        );
    }

    //-----------------------------------------------Private functions------------------------------------------------//

    /*
     * @dev Update lastRecorder
     */
    function newRecorder(
        bytes32 _senderHash,
        bytes32 _recorder,
        bytes32 _lastRecorder
    ) private view returns (bytes32, bytes32) {
        bytes32 lastrec;

        if (
            ((registeredUsers[_recorder].userType == 1) ||
                (_recorder == keccak256(abi.encodePacked(owner())))) &&
            (_senderHash != _recorder)
        ) {
            lastrec = _recorder;
        } else {
            lastrec = _lastRecorder;
        }

        return (_senderHash, lastrec);
    }
}
