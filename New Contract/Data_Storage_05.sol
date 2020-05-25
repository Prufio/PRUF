// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./Ownable.sol";


// interface erc20_tokenInterface {
//     function transfer(address, uint256) external returns (bool);
//     function balanceOf(address) external view returns (uint256);
// }

interface erc721_tokenInterface {
    function ownerOf(uint256) external view returns (address);
}


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

    //address erc20_tokenAddress;
    address erc721ContractAddress;
    erc721_tokenInterface erc721_tokenContract; //erc721_token prototype initialization

    /*  NOTES:---------------------------------------------------------------------------------------//
     * Authorized external Contract / address types:   authorizedAdresses[]
     * no user authorization required above asset class 8192
     * no contract authorization required above asset class 32768 - authentication done by ERC721 token only
     *
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
     * rgtHash = K256(abiPacked(idxHash,rgtHash))
     */


    //----------------------------------------------Modifiers----------------------------------------------//

    /*
     * @dev Check msg.sender against authorized adresses
     * msg.sender
     *      Exists in registeredUsers as a usertype 99
     *      Exists in authorizedAddress as a contract type 4
     *      Is authorized for asset class
     *
     */
    modifier isAdmin() {
                require(
            ((authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] == 4)  &&
            (registeredUsers[keccak256(abi.encodePacked(msg.sender))].userType == 99)) 
        );
        _;
    }

    /*
     * @dev Verify user credentials
     *
     * Originating Address:  (call may pass through a contract before it arrives )
     * If assetClass is 8192 or less;
     *      Exists in registeredUsers as a usertype 1 or 9
     *      Is authorized for asset class
     *If assetClass is 32768 or greater , msg.sender hods a token whose hashed
     *      tokenID is identical to the rightsHolder
     */
    modifier userAuth(bytes32 _senderHash, bytes32 _idxHash) {
        uint8 senderType = registeredUsers[_senderHash].userType;

        uint256 tokenID = uint256(database[_idxHash].rightsHolder);  //tokenID set to the uint256 of the rightsHolder hash at _idx

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
        require(
            (database[_idxHash].assetClass < 32768) ||
                (erc721_tokenContract.ownerOf(tokenID) == msg.sender),
            "MOD:ERR-User address does not hold asset token"
        );
        _;
    }

    /*
     * @dev Check record _idxHash exists and is not locked
     */
    modifier unlocked(bytes32 _idxHash) {
        require(
            (database[_idxHash].assetStatus < 200) &&
                (database[_idxHash].assetClass < 32768),
            "MOD-U-record Locked"
        );
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





    //--------------------------------Internal Admin functions / onlyowner---------------------------------//

    // function setErc20_tokenAddress (address contractAddress) public onlyOwner {
    //     require(contractAddress != address(0), "Invalid contract address");
    //     erc20_tokenAddress = contractAddress;
    //     erc20_tokenContract = erc20_tokenInterface(contractAddress);
    // }
    //erc20_tokenInterface erc20_tokenContract; //erc20_token

    function setErc721_tokenAddress(address _contractAddress) public onlyOwner {
        require(_contractAddress != address(0), "Invalid contract address");
        erc721ContractAddress = _contractAddress;
        erc721_tokenContract = erc721_tokenInterface(_contractAddress);
    }
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
            (_userType == 0) || (_userType == 1) || (_userType == 9) || (_userType == 99),
            "AU:ER-13 Invalid user type"
        );
        require(
            _authorizedAssetClass < 32768,
            "AU:ERR--Auth by user prohibited in class 32768 or higher"
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
        require(_contractAuthLevel <= 3, "AC:ER-13 Invalid user type");
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
    function ADMIN_lockStatus(string calldata _idx, uint8 _stat)
        external
        onlyOwner
    {
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx)); // TESTING ONLY
        //for testing only should be (b32 _idxHash) exists(_idxHash) onlyOwner
        //---------------------------------------INSECURE USE HASH!!!!
        require(
            database[_idxHash].assetClass < 32768,
            "AL:ERR--locking prohibited in class 32768 or higher"
        );
        require(
            _stat > 199,
            "AL:ERR--locking requires setting assetStatus > 199"
        );
        database[_idxHash].assetStatus = _stat;
    }

    /*
     * @dev Allows Admin to unlock asset
     */
    function ADMIN_unlock(string calldata _idx) external onlyOwner {
        //---------------------------------------INSECURE USE HASH!!!!
        //for testing only should be (b32 _idxHash) exists(_idxHash) onlyOwner
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx)); // TESTING ONLY
        require(
            database[_idxHash].assetClass < 32768,
            "AL:ERR--admin edits prohibited in class 32768 or higher"
        );
        database[_idxHash].assetStatus = 0; //set to unspecified assetStatus
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
        require(
            database[_idxHash].assetClass < 32768,
            "AL:ERR--admin edits prohibited in class 32768 or higher"
        );
        database[_idxHash].timeLock = _blockNumber; //set lock to expiration blocknumber
    }

    /*
     * @dev Allows Admin to reset force mod count
     */
    function ADMIN_resetFMC(string calldata _idx) external onlyOwner {
        //---------------------------------------INSECURE USE HASH!!!!
        //for testing only should be (b32 _idxHash) exists(_idxHash) onlyOwner
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx)); // TESTING ONLY
        require(
            database[_idxHash].assetClass < 32768,
            "AL:ERR--admin edits prohibited in class 32768 or higher"
        );
        database[_idxHash].forceModCount = 0; //set to unspecified assetStatus
    }


    function tokentest ( bytes32 _rgt, bytes32 _idx) external view returns (string memory ,uint256, string memory, uint256, string memory, address) {
         uint256 tokenID = uint256(_rgt);  //tokenID set to the uint256 of the supplied rgt
         uint256 DBtokenID = uint256(database[_idx].rightsHolder);  //tokenID set to the uint256 of the rightsHolder hash at _idx
         address tokenAdresss = erc721_tokenContract.ownerOf(tokenID);
         return ("token ID :", tokenID, "  token ID from DB :", DBtokenID,"  holder of token :", tokenAdresss);
        
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
        bytes32 _Ipfs1
    ) public {
        uint256 tokenID = uint256(_rgt);  //tokenID set to the uint256 of the supplied rgt

        require(
            registeredUsers[_userHash].userType == 1 || (_assetClass > 8192), //cannot use userAuth because record[idx] doesnt exist yet
            "NR:ERR-User not registered"
        );
        require(
            (_assetClass == registeredUsers[_userHash].authorizedAssetClass) || //cannot use userAuth because record[idx] doesnt exist yet
                (_assetClass > 8192),
            "NR:ERR-User not registered for asset class"
        );

        require(
            ((authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >= 3)  &&
            (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <= 4)) ||
            (database[_idxHash].assetClass >= 32768),
            "Contract not authorized or improperly permissioned"
        );
        require(
            database[_idxHash].rightsHolder == 0,
            "NR:ERR-Record already exists"
        );
        require(_rgt != 0, "NR:ERR-Rightsholder cannot be blank");
        require(
            (_assetClass < 32768) ||
                (erc721_tokenContract.ownerOf(tokenID) == msg.sender),
            "NR:ERR-User address does not hold asset token"
        );

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
     */
    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _regHash,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount
    )
        public
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
        require(
            _assetStatus < 200,
            "MR:ERR-assetStatus over 199 cannot be set by user"
        );

        require( //Moved addressAuth functionality here for stack saving
            (((authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >=
                3) &&
                (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <=
                    4)) || (database[_idxHash].assetClass >= 32768)),
            "Contract not authorized or improperly permissioned"
        );

        database[_idxHash].timeLock = block.number;

        Record memory _record;
        _record = database[_idxHash];

        _record.rightsHolder = _regHash;
        _record.countDown = _countDown;
        _record.assetStatus = _assetStatus;
        _record.forceModCount = _forceCount;

        (_record.recorder, _record.lastRecorder) = newRecorder(
            _userHash,
            _record.recorder,
            _record.lastRecorder
        );

        database[_idxHash] = _record;
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
        public
        userAuth(_userHash, _idxHash)
        exists(_idxHash)
        unlocked(_idxHash)
        notTimeLocked(_idxHash)
    {

        require(
            ((authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >= 3)  &&
            (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <= 4)) ||
            (database[_idxHash].assetClass >= 32768),
            "Contract not authorized or improperly permissioned"
        );

        database[_idxHash].timeLock = block.number;

        Record memory _record = database[_idxHash];

        if (_record.Ipfs1 != _Ipfs1) {
            _record.Ipfs1 = _Ipfs1;
        }

        if (_record.Ipfs2 == 0) {
            _record.Ipfs2 = _Ipfs2;
        }

        (_record.recorder, _record.lastRecorder) = newRecorder(
            _userHash,
            _record.recorder,
            _record.lastRecorder
        );

        database[_idxHash] = _record;
        //database[_idxHash].timeLock = 0;
        emit REPORT("Record modified");
    }










    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function retrieveCosts(uint16 _assetClass)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        require( //SUBSET of addressAuth functionality does not include exception for > 32768 assetClass
            (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >=
                3) &&
                (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <=
                    4),
            "Contract not authorized or improperly permissioned"
        );
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
        uint256 tokenID = uint256(database[_idxHash].rightsHolder);  //tokenID set to the uint256 of the rightsHolder hash at _idx

        require(
            (((authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >=
                3) &&
                (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <=
                    4)) || (database[_idxHash].assetClass >= 32768)),
            "Contract not authorized or improperly permissioned"
        );
        require(
            (database[_idxHash].assetClass < 32768) ||
                (erc721_tokenContract.ownerOf(tokenID) == msg.sender),
            "NR:ERR-User address does not hold asset token"
        );

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
        public
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
        onlyOwner
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
}
