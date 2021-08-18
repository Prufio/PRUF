/**--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 *  TO DO
 * //CTS:EXAMINE Run through interfaces, make sure is up to date.
 *---------------------------------------------------------------*/

/**-----------------------------------------------------------------
 *  PRUF STOR  is the primary data repository for the PRUF protocol. No direct user writes are permitted in STOR, all data must come from explicitly approved contracts.
 *  PRUF STOR  stores records in a map of Records, foreward and reverse name resolution for approved contracts, as well as contract authorization data.
 *---------------------------------------------------------------*/

/**-----------------------------------------------------------------
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, certain management types are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
 *-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

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

    mapping(string => mapping(uint32 => uint8)) internal contractInfo; // name=>node=>authorization level
    mapping(address => string) private contractAddressToName; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNameToAddress; // Authorized contract addresses, indexed by name
    mapping(uint256 => DefaultContract) private defaultContracts; //default contracts for node creation
    mapping(bytes32 => Record) private database; // Main Data Storage

    //address private NODE_TKN_Address;
    NODE_TKN_Interface private NODE_TKN; //erc721_token prototype initialization

    //address internal NODE_MGR_Address;
    NODE_MGR_Interface internal NODE_MGR; // Set up external contract interface for NODE_MGR

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //----------------------------------------------Modifiers----------------------------------------------//

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "S:MOD-ICA: Must have CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has PAUSER_ROLE
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "S:MOD-IP: Must have PAUSER_ROLE"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Requires: Originating Address is authorized for node
     * @param _node node to check address auth
     */
    modifier isAuthorized(uint32 _node) {
        uint8 auth = contractInfo[contractAddressToName[msg.sender]][_node];
        require(
            ((auth > 0) && (auth < 5)) || (auth == 10),
            "S:MOD-IAUT: Contract not authorized"
        );
        _;
    }

    /**
     * @dev Check record is not in escrow
     * @param _idxHash idx hash to check escrow status
     */
    modifier notEscrow(bytes32 _idxHash) {
        require(
            isEscrow(database[_idxHash].assetStatus) == 0,
            "S:MOD-NE: Rec locked in ecr"
        );
        _;
    }

    /**
     * @dev Check record exists in database
     * @param _idxHash idx hash to check for existance in storage data
     */
    modifier exists(bytes32 _idxHash) {
        require(database[_idxHash].node != 0, "S:MOD-E: Rec !exist");
        _;
    }

    /**
     * @dev Check to see if caller (contract) address resolves to ECR_MGR
     */
    modifier isEscrowManager() {
        require(
            _msgSender() == contractNameToAddress["ECR_MGR"],
            "S:MOD-IEM: Caller !ECR_MGR"
        );
        _;
    }

    /**
     * @dev Check to see if a status matches lost or stolen status
     * @param _assetStatus status to check against list
     * returns 0 if supplied status is not a lost or stolen stat, 170 if it is
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

    /**
     * @dev Check to see if a status matches transferred status
     * @param _assetStatus status to check against list
     * returns 0 if supplied status is not a transferred stat, 170 if it is
     */
    function isTransferred(uint8 _assetStatus) private pure returns (uint8) {
        if ((_assetStatus != 5) && (_assetStatus != 55)) {
            return 0;
        } else {
            return 170;
        }
    }

    /**
     * @dev Check to see if a status matches transferred status
     * @param _assetStatus status to check against list
     * returns 0 if supplied status is not an escrow stat, 170 if it is
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
    // Emits a report using string,b32
    event REPORT(string _msg, bytes32 b32);

    //--------------------------------Internal Admin functions / isContractAdmin---------------------------------//

    /**
     * @dev Triggers stopped state. (pausable)
     */
    function pause() external isPauser {
        _pause();
    }

    /**
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external isPauser {
        _unpause();
    }

    /**
     * @dev Authorize / Deauthorize ADRESSES permitted to make record modifications, per node
     * populates contract name resolution and data mappings
     * @param _contractName - String name of contract
     * @param _contractAddr - address of contract
     * @param _node - node to authorize in
     * @param _contractAuthLevel - auth level to assign
     */
    function OO_addContract(
        string calldata _contractName,
        address _contractAddr,
        uint32 _node,
        uint8 _contractAuthLevel
    ) external isContractAdmin {
        require(_node == 0, "S:node: node !=0");
        //^^^^^^^checks^^^^^^^^^

        contractInfo[_contractName][_node] = _contractAuthLevel; //does not pose a partial record overwrite risk
        contractNameToAddress[_contractName] = _contractAddr;
        contractAddressToName[_contractAddr] = _contractName;

        NODE_TKN = NODE_TKN_Interface(contractNameToAddress["NODE_TKN"]); // cheaper than keking to check
        NODE_MGR = NODE_MGR_Interface(contractNameToAddress["NODE_MGR"]); // cheaper than keking to check
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev set the default list of 11 contracts (zero index) to be applied to Nodees
     * APP_NC, APP2_NC, NODE_MGR, NODE_TKN, A_TKN, ECR_MGR, RCLR, PIP, PURCHASE, DECORATE, WRAP
     * @param _contractNumber - 0-10
     * @param _name - name
     * @param _contractAuthLevel - authLevel
     */
    function addDefaultContracts(
        uint256 _contractNumber,
        string calldata _name,
        uint8 _contractAuthLevel
    ) external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^
        require(_contractNumber <= 10, "S:ADC: Contract number > 10");
        defaultContracts[_contractNumber].name = _name;
        defaultContracts[_contractNumber].contractType = _contractAuthLevel;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev retrieve a record from the default list of 11 contracts to be applied to Nodees
     * @param _contractNumber to look up (0-10)
     * returns the name and auth level
     */
    function getDefaultContract(uint256 _contractNumber)
        external
        view
        isContractAdmin
        returns (DefaultContract memory)
    {
        //^^^^^^^checks^^^^^^^^^
        return (defaultContracts[_contractNumber]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set the default 11 authorized contracts
     * @param _node the Node which will be enabled for the default contracts
     */
    function enableDefaultContractsForAC(uint32 _node) external {
        require(
            (NODE_TKN.ownerOf(_node) == _msgSender()) ||
                (_msgSender() == contractNameToAddress["NODE_MGR"]),
            "S:EDCFAC: Caller not ACtokenHolder or NODE_MGR"
        );
        //^^^^^^^checks^^^^^^^^^
        enableContractForAC(
            defaultContracts[0].name,
            _node,
            defaultContracts[0].contractType
        );
        enableContractForAC(
            defaultContracts[1].name,
            _node,
            defaultContracts[1].contractType
        );
        enableContractForAC(
            defaultContracts[2].name,
            _node,
            defaultContracts[2].contractType
        );
        enableContractForAC(
            defaultContracts[3].name,
            _node,
            defaultContracts[3].contractType
        );
        enableContractForAC(
            defaultContracts[4].name,
            _node,
            defaultContracts[4].contractType
        );
        enableContractForAC(
            defaultContracts[5].name,
            _node,
            defaultContracts[5].contractType
        );
        enableContractForAC(
            defaultContracts[6].name,
            _node,
            defaultContracts[6].contractType
        );
        enableContractForAC(
            defaultContracts[7].name,
            _node,
            defaultContracts[7].contractType
        );
        enableContractForAC(
            defaultContracts[8].name,
            _node,
            defaultContracts[8].contractType
        );
        enableContractForAC(
            defaultContracts[9].name,
            _node,
            defaultContracts[9].contractType
        );
        enableContractForAC(
            defaultContracts[10].name,
            _node,
            defaultContracts[10].contractType
        );
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Authorize / Deauthorize contract NAMES permitted to make record modifications, per node
     * allows ACtokenHolder to Authorize / Deauthorize specific contracts to work within their node
     * @param   _name -  Name of contract being authed
     * @param   _node - affected node
     * @param   _contractAuthLevel - auth level to set for thae contract, in that node
     */
    function enableContractForAC(
        string memory _name,
        uint32 _node,
        uint8 _contractAuthLevel
    ) public {
        require(
            (NODE_TKN.ownerOf(_node) == _msgSender()) ||
                (_msgSender() == contractNameToAddress["NODE_MGR"]),
            "S:ECFAC: Caller not ACtokenHolder or NODE_MGR"
        );

        //^^^^^^^checks^^^^^^^^^

        contractInfo[_name][_node] = _contractAuthLevel; //does not pose an partial record overwrite risk
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACDA", bytes32(uint256(_contractAuthLevel))); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External "write" contract functions / authuser---------------------------------//

    /**
     * @dev Make a new record, writing to the 'database' mapping with basic initial asset data
     * @param   _idxHash - asset ID
     * @param   _rgtHash - rightsholder id hash
     * @param   _node - node in which to create the asset
     * @param   _countDownStart - initial value for decrement-only value
     * calling contract must be authorized in relevant node
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) external nonReentrant whenNotPaused isAuthorized(_node) {
        require(
            database[_idxHash].assetStatus != 60,
            "S:NR: Asset discarded use APP_NC rcycl"
        );
        require(database[_idxHash].node == 0, "S:NR: Rec already exists");
        require(_rgtHash != 0, "S:NR: RGT = 0");
        require(_node != 0, "S:NR: node = 0");
        //^^^^^^^checks^^^^^^^^^

        Record memory rec;

        if (
            contractInfo[contractAddressToName[_msgSender()]][_node] == 1 //EXAMINE, what do management types do to how we handle "custodial" status' ?? change this??? (big)
        ) {
            rec.assetStatus = 0;
        } else {
            rec.assetStatus = 51;
        }

        rec.node = _node;
        rec.countDown = _countDownStart;
        rec.rightsHolder = _rgtHash;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify a record, writing to the 'database' mapping with updates to multiple fields
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * @param _newAssetStatus - New Status to set
     * @param _countDown - New countdown value (must be <= old value)
     * @param _int32temp - temp value
     * @param _incrementModCount - 0 = no 170 = yes
     * @param _incrementNumberOfTransfers - 0 = no 170 = yes
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint32 _countDown,
        uint32 _int32temp,
        uint256 _incrementModCount,
        uint256 _incrementNumberOfTransfers
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].node) //calling contract must be authorized in relevant node
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

        require(_rgtHash != 0, "S:MR: rgtHash = 0");
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        rec.countDown = _countDown;
        rec.int32temp = _int32temp;
        rec.assetStatus = _newAssetStatus;

        if ((_incrementModCount == 170) && (rec.modCount < 255)) {
            rec.modCount = rec.modCount + 1;
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

    /**
     * @dev Change node of an asset - writes to node in the 'Record' struct of the 'database' at _idxHash
     * @param _idxHash - record asset ID
     * @param _newNode - Aseet Class to change to
     */
    function changeNode(bytes32 _idxHash, uint32 _newNode)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        notEscrow(_idxHash) // asset must not be held in escrow status
        isAuthorized(0) //is an authorized contract, Node nonspecific
    {
        Record memory rec = database[_idxHash];

        require(_newNode != 0, "S:CAC: Cannot set node=0");
        require( //require new node is in the same root as old node
            NODE_MGR.isSameRootNode(_newNode, rec.node) == 170,
            "S:CAC: Cannot mod node to new root"
        );
        require(isLostOrStolen(rec.assetStatus) == 0, "S:CAC: L/S asset"); //asset cannot be in lost or stolen status
        require(isTransferred(rec.assetStatus) == 0, "S:CAC: Txfrd asset"); //asset cannot be in transferred status
        //^^^^^^^checks^^^^^^^^^

        rec.node = _newNode;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("UPD node", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set an asset to Lost Or Stolen. Allows narrow modification of status 6/12 assets, normally locked
     * @param _idxHash - record asset ID
     * @param _newAssetStatus - Status to change to
     */
    function setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash)
        isAuthorized(database[_idxHash].node)
    {
        Record memory rec = database[_idxHash];

        require(
            isLostOrStolen(_newAssetStatus) == 170, //proposed new status must be L/S status
            "S:SSL: Must set to L/S"
        );
        require( //asset cannot be set L/S if in transferred or locked escrow status
            (rec.assetStatus != 5) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 55),
            "S:SSL: Txfr or ecr-locked asset"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Set an asset to escrow locked status (6/50/56).
     * @param _idxHash - record asset ID
     * @param _newAssetStatus - New Status to set
     */
    function setEscrow(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isEscrowManager // calling contract must be ECR_MGR
        exists(_idxHash) //asset must exist in 'database'
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require(isEscrow(_newAssetStatus) == 170, "S:SE: Stat !ECR"); //proposed new status must be an escrow status
        require(isLostOrStolen(rec.assetStatus) == 0, "S:SE: L/S asset"); //asset cannot be in lost or stolen status
        require(isTransferred(rec.assetStatus) == 0, "S:SE: Txfrd asset"); //asset cannot be in transferred status
        //^^^^^^^checks^^^^^^^^^

        if (_newAssetStatus == 60) {
            //if setting to "escrow" status, set rgt to 0xFFF_
            rec.rightsHolder = B320xF_;
        }

        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev remove an asset from escrow status. Implicitly trusts escrowManager ECR_MGR contract
     * @param _idxHash - record asset ID
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        isEscrowManager //calling contract must be ECR_MGR
        exists(_idxHash) //asset must exist in 'database' REDUNDANT THROWS IN ECR_MGR WITH "Asset not in escrow status"
    {
        Record memory rec = database[_idxHash];
        require(isEscrow(rec.assetStatus) == 170, "S:EE: STAT !ECR"); //asset must be in an escrow status
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
    }

    /**
     * @dev Modify record sale price and currency data
     * @param  _idxHash - record asset ID
     * @param  _price set selling price in:
     * @param  _currency (see docs)
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
        isAuthorized(database[_idxHash].node) //calling contract must be authorized in relevant node
    {
        Record memory rec = database[_idxHash];
        require(isTransferred(rec.assetStatus) == 0, "S:SP: Txfrd asset");
        //^^^^^^^checks^^^^^^^^^

        rec.price = _price;
        rec.currency = _currency;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev set record sale price and currency data to zero
     * @param _idxHash - record asset ID
     */
    function clearPrice(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].node) //calling contract must be authorized in relevant node
    {
        Record memory rec = database[_idxHash];
        require(isTransferred(rec.assetStatus) == 0, "S:CP: Txfrd asset");
        //^^^^^^^checks^^^^^^^^^

        rec.price = 0;
        rec.currency = 0;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("Price mod", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify record MutableStorage data
     * @param  _idxHash - record asset ID
     * @param  _mutableStorage1 - first half of content adressable storage location
     * @param  _mutableStorage2 - second half of content adressable storage location
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].node) //calling contract must be authorized in relevant node
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require(isTransferred(rec.assetStatus) == 0, "S:MI1: Txfrd asset"); //STAT UNREACHABLE

        require(
            (rec.mutableStorage1 != _mutableStorage1) ||
                (rec.mutableStorage2 != _mutableStorage2),
            "S:MI1: New value = old"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.mutableStorage1 = _mutableStorage1;
        rec.mutableStorage2 = _mutableStorage2;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        //emit REPORT("I1 mod", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify NonMutableStorage data
     * @param _idxHash - record asset ID
     * @param _nonMutableStorage1 - first half of content adressable storage location
     * @param _nonMutableStorage2 - second half of content adressable storage location
     */
    function modifyNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    )
        external
        nonReentrant
        whenNotPaused
        exists(_idxHash) //asset must exist in 'database'
        isAuthorized(database[_idxHash].node) //calling contract must be authorized in relevant node
        notEscrow(_idxHash) // asset must not be held in escrow status
    {
        Record memory rec = database[_idxHash];
        require(isLostOrStolen(rec.assetStatus) == 0, "S:MNMS: L/S asset"); //asset cannot be in lost or stolen status
        require(isTransferred(rec.assetStatus) == 0, "S:MNMS: Txfrd. asset"); //asset cannot be in transferred status

        require(
            ((rec.nonMutableStorage1 == 0) && (rec.nonMutableStorage2 == 0)) ||
                (rec.assetStatus == 201),
            "S:MNMS: Cannot overwrite NM Storage"
        ); //NonMutableStorage record is immutable after first write unless status 201 is set (Storage provider has died)
        //^^^^^^^checks^^^^^^^^^

        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        //emit REPORT("I2 mod", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//
    /**
     * @dev return a record from the database
     * @param  _idxHash - record asset ID
     * returns a complete Record struct (see interfaces for struct definitions)
     */
    function retrieveRecord(bytes32 _idxHash)
        external
        view
        isAuthorized(0)
        returns (Record memory)
    {
        return database[_idxHash];
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev return a record from the database w/o rgt
     * @param _idxHash - record asset ID
     * returns rec.assetStatus,
                rec.modCount,
                rec.node,
                rec.countDown,
                rec.countDownStart,
                rec.mutableStorage1,
                rec.mutableStorage2,
                rec.nonMutableStorage1,
                rec.nonMutableStorage2,
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

        return (
            rec.assetStatus,
            rec.modCount,
            rec.node,
            rec.countDown,
            rec.int32temp,
            rec.mutableStorage1,
            rec.mutableStorage2,
            rec.nonMutableStorage1,
            rec.nonMutableStorage2,
            rec.numberOfTransfers
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev return the pricing and currency data from a record
     * @param _idxHash - record asset ID
     * returns rec.price,
                rec.currency
     */
    function getPriceData(bytes32 _idxHash)
        external
        view
        returns (uint120, uint8)
    {
        return (database[_idxHash].price, database[_idxHash].currency);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * returns 170 if matches, 0 if not
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

    /**
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder (writes an emit in blockchain for independant verification)
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * returns 170 if matches, 0 if not
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

    /**
     * @dev //returns the address of a contract with name _name. This is for web3 implementations to find the right contract to interact with
     * example :  Frontend = ****** so web 3 first asks storage where to find frontend, then calls for frontend functions.
     * @param _name - contract name
     * returns address contract address
     */
    function resolveContractAddress(string calldata _name)
        external
        view
        returns (address)
    {
        return contractNameToAddress[_name];
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev //returns the contract type of a contract with address _addr.
     * @param _addr - contract address
     * @param _node - node to look up contract type-in-class
     * returns address contract address
     */
    function ContractInfoHash(address _addr, uint32 _node)
        external
        view
        returns (uint8, bytes32)
    {
        return (
            contractInfo[contractAddressToName[_addr]][_node],
            keccak256(abi.encodePacked(contractAddressToName[_addr]))
        );
        //^^^^^^^interactions^^^^^^^^^
    }
}
