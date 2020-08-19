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
        bytes32 rightsHolder; // KEK256 Registered owner
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint256 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        uint16 numberOfTransfers; //number of transfers and forcemods
    }

    mapping(string => mapping(uint256 => uint8)) internal contractInfo;
    mapping(address => string) private contractAddressToName; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNameToAddress; // Authorized contract addresses, indexed by name

    mapping(bytes32 => Record) private database; // Main Data Storage

    address private AC_TKN_Address;
    AC_TKN_Interface private AC_TKN; //erc721_token prototype initialization

    address internal AC_MGR_Address;
    AC_MGR_Interface internal AC_MGR; // Set up external contract interface

    //----------------------------------------------Modifiers----------------------------------------------//

    /*
     * @dev Verify user credentials
     *
     * Originating Address is authorized for asset class
     */
    modifier isAuthorized(uint256 _assetClass) {
        uint8 auth = contractInfo[contractAddressToName[msg
            .sender]][_assetClass];
        require(
            ((auth > 0) && (auth < 5)) || (auth == 10),
            "S:MOD-IA:Cntrct not prmsnd"
        );
        _;
    }

    /*
     * @dev Check record _idxHash exists and is not locked
     */
    modifier notEscrow(bytes32 _idxHash) {
        require(
            isEscrow(database[_idxHash].assetStatus) == 0,
            "S:MOD-NE:rec mod prohib while locked in ecr"
        );
        _;
    }

    /*
     * @dev Check record exists in database
     */
    modifier exists(bytes32 _idxHash) {
        require(
            database[_idxHash].assetClass != 0,
            "S:MOD-E:rec does not exist"
        );
        _;
    }

    /*
     * @dev Check to see if contract adress is registered to PRUF_escrowMGR
     */
    modifier isEscrowManager() {
        require(
            msg.sender == contractNameToAddress["ECR_MGR"],
            "S:MOD-IEM:Caller not ECR_MGR"
        );
        _;
    }

    /*
     * @dev Check to see if record is in lost or stolen status
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
     * @dev Check to see if record is in escrow status
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
     * @dev Triggers stopped state.
     */
    function pause() external onlyOwner {
        _pause();
    }

    /*
     * @dev Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*
     * @dev Authorize / Deauthorize / Authorize ADRESSES permitted to make record modifications, per AssetClass
     */
    function OO_addContract(
        string calldata _name,
        address _addr,
        uint256 _assetClass,
        uint8 _contractAuthLevel
    ) external onlyOwner {
        require((_assetClass == 0), "S:AC: AC not 0");
        require(_contractAuthLevel <= 4, "S:AC: Invalid user type");
        //^^^^^^^checks^^^^^^^^^

        contractInfo[_name][_assetClass] = _contractAuthLevel;
        contractNameToAddress[_name] = _addr;
        contractAddressToName[_addr] = _name;

        AC_TKN = AC_TKN_Interface(contractNameToAddress["AC_TKN"]);
        AC_MGR = AC_MGR_Interface(contractNameToAddress["AC_MGR"]);
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Authorize / Deauthorize / Authorize contract Names permitted to make record modifications, per AssetClass
     */
    function enableContractForAC(
        string calldata _name,
        uint256 _assetClass,
        uint8 _contractAuthLevel
    ) external {
        require(
            AC_TKN.ownerOf(_assetClass) == msg.sender,
            "S:ECFAC:Caller not ACtokenHolder"
        );

        //^^^^^^^checks^^^^^^^^^

        contractInfo[_name][_assetClass] = _contractAuthLevel;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External "write" contract functions / authuser---------------------------------//

    /*
     * @dev Make a new record in the database  *read fullHash, write rightsHolder, recorders, assetClass,countDownStart --new_record
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint256 _assetClass,
        uint256 _countDownStart
    ) external nonReentrant whenNotPaused isAuthorized(_assetClass) {
        require(
            database[_idxHash].assetStatus != 60,
            "S:NR:Asset is rcycl. Use PRUF_APP_NC rcycl instead"
        );
        //vvvRedundant??vvv
        require(
            database[_idxHash].rightsHolder == 0,
            "S:NR:Rec already exists"
        );
        require(_rgtHash != 0, "S:NR:RGT != 0");
        require(_assetClass != 0, "S:NR:AC != 0");
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

        emit REPORT("NEW REC", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify a record in the database  *read fullHash, write rightsHolder, update recorder, assetClass,countDown update recorder....
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint256 _countDown,
        uint8 _forceModCount,
        uint16 _numberOfTransfers
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash)
        isAuthorized(database[_idxHash].assetClass)
        notEscrow(_idxHash)
    {
        Record memory rec = database[_idxHash];
        bytes32 idxHash = _idxHash; //stack saving

        require(_countDown <= rec.countDown, "S:MR:countDown +!"); //prohibit increasing the countdown value
        require(
            (_forceModCount == rec.forceModCount) || ((_forceModCount == rec.forceModCount ++ ) && (_forceModCount != 0)),
            "S:MR:forceModCount err"
        );
        require(
            (_numberOfTransfers == rec.numberOfTransfers) || ((_numberOfTransfers == rec.numberOfTransfers ++ ) && (_numberOfTransfers != 0)),
            "S:MR:transferCount err"
        );
        require(
            isLostOrStolen(_newAssetStatus) == 0,
            "S:MR:Must use L/S to set L/S status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        rec.countDown = _countDown;
        rec.assetStatus = _newAssetStatus;
        rec.forceModCount = _forceModCount;
        rec.numberOfTransfers = _numberOfTransfers;

        database[idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("REC MOD", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Change asset class of an asset
     */
    function changeAC(bytes32 _idxHash, uint256 _newAssetClass)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash)
        notEscrow(_idxHash)
        isAuthorized(0) //is an authorized contract, generically
    {
        Record memory rec = database[_idxHash];

        require(
            _newAssetClass != 0,
            "S:CAC:Cannot set AC-0"
        );
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "S:CAC:Cannot mod AC to new root"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetClass = _newAssetClass;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("UPD AC", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset tot stolen or lost. Allows narrow modification of status 6/12 assets, normally locked
     */
    function setStolenOrLost(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash)
        isAuthorized(database[_idxHash].assetClass)
    {
        require(
            isLostOrStolen(_newAssetStatus) == 170,
            "S:SSL:Must set to L/S"
        );
        require(
            (database[_idxHash].assetStatus != 5) &&
                (database[_idxHash].assetStatus != 50) &&
                (database[_idxHash].assetStatus != 55),
            "S:SSL:Txfr or ecr locked asset != L/S."
        );
        //^^^^^^^checks^^^^^^^^^

        Record memory rec = database[_idxHash];
        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        if ((_newAssetStatus == 3) || (_newAssetStatus == 53)) {
            emit REPORT("STOLEN", _idxHash);
        } else {
            emit REPORT("LOST", _idxHash);
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     */
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _contractNameHash
    )
        external
        nonReentrant
        whenNotPaused
        isEscrowManager
        exists(_idxHash)
        notEscrow(_idxHash)
    {
        require(isEscrow(_newAssetStatus) == 170, "S:SE: Asset in ecr"); //Redundant, triggered in ECR_MGR
        require( //Redundant, triggered in ECR_MGR
            (isLostOrStolen(database[_idxHash].assetStatus) == 0) &&
                (database[_idxHash].assetStatus != 5) &&
                (database[_idxHash].assetStatus != 55),
            "S:SE: != ecr"
        );
        require( //Redundant, triggered in ECR_MGR
            isEscrow(database[_idxHash].assetStatus) == 0,
            "S:SE: In ecr stat"
        );
        //^^^^^^^checks^^^^^^^^^

        Record memory rec = database[_idxHash];

        if (_newAssetStatus == 60) {
            rec
                .rightsHolder = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        }

        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("ECR SET", _contractNameHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status
     */
    function endEscrow(bytes32 _idxHash, bytes32 _contractNameHash)
        external
        nonReentrant
        whenNotPaused
        isEscrowManager
        exists(_idxHash)
    {
        require(
            isEscrow(database[_idxHash].assetStatus) == 170,
            "S:EE:!= ecr stat"
        );
        //^^^^^^^checks^^^^^^^^^
        Record memory rec = database[_idxHash];

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
        emit REPORT("ECR END:", _contractNameHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify record Ipfs1 data
     */
    function modifyIpfs1(bytes32 _idxHash, bytes32 _Ipfs1)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash)
        isAuthorized(database[_idxHash].assetClass)
        notEscrow(_idxHash)
    {
        Record memory rec = database[_idxHash];

        require((rec.Ipfs1 != _Ipfs1), "S:MI1: New value = old");
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _Ipfs1;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("I1 mod", _idxHash);
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
        exists(_idxHash)
        isAuthorized(database[_idxHash].assetClass)
        notEscrow(_idxHash)
    {
        Record memory rec = database[_idxHash];

        require((rec.Ipfs2 == 0), "S:MI2: ! overwrite I2");
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _Ipfs2;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("I2 mod", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//
    /*
     * @dev return a complete record from the database
     */
    function retrieveRecord(bytes32 _idxHash)
        external
        view
        isAuthorized(0)
        returns (
            //bytes32,
            //bytes32,
            bytes32,
            uint8,
            uint8,
            uint256,
            uint256,
            uint256,
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
        //      emit REPORT_B32("Lost or stolen record queried", _idxHash);
        //  }

        return (
            rec.rightsHolder,
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

    function retrieveShortRecord(bytes32 _idxHash)
        external
        view
        returns (
            uint8,
            uint8,
            uint256,
            uint256,
            uint256,
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
        //      emit REPORT_B32("Lost or stolen record queried", _idxHash);
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
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder (writes in blockchain)
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
    function ContractInfoHash(address _addr, uint256 _assetClass)
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
