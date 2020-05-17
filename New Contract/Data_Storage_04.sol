// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./Ownable.sol";


contract Storage is Ownable {
    struct Record {
        bytes32 recorder; // Address hash of recorder
        bytes32 rightsHolder; // KEK256 Registered owner
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

    /*
     * Authorized external Contract / address types:   authorizedAdresses[]
     *
     * 0   --NONE
     * 1   --E
     * 2   --RE
     * 3   --RWE
     * 4  --Administrator
     * >4 NONE
     * Owner (onlyOwner)
     * other = unauth
     *
     * Authorized User Types   registeredUsers[]
     * 1 = Standard User
     * 9 = Robot
     * Other = unauth
     *
     */

    //----------------------------------------------Modifiers----------------------------------------------//

    /*
     * @dev Check msg.sender against authorized adresses
     */
    modifier addrAuth(uint8 _userType) {
        require(
            ((authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >=
                _userType) &&
                (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <=
                    4)),
            "Contract not authorized or improperly permissioned"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     */

    modifier userAuth(bytes32 _senderHash, bytes32 _idxHash) {
        uint8 senderType = registeredUsers[_senderHash].userType;

        require(
            (senderType == 1) ||
                (senderType == 9) ||
                (database[_idxHash].assetClass > 8192),
            "MOD-UA-User not registered"
        );

        require(
            (database[_idxHash].assetClass ==
                registeredUsers[_senderHash].authorizedAssetClass) ||
                (database[_idxHash].assetClass > 8192),
            "MOD-UA-User not registered for asset type"
        );
        _;
    }

    /*
     * @dev Check record exists and is not locked
     */

    modifier unlocked(bytes32 _idxHash) {
        require(database[_idxHash].status < 200, "MOD-U-record Locked");
        _;
    }

    /*
     * @dev Check record exists
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

    //--------------------------------Internal Admin functions / onlyowner---------------------------------//

    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function ADMIN_addUser(
        address _authAddr,
        uint8 _userType,
        uint16 _authorizedAssetClass
    ) external onlyOwner {
        require(
            (_userType == 0) || (_userType == 1) || (_userType == 9),
            "AUTHU:ER-13 Invalid user type"
        );

        bytes32 hash;
        hash = keccak256(abi.encodePacked(_authAddr));

        emit REPORT("internal user database access!"); //report access to the internal user database
        registeredUsers[hash].userType = _userType;
        registeredUsers[hash].authorizedAssetClass = _authorizedAssetClass;
    }

    /*
     * @dev Authorize / Deauthorize / Authorize ADRESSES permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function ADMIN_addContract(
        string calldata _name,
        address _addr,
        uint8 _contractAuthLevel
    ) external onlyOwner {
        require(_contractAuthLevel <= 3, "AUTHC:ER-13 Invalid user type");
        emit REPORT("internal user database access!"); //report access to the internal user database

        authorizedAdresses[keccak256(
            abi.encodePacked(_addr)
        )] = _contractAuthLevel;
        contractNames[_name] = _addr;
    }

    /*
     * @dev Set function costs per asset class, in Wei
     */
    function ADMIN_setCosts(
        uint16 _class,
        uint256 _newRecordCost,
        uint256 _transferRecordCost,
        uint256 _createNoteCost,
        uint256 _cost4,
        uint256 _cost5,
        uint256 _forceModCost
    ) external onlyOwner {
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
    function ADMIN_lockStatus(string calldata _idx, uint8 _stat)
        external
        onlyOwner
    {
        //---------------------------------------INSECURE USE HASH!!!!

        require(_stat > 199, "AL:ERR--locking requires status > 199");

        bytes32 _idxHash = keccak256(abi.encodePacked(_idx)); // TESTING ONLY
        database[_idxHash].status = _stat;
    }

    /*
     * @dev Allows Admin to unlock asset
     */
    function ADMIN_unlock(string calldata _idx) external onlyOwner {
        //---------------------------------------INSECURE USE HASH!!!!
        //for testing only should be (b32 _idxHash) exists(_idxHash) onlyOwner
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx)); // TESTING ONLY
        database[_idxHash].status = 0; //set to unspecified status
    }

    /*
     * @dev Allows Admin to set time lock
     */
    function ADMIN_setTimelock(string calldata _idx, uint256 _blockNumber)
        external
        onlyOwner
    {
        //---------------------------------------INSECURE USE HASH!!!!
        //for testing only should be (b32 _idxHash) exists(_idxHash) onlyOwner
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx)); // TESTING ONLY
        database[_idxHash].timeLock = _blockNumber; //set lock to expiration blocknumber
    }

    /*
     * @dev Allows Admin to reset force mod count
     */
    function ADMIN_resetFMC(string calldata _idx) external onlyOwner {
        //---------------------------------------INSECURE USE HASH!!!!
        //for testing only should be (b32 _idxHash) exists(_idxHash) onlyOwner
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx)); // TESTING ONLY
        database[_idxHash].forceModCount = 0; //set to unspecified status
    }

    //--------------------------------External contract functions / authuser---------------------------------//

    /*
     * @dev Make a new record in the database  *read fullHash, write rightsHolder, recorders, assetClass,countDownStart --new_record
     */

    function newRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _IPFS1
    ) external addrAuth(3) {
        require(
            registeredUsers[_userHash].userType == 1 || (_assetClass > 8192),
            "NR:ERR-User not registered"
        );

        require(
            (_assetClass == registeredUsers[_userHash].authorizedAssetClass) ||
                (_assetClass > 8192),
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
        _record.IPFS1 = _IPFS1;

        database[_idxHash] = _record;
    }

    /*
     * @dev Modify a record in the database  *read fullHash, write rightsHolder, update recorder, assetClass,countDown update recorder....
     */

    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _regHash,
        uint8 _status,
        uint256 _countDown,
        uint8 _forceCount
    )
        external
        addrAuth(3)
        userAuth(_userHash, _idxHash)
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {
        require(_regHash != 0, "MR:ERR-Rightsholder cannot be blank");

        require(
            _countDown <= database[_idxHash].countDown,
            "MR:ERR-new countDown exceeds original countDown"
        );

        require(
            _forceCount >= database[_idxHash].forceModCount,
            "MR:ERR-new forceModCount less than original forceModCount"
        );

        require(_status < 200, "MR:ERR-status over 199 cannot be set by user");

        database[_idxHash].timeLock = block.number;

        Record memory _record;
        _record = database[_idxHash];
        _record.rightsHolder = _regHash;
        _record.countDown = _countDown;
        _record.status = _status;
        _record.forceModCount = _forceCount;

        (_record.recorder, _record.lastRecorder) = newRecorder(
            _userHash,
            _record.recorder,
            _record.lastRecorder
        );

        database[_idxHash] = _record;
        database[_idxHash].timeLock = 0;
    }

    /*
     * @dev Modify record IPFS data
     */
    function modifyIPFS(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _IPFS1,
        bytes32 _IPFS2
    )
        external
        addrAuth(3)
        userAuth(_userHash, _idxHash)
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {
        database[_idxHash].timeLock = block.number;

        Record memory _record = database[_idxHash];

        if (_record.IPFS1 != _IPFS1) {
            _record.IPFS1 = _IPFS1;
        }

        if (_record.IPFS2 == 0) {
            _record.IPFS2 = _IPFS2;
        }

        (_record.recorder, _record.lastRecorder) = newRecorder(
            _userHash,
            _record.recorder,
            _record.lastRecorder
        );

        database[_idxHash] = _record;
        database[_idxHash].timeLock = 0;
    }

    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */

    function retrieveCosts(uint16 _assetClass)
        external
        view
        addrAuth(3)
        returns (uint256, uint256, uint256, uint256, uint256, uint256)
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

    function retrieveRecord(bytes32 _idxHash)
        external
        view
        addrAuth(2)
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
            rec.status,
            rec.forceModCount,
            rec.assetClass,
            rec.countDown,
            rec.countDownStart,
            rec.IPFS1,
            rec.IPFS2
        );
    }

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     */
    function CompareRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        public
        view
        addrAuth(1)
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

    function BlockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        addrAuth(1)
        returns (uint8)
    {
        if (_rgtHash == database[_idxHash].rightsHolder) {
            emit REPORT("Rights holder match confirmed");
            return 170;
        } else {
            emit REPORT("Rights holder does not match");
            return 0;
        }
    }

    /*
     * @dev Compare record.rightsholder with a hashed string
     */
    function Admin_compare_rgt(string calldata _idx, string calldata _rgt)
        external
        view
        onlyOwner
        returns (string memory)
    {
        if (
            keccak256(abi.encodePacked(_rgt)) ==
            database[keccak256(abi.encodePacked(_idx))].rightsHolder
        ) {
            return "Rights holder match confirmed";
        } else {
            return "Rights holder does not match";
        }
    }

    /*
     * @dev //returns the address of a contract with name _name. This is for web3 implementations to find the right contract to interact with
     * example :  Frontend = ****** so web 3 first asks storage where to find frontend, then calls for frontend functions.
     */
    function ResolveContractAddress(string calldata _name)
        external
        view
        returns (address)
    {
        uint8 senderType = registeredUsers[keccak256(
            abi.encodePacked(msg.sender)
        )]
            .userType;

        require(
            (senderType == 1) || (senderType == 9),
            "MOD-UA-User not registered - contract resolution denied"
        );
        return contractNames[_name];
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
