/*--------------------------------------------------------PRüF0.8.0
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
 * //CTS:EXAMINE all params/returns defined in comments global
 * //CTS:EXAMINE AssetClass, asset class, assetClass->Node global
 * //CTS:EXAMINE ACTH->NTH global
 * //CTS:EXAMINE AssetClassRoot, asset class root, root->RootNode global
 * //CTS:EXAMINE IPFS1/IPFS2->storProvider/storProvider2 global
 * //CTS:EXAMINE idxHash->assetId global

 *---------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  PRUF STOR  is the primary data repository for the PRUF protocol. No direct user writes are permitted in STOR, all data must come from explicitly approved contracts. 
 *  PRUF STOR  stores records in a map of Records, foreward and reverse name resolution for approved contracts, as well as contract authorization data.
 *---------------------------------------------------------------*/

/*-----------------------------------------------------------------
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, certain management types are not secure beyond the honorable intentions 
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
 *-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract STOR is AccessControl, ReentrancyGuard, Pausable {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");

    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    mapping(string => mapping(uint32 => uint8)) internal contractInfo; // name=>AC=>authorization level
    mapping(address => string) private contractAddressToName; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNameToAddress; // Authorized contract addresses, indexed by name
    mapping(uint256 => DefaultContract) private defaultContracts; //default contracts for AC creation
    mapping(bytes32 => Record) private database; // Main Data Storage

    //address private AC_TKN_Address;
    AC_TKN_Interface private AC_TKN; //erc721_token prototype initialization

    //address internal AC_MGR_Address;
    AC_MGR_Interface internal AC_MGR; // Set up external contract interface for AC_MGR

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //----------------------------------------------Modifiers----------------------------------------------//

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is admin //CTS:EXAMINE "is Contract Admin"?
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "S:MOD-IADM: Must have CONTRACT_ADMIN_ROLE" //CTS:EXAMINE "S:MOD-ICA"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Pauser
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "S:MOD-IP: Must have PAUSER_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * //CTS:EXAMINE param
     * Originating Address is authorized for asset class
     */
    modifier isAuthorized(uint32 _assetClass) {
        uint8 auth =
            contractInfo[contractAddressToName[msg.sender]][_assetClass];
        require(
            ((auth > 0) && (auth < 5)) || (auth == 10),
            "S:MOD-IAUT: Contract not authorized"
        );
        _;
    }

    /*
     * @dev Check record is not in escrow
     * //CTS:EXAMINE param
     * //CTS:EXAMINE should isEscrow just take an idx?
     */
    modifier notEscrow(bytes32 _idxHash) {
        require(
            isEscrow(database[_idxHash].assetStatus) == 0,
            "S:MOD-NE: Rec locked in ecr"
        );
        _;
    }

    /*
     * @dev Check record exists in database
     * //CTS:EXAMINE param
     */
    modifier exists(bytes32 _idxHash) {
        require(database[_idxHash].assetClass != 0, "S:MOD-E: Rec !exist");
        _;
    }

    /*
     * @dev Check to see if contract address resolves to ECR_MGR //CTS:EXAMINE "...if caller address..."
     */
    modifier isEscrowManager() {
        require(
            _msgSender() == contractNameToAddress["ECR_MGR"],
            "S:MOD-IEM: Caller not ECR_MGR" //CTS:EXAMINE "Caller !ECR_MGR"
        );
        _;
    }

    /*
     * @dev Check to see a status matches lost or stolen status //CTS:EXAMINE "...to see if a status matches..."
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
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
     * @dev Check to see a status matches transferred status //CTS:EXAMINE "...to see if a status matches..."
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
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
    //CTS:EXAMINE comment
    event REPORT(string _msg, bytes32 b32);

    //--------------------------------Internal Admin functions / isContractAdmin---------------------------------//

    /*
     * @dev Triggers stopped state. (pausable)
     */
    function pause() external isPauser {
        _pause();
    }

    /*
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external isPauser {
        _unpause();
    }

    /*
     * @dev Authorize / Deauthorize / Authorize ADRESSES permitted to make record modifications, per AssetClass //CTS:EXAMINE "Authorize" twice in intro
     * populates contract name resolution and data mappings
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function OO_addContract(
        string calldata _name,
        address _addr,
        uint32 _assetClass,
        uint8 _contractAuthLevel
    ) external isContractAdmin {
        require(_assetClass == 0, "S:AC: AC !0"); //CTS:EXAMINE "AC = 0"
        //^^^^^^^checks^^^^^^^^^

        contractInfo[_name][_assetClass] = _contractAuthLevel; //does not pose an partial record overwrite risk //CTS:EXAMINE are vvv these vvv neccesary
        contractNameToAddress[_name] = _addr; //does not pose an partial record overwrite risk
        contractAddressToName[_addr] = _name; //does not pose an partial record overwrite risk

        AC_TKN = AC_TKN_Interface(contractNameToAddress["AC_TKN"]); //CTS:EXAMINE does this need to happen every time? ex. if (_name = AC_TKN) {=>} ?
        AC_MGR = AC_MGR_Interface(contractNameToAddress["AC_MGR"]);
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database //CTS:EXAMINE is this neccesary
        //^^^^^^^interactions^^^^^^^^^
    }

    // struct DefaultContract { //CTS:EXAMINE
    // //Struct for holding and manipulating contract authorization data
    // uint8 contractType; // Auth Level / type
    // string name; // Contract name
    // }

    /*
     * @dev set the default list of 11 contracts (zero index) to be applied to asset classes
     * APP_NC, NP_NC, AC_MGR, AC_TKN, A_TKN, ECR_MGR, RCLR, PIP, PURCHASE, DECORATE, WRAP
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE:
        //^^^^^^^checks^^^^^^^^^
        //^^^^^^^effects^^^^^^^^^
        //^^^^^^^interactions^^^^^^^^^
     */
    function addDefaultContracts(
        uint256 _contractNumber, // 0-10 //CTS:EXAMINE I wouldnt describe params like this, clutters up the code. keep it in the head comment
        string calldata _name, //name
        uint8 _contractAuthLevel //authLevel
    ) public isContractAdmin {
        require(_contractNumber <= 10, "S:ADC: Contract number > 10");
        defaultContracts[_contractNumber].name = _name;
        defaultContracts[_contractNumber].contractType = _contractAuthLevel;
    }

    /*
     * @dev retrieve a record from the default list of 11 contracts to be applied to asset classes
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
     * //CTS:EXAMINE:
        //^^^^^^^checks^^^^^^^^^
        //^^^^^^^effects^^^^^^^^^
        //^^^^^^^interactions^^^^^^^^^
     */
    function getDefaultContract(uint256 _contractNumber)
        public
        view
        isContractAdmin
        returns (DefaultContract memory)
    {
        return (defaultContracts[_contractNumber]);
    }

    /*
     * @dev Set the default 11 authorized contracts
     * //CTS:EXAMINE param
     * //CTS:EXAMINE should remain public, reqs should check if caller is ACTH or AC_MGR for future contract upgrade purposes
     * //CTS:EXAMINE:
        //^^^^^^^checks^^^^^^^^^
        //^^^^^^^effects^^^^^^^^^
        //^^^^^^^interactions^^^^^^^^^
     */
    function enableDefaultContractsForAC(uint32 _assetClass) public {
        require(
            _msgSender() == contractNameToAddress["AC_MGR"],
            "S:EDCFAC: Caller not AC_MGR"
        );
        enableContractForAC(
            defaultContracts[0].name,
            _assetClass,
            defaultContracts[0].contractType
        );
        enableContractForAC(
            defaultContracts[1].name,
            _assetClass,
            defaultContracts[1].contractType
        );
        enableContractForAC(
            defaultContracts[2].name,
            _assetClass,
            defaultContracts[2].contractType
        );
        enableContractForAC(
            defaultContracts[3].name,
            _assetClass,
            defaultContracts[3].contractType
        );
        enableContractForAC(
            defaultContracts[4].name,
            _assetClass,
            defaultContracts[4].contractType
        );
        enableContractForAC(
            defaultContracts[5].name,
            _assetClass,
            defaultContracts[5].contractType
        );
        enableContractForAC(
            defaultContracts[6].name,
            _assetClass,
            defaultContracts[6].contractType
        );
        enableContractForAC(
            defaultContracts[7].name,
            _assetClass,
            defaultContracts[7].contractType
        );
        enableContractForAC(
            defaultContracts[8].name,
            _assetClass,
            defaultContracts[8].contractType
        );
        enableContractForAC(
            defaultContracts[9].name,
            _assetClass,
            defaultContracts[9].contractType
        );
        enableContractForAC(
            defaultContracts[10].name,
            _assetClass,
            defaultContracts[10].contractType
        );
    }

    /*
     * @dev Authorize / Deauthorize / Authorize contract NAMES permitted to make record modifications, per AssetClass //CTS:EXAMINE "Authorize" twice in intro, "deauthorize"->"unauthorize"
     * allows ACtokenHolder to auithorize or deauthorize specific contracts to work within their asset class //CTS:EXAMINE "auithorize"->"authorize", "deauthorize"->"unauthorize"
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function enableContractForAC(
        string memory _name,
        uint32 _assetClass,
        uint8 _contractAuthLevel
    ) public {
        require(
            (AC_TKN.ownerOf(_assetClass) == _msgSender()) ||
                (_msgSender() == contractNameToAddress["AC_MGR"]),
            "S:ECFAC: Caller not ACtokenHolder" //CTS:EXAMINE || AC_MGR
        );

        //^^^^^^^checks^^^^^^^^^

        contractInfo[_name][_assetClass] = _contractAuthLevel; //does not pose an partial record overwrite risk //CTS:EXAMINE comment neccesary?
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database //CTS:EXAMINE neccesary?
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External "write" contract functions / authuser---------------------------------//

    /*
     * @dev Make a new record, writing to the 'database' mapping with basic initial asset data
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
        isAuthorized(_assetClass) //calling contract must be authorized in relevant assetClass //CTS:EXAMINE are these kind of comments neccesary? They can(and should) track down the function if they want to know what it does
    {
        require(
            database[_idxHash].assetStatus != 60,
            "S:NR: Asset discarded use APP_NC rcycl"
        );
        require(database[_idxHash].assetClass == 0, "S:NR: Rec already exists");
        require(_rgtHash != 0, "S:NR: RGT = 0");
        require(_assetClass != 0, "S:NR: AC = 0");
        //^^^^^^^checks^^^^^^^^^

        Record memory rec;

        if (
            contractInfo[contractAddressToName[_msgSender()]][_assetClass] == 1 //CTS:EXAMINE, what do management types do to how we handle "custodial" status'
        ) {
            rec.assetStatus = 0;
        } else {
            rec.assetStatus = 51;
        }

        rec.assetClass = _assetClass;
        rec.countDownStart = _countDownStart; //CTS:EXAMINE put in order, put rgt here, move this one step down. just to prettify
        rec.countDown = _countDownStart;
        rec.rightsHolder = _rgtHash;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("NEW REC", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify a record, writing to the 'database' mapping with updates to multiple fields
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint32 _countDown,
        uint256 _incrementForceModCount, //CTS:EXAMINE do we want to call it force mod count? doesn't happen without custodial contracts (import, modRGT)
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

        require(_countDown <= rec.countDown, "S:MR: CountDown +!"); //prohibit increasing the countdown value
        require(
            (isLostOrStolen(_newAssetStatus) == 0) ||
                (_newAssetStatus == rec.assetStatus),
            "S:MR: Must use L/S"
        );
        require(
            (isEscrow(_newAssetStatus) == 0) ||
                (_newAssetStatus == rec.assetStatus),
            "S:MR: Must use ECR"
        );
        // require( //CTS:EXAMINE remove? done higher up? not sure
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

        //emit REPORT("REC MOD", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Change asset class of an asset - writes to assetClass in the 'Record' struct of the 'database' at _idxHash
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function changeAC(bytes32 _idxHash, uint32 _newAssetClass)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        notEscrow(_idxHash) // asset must not be held in escrow status
        isAuthorized(0) //is an authorized contract, Asset class nonspecific
    {
        Record memory rec = database[_idxHash];

        require(_newAssetClass != 0, "S:CAC: Cannot set AC-0"); //CTS:EXAMINE "AC = 0"
        require( //require new assetClass is in the same root as old assetClass
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "S:CAC: Cannot mod AC to new root"
        );
        require((isLostOrStolen(rec.assetStatus) == 0), "S:CAC: L/S asset"); //asset cannot be in lost or stolen status //CTS:EXAMINE remove extra ()
        require((isTransferred(rec.assetStatus) == 0), "S:CAC: Txfrd asset"); //asset cannot be in transferred status //CTS:EXAMINE remove extra ()
        //^^^^^^^checks^^^^^^^^^

        rec.assetClass = _newAssetClass;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("UPD AC", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset to stolen or lost. Allows narrow modification of status 6/12 assets, normally locked
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE we use "...StolenOrLost", but reference it as "L/S" or "...LostOrStolen" everywhere. a little awkward.
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
            "S:SSL: Must set to L/S" //CTS:EXAMINE "Already L/S"
        );
        require( //asset cannot be set l/s if in transferred or locked escrow status //CTS:EXAMINE cap "...l/s..."
            (rec.assetStatus != 5) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 55), //STATE UNREACHABLE TO SET TO STAT 55 IN CURRENT CONTRACTS
            "S:SSL: Txfr or ecr-locked asset != L/S." //CTS:EXAMINE remove "...!= L/S"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //CTS:EXAMINE remove? vvvv
        // if ((_newAssetStatus == 3) || (_newAssetStatus == 53)) {
        //     emit REPORT("STOLEN", _idxHash);
        // } else {
        //     emit REPORT("LOST", _idxHash);
        // }
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset to escrow locked status (6/50/56).
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function setEscrow(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isEscrowManager //CTS:EXAMINE add -> calling contract must be ECR_MGR
        exists(_idxHash) //asset must exist in 'database'
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require(isEscrow(_newAssetStatus) == 170, "S:SE: Stat must = ecr"); //proposed new status must be an escrow status //CTS:EXAMINE "Stat !ECR"
        require((isLostOrStolen(rec.assetStatus) == 0), "S:SE: L/S asset"); //asset cannot be in lost or stolen status //CTS:EXAMINE remove extra ()
        require((isTransferred(rec.assetStatus) == 0), "S:SE: Txfrd asset"); //asset cannot be in transferred status //CTS:EXAMINE remove extra ()
        //^^^^^^^checks^^^^^^^^^

        if (_newAssetStatus == 60) {
            //if setting to "escrow" status, set rgt to 0xFFF_
            rec.rightsHolder = B320xF_;
        }

        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        //emit REPORT("ECR SET", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status. Implicitly trusts escrowManager ECR_MGR contract
     * //CTS:EXAMINE param
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        isEscrowManager //calling contract must be ECR_MGR
        exists(_idxHash) //asset must exist in 'database' REDUNDANT THROWS IN ECR_MGR WITH "Asset not in escrow status"
    {
        Record memory rec = database[_idxHash];
        require(isEscrow(rec.assetStatus) == 170, "S:EE: !Ecr stat"); //asset must be in an escrow status //CTS:EXAMINE "Stat !ECR"
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
        //emit REPORT("ECR END:", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify record sale price and currency data
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function setPrice(
        bytes32 _idxHash,
        uint120 _price,
        uint8 _currency
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
    //notEscrow(_idxHash) // asset must not be held in escrow status //CTS:EXAMINE remove?
    {
        Record memory rec = database[_idxHash];
        require((isTransferred(rec.assetStatus) == 0), "S:SP: Txfrd asset"); //CTS:EXAMINE remove extra ()
        //require(isEscrow(rec.assetStatus) == 0, "S:SP: Escrowed asset"); //CTS:EXAMINE remove?
        //^^^^^^^checks^^^^^^^^^

        rec.price = _price;
        rec.currency = _currency;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("Price mod", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set record sale price and currency data to zero
     * //CTS:EXAMINE param
     */
    function clearPrice(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
    {
        Record memory rec = database[_idxHash];
        require((isTransferred(rec.assetStatus) == 0), "S:CP: Txfrd asset"); //CTS:EXAMINE remove extra ()
        //^^^^^^^checks^^^^^^^^^

        rec.price = 0;
        rec.currency = 0;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("Price mod", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify record Ipfs1 data
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function modifyIpfs1(
        bytes32 _idxHash,
        bytes32 _Ipfs1a,
        bytes32 _Ipfs1b
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require((isTransferred(rec.assetStatus) == 0), "S:MI1: Txfrd asset"); //STAT UNREACHABLE //CTS:EXAMINE remove extra ()

        require(
            (rec.Ipfs1a != _Ipfs1a) || (rec.Ipfs1b != _Ipfs1b),
            "S:MI1: New value = old"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1a = _Ipfs1a;
        rec.Ipfs1b = _Ipfs1b;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        //emit REPORT("I1 mod", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * //CTS:EXAMINE comment?
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function modifyIpfs2(
        //bytes32 _userHash, //CTS:EXAMINE remove?
        bytes32 _idxHash,
        bytes32 _Ipfs2a,
        bytes32 _Ipfs2b
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].assetClass) //calling contract must be authorized in relevant assetClass
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require((isLostOrStolen(rec.assetStatus) == 0), "S:MI2: L/S asset"); //asset cannot be in lost or stolen status //CTS:EXAMINE remove extra ()
        require((isTransferred(rec.assetStatus) == 0), "S:MI2: Txfrd. asset"); //asset cannot be in transferred status //CTS:EXAMINE remove extra ()

        require(
            ((rec.Ipfs2a == 0) && (rec.Ipfs2b == 0)) || rec.assetStatus == 201, //CTS:EXAMINE add () to both sides
            "S:MI2: Cannot overwrite I2"
        ); //IPFS2 record is immutable after first write unlwss status 201 is set (Storage provider has died) //CTS:EXAMINE "unlwss"->"unless"
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2a = _Ipfs2a;
        rec.Ipfs2b = _Ipfs2b;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("I2 mod", _idxHash); //CTS:EXAMINE remove?
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//
    /*
     * @dev return a record from the database
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
     */
    function retrieveRecord(bytes32 _idxHash)
        external
        view
        isAuthorized(0) //is an authorized contract, Asset class nonspecific
        returns (Record memory)
    {
        return database[_idxHash];
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev return a record from the database w/o rgt
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
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
            bytes32,
            bytes32,
            uint16
        )
    {
        Record memory rec = database[_idxHash];

        //  if ( CTS:EXAMINE remove? 
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
            rec.Ipfs1a,
            rec.Ipfs1b,
            rec.Ipfs2a,
            rec.Ipfs2b,
            rec.numberOfTransfers
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev return the pricing and currency data from a record
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
     */
    function getPriceData(bytes32 _idxHash)
        external
        view
        returns (uint120, uint8)
    {
        return (database[_idxHash].price, database[_idxHash].currency);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
     */
    function blockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint256)
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
     * //CTS:EXAMINE return
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
}
