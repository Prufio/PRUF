/*  TO DO
 * integration of ACtoken requirements?
 * integration of assetToken Checks ? (userHash must hold token if asset token exists?)
 * implement stolenOrLost
 * implement escrow


        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //uint256 assetTokenID = uint256(_idxHash); //tokenID set to the uint256 of the supplied IDX for token verification
        uint256 assetClass256 = uint256(_assetClass);
        // require( //origin address holds asset token if asset class is 30,000 or more
        //     (_assetClass < 30000) ||
        //     (assetTokenContract.ownerOf(assetTokenID) == message_origin),
        //     "NR:ERR-User address does not hold asset token"
        // );
        require( //origin address holds assetClass token, or assetClass is >60000
                (_assetClass >= 65000) ||
                (ACtokenContract.ownerOf(assetClass256) == message_origin),
            "NR:ERR-Contract not authorized in asset class"
        );


*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./Ownable.sol";

interface assetTokenInterface {
    function ownerOf(uint256) external view returns (address);
    //function mint(uint256) external view returns (address);
    //function transfer(uint256,address) external view returns (address);
}

interface ACtokenInterface {
    function ownerOf(uint256) external view returns (address);
    //function mint(uint256) external view returns (address);
    //function transfer(uint256,address) external view returns (address);
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
        uint256 cost1; // Cost to create a new record / mint asset
        uint256 cost2; // Cost to transfer a record from known rights holder to a new one
        uint256 cost3; // Cost to add a static note to an asset
        uint256 cost4; // Cost to remint an asset
        uint256 cost5; // Cost to change asset status
        uint256 cost6; // Cost to brute-force a record transfer
    }

    mapping(bytes32 => uint8) private contractAdresses; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNames; // Authorized contract addresses, indexed by name
    mapping(bytes32 => Record) private database; // Main Data Storage
    mapping(uint16 => Costs) private cost; // Cost per function by asset class

    // address minterContractAddress;
    // address assetContractAddress;
    // assetTokenInterface assetTokenContract; //erc721_token prototype initialization
    address ACcontractAddress;
    ACtokenInterface ACtokenContract; //erc721_token prototype initialization

    /*  NOTES:---------------------------------------------------------------------------------------//
     * Authorized external Contract / address types:   contractAdresses[]
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
            (contractAdresses[keccak256(abi.encodePacked(msg.sender))] == 4) ||
                (owner() == msg.sender),
            "MOD-ISADMINaddress does not belong to an Admin"
        );
        _;
    }

    modifier isACtokenHolder(bytes32 _idxHash) {
        uint256 assetClass256 = uint256(database[_idxHash].assetClass);
        require( //origin address holds assetClass token, or assetClass is >=65000
            (database[_idxHash].assetClass >= 65000) ||
                (ACtokenContract.ownerOf(assetClass256) == msg.sender),
            "MOD-ACTH-Contract not authorized in asset class"
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
    modifier isAuthorized() {
        require(
            (contractAdresses[keccak256(abi.encodePacked(msg.sender))] == 3),
            "MOD-IA-Contract not authorized or improperly permissioned"
        );
        _;
    }

    /*
     * @dev Check record _idxHash exists and is not locked
     */
    modifier notEscrow(bytes32 _idxHash) {
        require(
            ((database[_idxHash].assetStatus != 6) &&
                (database[_idxHash].assetStatus != 12)) ||
                database[_idxHash].timeLock < now, //Since time here is +/1 a day or so, now can be used as per the 15 second rule (consensys)
            "MOD-U-record modification prohibited while locked in escrow"
        );
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
     * @dev Address Setters
     */
    // function OO_set_Asset_token(address _contractAddress)
    //     external
    //     onlyOwner
    // {
    //     require(_contractAddress != address(0), "Invalid contract address");
    //     assetContractAddress = _contractAddress;
    //     assetTokenContract = assetTokenInterface(_contractAddress);
    // }

    function OO_set_AC_token(address _contractAddress) external onlyOwner {
        require(_contractAddress != address(0), "Invalid contract address");
        ACcontractAddress = _contractAddress;
        ACtokenContract = ACtokenInterface(_contractAddress);
    }

    // function OO_setMinterAddress(address _contractAddress)
    //     external
    //     onlyOwner
    // {
    //     require(_contractAddress != address(0), "Invalid contract address");
    //     minterContractAddress = _contractAddress;
    // }

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

        contractAdresses[keccak256(
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
        uint256 _reMintRecordCost,
        uint256 _modifyStatusCost,
        uint256 _forceModCost
    ) external onlyOwner {
        cost[_class].cost1 = _newRecordCost;
        cost[_class].cost2 = _transferRecordCost;
        cost[_class].cost3 = _createNoteCost;
        cost[_class].cost4 = _reMintRecordCost;
        cost[_class].cost5 = _modifyStatusCost;
        cost[_class].cost6 = _forceModCost;
    }

    /*
     * @dev Allows Admin to reset force mod count
     */
    function ADMIN_resetFMC(bytes32 _idxHash)
        external
        isAdmin
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
    ) external isAuthorized {
        uint256 assetClass256 = uint256(_assetClass);
        require( //origin address holds assetClass token, or assetClass is >=65000
            (database[_idxHash].assetClass >= 65000) ||
                (ACtokenContract.ownerOf(assetClass256) == msg.sender),
            "NR:ERR-Contract not authorized in asset class"
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
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
        notTimeLocked(_idxHash)
        isACtokenHolder(_idxHash)
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
        Record memory _record = database[_idxHash];

        (_record.lastRecorder, _record.recorder) = storeRecorder(
            _idxHash,
            _userHash
        );
        _record.rightsHolder = rgtHash;
        _record.countDown = _countDown;
        _record.assetStatus = _assetStatus;
        _record.forceModCount = _forceCount;

        database[idxHash] = _record;
        emit REPORT("Record modified");
    }

    function setStolenOrLost(
        bytes32 _userHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus
    )
        external
        isAuthorized
        exists(_idxHash)
        notTimeLocked(_idxHash)
        isACtokenHolder(_idxHash)
    {
        _idxHash;

        require(
            (_newAssetStatus == 3) ||
                (_newAssetStatus == 4) ||
                (_newAssetStatus == 9) ||
                (_newAssetStatus == 10),
            "MR:ERR-Must set to a lost or stolen status"
        );
        require(
            (database[_idxHash].assetStatus != 5),
            "MR:ERR-Transferred status cannot be set to lost or stolen."
        );
        require(
            _newAssetStatus < 200,
            "MR:ERR-assetStatus over 199 cannot be set by user"
        );

        database[_idxHash].timeLock = block.number;
        Record memory _record = database[_idxHash];

        (_record.lastRecorder, _record.recorder) = storeRecorder(
            _idxHash,
            _userHash
        );
        _record.assetStatus = _newAssetStatus;

        database[_idxHash] = _record;
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
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
        notTimeLocked(_idxHash)
        isACtokenHolder(_idxHash)
    {
        string memory retMessage = "No modifications made";

        database[_idxHash].timeLock = block.number;
        Record memory _record = database[_idxHash];

        if (_record.Ipfs1 != _Ipfs1) {
            _record.Ipfs1 = _Ipfs1;
            (_record.lastRecorder, _record.recorder) = storeRecorder(
                _idxHash,
                _userHash
            );
            retMessage = "Description Updated";
        }

        if (_record.Ipfs2 == 0) {
            _record.Ipfs2 = _Ipfs2;
            (_record.lastRecorder, _record.recorder) = storeRecorder(
                _idxHash,
                _userHash
            );
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
     * @dev Retrieve function costs per asset class, in Wei
     */
    function retrieveCosts(uint16 _assetClass)
        external
        view
        isAuthorized
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        Costs memory _returnCosts = cost[_assetClass];
        return (
            _returnCosts.cost1,
            _returnCosts.cost2,
            _returnCosts.cost3,
            _returnCosts.cost4,
            _returnCosts.cost5,
            _returnCosts.cost6
        );
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
        //storeRecorder(_idxHash, _recorder) returns (lastRecorder,recorder)
        bytes32 _idxHash,
        bytes32 _recorder
    ) internal view returns (bytes32, bytes32) {
        if (database[_idxHash].recorder != _recorder) {
            return (database[_idxHash].recorder, _recorder);
        } else {
            return (database[_idxHash].lastRecorder, _recorder);
        }
    }
}
