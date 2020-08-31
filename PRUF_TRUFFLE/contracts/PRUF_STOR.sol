/*-----------------------------------------------------------V0.6.8
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  PRUF STOR is the primary data repository for the PRUF system. No direct user writes are permitted in STOR, all data must come from explicitly approved contracts.
 *  PRUF STOR  stores records in a map of Records, foreward and reverse name resolution for approved contracts, as well as contract authorization data.
 *---------------------------------------------------------------*/

/*-----------------------------------------------------------------
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, custodial classes are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
 *-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/Ownable.sol";
import "./Imports/Pausable.sol";
import "./Imports/SafeMath.sol";
import "./Imports/ReentrancyGuard.sol";

contract STOR is Ownable, ReentrancyGuard, Pausable {
    struct Record {
        // Still have room for a free bytes(16) or a uint 128 !!!
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 numberOfTransfers; //number of transfers and forcemods
        uint32 assetClass; // Type of asset
        uint32 countDown; // Variable that can only be dencreased from countDownStart
        uint32 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        bytes32 rightsHolder; // KEK256 Registered owner
    }

    mapping(string => mapping(uint32 => uint8)) internal contractInfo; // name=>AC=>authorization level
    mapping(address => string) private contractAddressToName; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNameToAddress; // Authorized contract addresses, indexed by name

    mapping(bytes32 => Record) private database; // Main Data Storage

    address private AC_TKN_Address;
    AC_TKN_Interface private AC_TKN; //erc721_token prototype initialization

    address internal AC_MGR_Address;
    AC_MGR_Interface internal AC_MGR; // Set up external contract interface for AC_MGR

    //----------------------------------------------Modifiers----------------------------------------------//

    /*
     * @dev Verify user credentials
     *
     * Originating Address is authorized for asset class
     */
    modifier isAuthorized(uint32 _assetClass) {
        uint8 auth = contractInfo[contractAddressToName[msg
            .sender]][_assetClass];
        require(
            ((auth > 0) && (auth < 5)) || (auth == 10),
            "S:MOD-IA:Contract not authorized"
        );
        _;
    }

    /*
     * @dev Check record _idxHash is not in escrow
     */
    modifier notEscrow(bytes32 _idxHash) {
        require(
            isEscrow(database[_idxHash].assetStatus) == 0,
            "S:MOD-NE:rec locked in ecr"
        );
        _;
    }

    /*
     * @dev Check record _idxHash exists in database
     */
    modifier exists(bytes32 _idxHash) {
        require(
            database[_idxHash].assetClass != 0,
            "S:MOD-E:rec does not exist"
        );
        _;
    }

    /*
     * @dev Check to see if contract address resolves to ECR_MGR
     */
    modifier isEscrowManager() {
        require(
            msg.sender == contractNameToAddress["ECR_MGR"],
            "S:MOD-IEM:Caller not ECR_MGR"
        );
        _;
    }

    /*
     * @dev Check to see a status matches lost or stolen status
     */
    function isLostOrStolen(uint8 _assetStatus) private pure returns (uint8) {
        if (
            (_assetStatus != 3) &&
            (_assetStatus != 4) &&
            (_assetStatus != 53) &&
            (_assetStatus != 54)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    /*
     * @dev Check to see a status matches transferred status
     */
    function isTransferred(uint8 _assetStatus) private pure returns (uint8) {
        if ((_assetStatus != 5) && (_assetStatus != 55)) {
            return 0;
        } else {
            return 170;
        }
    }

    /*
     * @dev Check to see a status matches escrow status
     */
    function isEscrow(uint8 _assetStatus) private pure returns (uint8) {
        if (
            (_assetStatus != 6) &&
            (_assetStatus != 50) &&
            (_assetStatus != 60) &&
            (_assetStatus != 56)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    //-----------------------------------------------Events------------------------------------------------//

    event REPORT(string _msg, bytes32 b32);

    //--------------------------------Internal Admin functions / onlyowner or isAdmin---------------------------------//

    /*
     * @dev Triggers stopped state. (pausable)
     */
    function pause() external onlyOwner {
        _pause();
    }

    /*
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*
     * @dev Authorize / Deauthorize / Authorize ADRESSES permitted to make record modifications, per AssetClass
     * populates contract name resolution and data mappings
     */
    function OO_addContract(
        string calldata _name,
        address _addr,
        uint32 _assetClass,
        uint8 _contractAuthLevel
    ) external onlyOwner {
        require(_assetClass == 0, "S:AC: AC not 0");
        require(_contractAuthLevel <= 4, "S:AC: Invalid auth lv");
        //^^^^^^^checks^^^^^^^^^

        contractInfo[_name][_assetClass] = _contractAuthLevel;  //does not pose an partial record overwrite risk
        contractNameToAddress[_name] = _addr; //does not pose an partial record overwrite risk
        contractAddressToName[_addr] = _name; //does not pose an partial record overwrite risk

        AC_TKN = AC_TKN_Interface(contractNameToAddress["AC_TKN"]);
        AC_MGR = AC_MGR_Interface(contractNameToAddress["AC_MGR"]);
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Authorize / Deauthorize / Authorize contract NAMES permitted to make record modifications, per AssetClass
     * allows ACtokenHolder to auithorize or deauthorize specific contracts to work within their asset class
     */
    function enableContractForAC(
        string calldata _name,
        uint32 _assetClass,
        uint8 _contractAuthLevel
    ) external {
        require(
            AC_TKN.ownerOf(_assetClass) == msg.sender,
            "S:ECFAC:Caller not ACtokenHolder"
        );

        //^^^^^^^checks^^^^^^^^^

        contractInfo[_name][_assetClass] = _contractAuthLevel; //does not pose an partial record overwrite risk
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External "write" contract functions / authuser---------------------------------//

    /*
     * @dev Make a new record, writing to the 'database' mapping with basic initial asset data
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_assetClass) //calling contract must be authorized in relevant assetClass
    {
        require(
            database[_idxHash].assetStatus != 60,
            "S:NR:Asset is rcycl. Use PRUF_APP_NC rcycl"
        );
        require(database[_idxHash].assetClass == 0, "S:NR:Rec already exists");
        require(_rgtHash != 0, "S:NR:RGT = 0");
        require(_assetClass != 0, "S:NR:AC = 0");
        //^^^^^^^checks^^^^^^^^^

        Record memory rec;

        if (contractInfo[contractAddressToName[msg.sender]][_assetClass] == 1) {
            rec.assetStatus = 0;
        } else {
            rec.assetStatus = 51;
        }

        rec.assetClass = _assetClass;
        rec.countDownStart = _countDownStart;
        rec.countDown = _countDownStart;
        rec.rightsHolder = _rgtHash;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("NEW REC", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify a record, writing to the 'database' mapping with updates to multiple fields
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint32 _countDown,
        uint256 _incrementForceModCount,
        uint256 _incrementNumberOfTransfers
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        bytes32 idxHash = _idxHash; //stack saving

        require(_countDown <= rec.countDown, "S:MR:countDown +!"); //prohibit increasing the countdown value  //REDUNDANT, THROWS IN SAFEMATH
        require(isLostOrStolen(_newAssetStatus) == 0, "S:MR:Must use L/S");
        require(isEscrow(_newAssetStatus) == 0, "S:MR:Must use ECR");
        // require(
        //     (_newAssetStatus != 7) &&
        //         (_newAssetStatus != 57) &&
        //         (_newAssetStatus != 58),
        //     "S:MR: Stat Rsrvd"
        // );
        require(_rgtHash != 0, "S:MR: rgtHash = 0");
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        rec.countDown = _countDown;
        rec.assetStatus = _newAssetStatus;

        if ((_incrementForceModCount == 170) && (rec.forceModCount < 255)) {
            rec.forceModCount = rec.forceModCount + 1;
        }
        if (
            (_incrementNumberOfTransfers == 170) &&
            (rec.numberOfTransfers < 65535)
        ) {
            rec.numberOfTransfers = rec.numberOfTransfers + 1;
        }

        database[idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("REC MOD", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Change asset class of an asset - writes to assetClass in the 'Record' struct of the 'database' at _idxHash
     */
    function changeAC(bytes32 _idxHash, uint32 _newAssetClass)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        notEscrow(_idxHash) // asset must not be held in escrow status
        isAuthorized(0) //is an authorized contract, generically
    {
        Record memory rec = database[_idxHash];

        require(_newAssetClass != 0, "S:CAC:Cannot set AC-0");
        require( //require new assetClass is in the same root as old assetClass
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "S:CAC:Cannot mod AC to new root"
        );
        require((isLostOrStolen(rec.assetStatus) == 0), "S:CAC:L/S asset"); //asset cannot be in lost or stolen status
        require((isTransferred(rec.assetStatus) == 0), "S:CAC:Txfrd asset"); //asset cannot be in transferred status
        //^^^^^^^checks^^^^^^^^^

        rec.assetClass = _newAssetClass;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("UPD AC", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset to stolen or lost. Allows narrow modification of status 6/12 assets, normally locked
     */
    function setStolenOrLost(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
    {
        Record memory rec = database[_idxHash];

        require(
            isLostOrStolen(_newAssetStatus) == 170, //proposed new status must be L/S status
            "S:SSL:Must set to L/S"
        );
        require( //asset cannot be set l/s if in transferred or locked escrow status
            (rec.assetStatus != 5) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 55), //STATE UNREACHABLE TO SET TO STAT 55 IN CURRENT CONTRACTS
            "S:SSL:Txfr or ecr-locked asset != L/S."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        // if ((_newAssetStatus == 3) || (_newAssetStatus == 53)) {
        //     emit REPORT("STOLEN", _idxHash);
        // } else {
        //     emit REPORT("LOST", _idxHash);
        // }
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset to escrow locked status (6/50/56).
     */
    function setEscrow(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isEscrowManager
        exists(_idxHash) //asset must exist in 'database'
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require(isEscrow(_newAssetStatus) == 170, "S:SE: stat must = ecr"); //proposed new status must be an escrow status
        require((isLostOrStolen(rec.assetStatus) == 0), "S:MI2:L/S asset"); //asset cannot be in lost or stolen status
        require((isTransferred(rec.assetStatus) == 0), "S:MI2: Txfrd asset"); //asset cannot be in transferred status
        //^^^^^^^checks^^^^^^^^^

        if (_newAssetStatus == 60) {
            //if setting to "discarded" status, set rgt to 0xFFF... (to prevent reminting)
            rec
                .rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        }

        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        //emit REPORT("ECR SET", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status. Implicitly trusts escrowManager ECR_MGR contract
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        isEscrowManager //calling contract must be ECR_MGR
        exists(_idxHash) //asset must exist in 'database'
    {
        Record memory rec = database[_idxHash];
        require(isEscrow(rec.assetStatus) == 170, "S:EE:! ecr stat"); //asset must be in an escrow status
        //^^^^^^^checks^^^^^^^^^

        if (rec.assetStatus == 6) {
            rec.assetStatus = 7;
        }
        if (rec.assetStatus == 56) {
            rec.assetStatus = 57;
        }
        if (rec.assetStatus == 50) {
            rec.assetStatus = 58;
        }
        if (rec.assetStatus == 60) {
            rec.assetStatus = 58;
        }

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        //emit REPORT("ECR END:", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify record Ipfs1 data
     */
    function modifyIpfs1(bytes32 _idxHash, bytes32 _Ipfs1)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require((isTransferred(rec.assetStatus) == 0), "S:MI2: Txfrd asset"); //asset cannot be in transferred status

        require((rec.Ipfs1 != _Ipfs1), "S:MI1: New value = old");
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _Ipfs1;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        //emit REPORT("I1 mod", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function modifyIpfs2(
        //bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs2
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require((isLostOrStolen(rec.assetStatus) == 0), "S:MI2:L/S asset"); //asset cannot be in lost or stolen status
        require((isTransferred(rec.assetStatus) == 0), "S:MI2: Txfrd. asset"); //asset cannot be in transferred status

        require((rec.Ipfs2 == 0), "S:MI2: ! overwrite I2"); //IPFS2 record is immutable after first write
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _Ipfs2;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("I2 mod", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//
    /*
     * @dev return a record from the database, including rgt
     */
    function retrieveRecord(bytes32 _idxHash)
        external
        view
        isAuthorized(0) //calling contract must be authorized, generically
        returns (
            bytes32,
            uint8,
            uint32,
            uint32,
            uint32,
            bytes32,
            bytes32
        )
    {
        Record memory rec = database[_idxHash];

        //  if (
        //      (rec.assetStatus == 3) ||
        //      (rec.assetStatus == 4) ||
        //      (rec.assetStatus == 53) ||
        //      (rec.assetStatus == 54)
        //  ) {
        //      emit REPORT("Lost or stolen record queried", _idxHash);
        //  }

        return (
            rec.rightsHolder,
            rec.assetStatus,
            rec.assetClass,
            rec.countDown,
            rec.countDownStart,
            rec.Ipfs1,
            rec.Ipfs2
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev return a record from the database w/o rgt
     */
    function retrieveShortRecord(bytes32 _idxHash)
        external
        view
        returns (
            uint8,
            uint8,
            uint32,
            uint32,
            uint32,
            bytes32,
            bytes32,
            uint16
        )
    {
        Record memory rec = database[_idxHash];

        //  if (
        //      (rec.assetStatus == 3) ||
        //      (rec.assetStatus == 4) ||
        //      (rec.assetStatus == 53) ||
        //      (rec.assetStatus == 54)
        //  ) {
        //      emit REPORT("Lost or stolen record queried", _idxHash);
        //  }

        return (
            rec.assetStatus,
            rec.forceModCount,
            rec.assetClass,
            rec.countDown,
            rec.countDownStart,
            rec.Ipfs1,
            rec.Ipfs2,
            rec.numberOfTransfers
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     * return 170 if matches, 0 if not
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
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder (writes an emit in blockchain for independant verification)
     */
    function blockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint8)
    {
        if (_rgtHash == database[_idxHash].rightsHolder) {
            emit REPORT("Match confirmed", _idxHash);
            return 170;
        } else {
            emit REPORT("Does not match", _idxHash);
            return 0;
        }
        //^^^^^^^checks/interactions^^^^^^^^^
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
        return contractNameToAddress[_name];
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev //returns the contract type of a contract with address _addr.
     */
    function ContractInfoHash(address _addr, uint32 _assetClass)
        external
        view
        returns (uint8, bytes32)
    {
        return (
            contractInfo[contractAddressToName[_addr]][_assetClass],
            keccak256(abi.encodePacked(contractAddressToName[_addr]))
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //-----------------------------------------------Private functions------------------------------------------------//
}
