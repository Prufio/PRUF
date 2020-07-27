/*-----------------------------------------------------------V0.6.7
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
        uint16 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        uint16 numberOfTransfers; //number of transfers and forcemods
    }

    struct Contracts {
        uint8 contractType; // Auth Level / type
        string name; // Contract Name
    }

    mapping(address => Contracts) private contractInfo; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNameToAddress; // Authorized contract addresses, indexed by name
    mapping(bytes32 => Record) private database; // Main Data Storage

    address private AssetClassTokenAddress;
    AC_TKN_Interface private AssetClassTokenContract; //erc721_token prototype initialization

    address internal AssetClassTokenManagerAddress;
    AC_MGR_Interface internal AssetClassTokenManagerContract; // Set up external contract interface

    //----------------------------------------------Modifiers----------------------------------------------//

    /*
     * @dev Verify user credentials
     *
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 or 9
     *      Is authorized for asset class
     */
    modifier isAuthorized() {
        require(
            (contractInfo[msg.sender].contractType == 1) ||
                (contractInfo[msg.sender].contractType == 2) ||
                (contractInfo[msg.sender].contractType == 3) ||
                (contractInfo[msg.sender].contractType == 4),
            "PS:IA:Contract not authorized or improperly permissioned"
        );
        _;
    }

    /*
     * @dev Check record _idxHash exists and is not locked
     */
    modifier notEscrow(bytes32 _idxHash) {
        require(
            ((database[_idxHash].assetStatus != 6) &&
                (database[_idxHash].assetStatus != 50) &&
                (database[_idxHash].assetStatus != 56)),
            "PS:NE:rec mod prohib while locked in escrow"
        );
        _;
    }

    /*
     * @dev Check record exists in database
     */
    modifier exists(bytes32 _idxHash) {
        require(
            database[_idxHash].rightsHolder != 0,
            "PS:E:rec does not exist"
        );
        _;
    }

    /*
     * @dev Check to see if contract adress is registered to PRUF_escrowMGR
     */
    modifier isEscrowManager() {
        require(
            msg.sender == contractNameToAddress["PRUF_escrowMGR"],
            "PS:IEM:Caller not escrowMgr"
        );
        _;
    }

    function isLostOrStolen(uint16 _assetStatus) private pure returns (uint8) {
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

    function isEscrow(uint16 _assetStatus) private pure returns (uint8) {
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

    /**
     * @dev Triggers stopped state.
     *
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     */
    function unpause() external onlyOwner {
        _unpause();
    }

    /*
     * @dev Authorize / Deauthorize / Authorize ADRESSES permitted to make record modifications
     */
    function OO_addContract(
        string calldata _name,
        address _addr,
        uint8 _contractAuthLevel
    ) external onlyOwner {
        require(_contractAuthLevel <= 4, "PS:AC: Invalid user type");
        //^^^^^^^checks^^^^^^^^^

        contractInfo[_addr].contractType = _contractAuthLevel;
        contractInfo[_addr].name = _name;
        contractNameToAddress[_name] = _addr;

        AssetClassTokenContract = AC_TKN_Interface(
            contractNameToAddress["assetClassToken"]
        );
        AssetClassTokenManagerContract = AC_MGR_Interface(
            contractNameToAddress["PRUF_AC_MGR"]
        );
        //^^^^^^^effects^^^^^^^^^

        emit REPORT(
            "AccessContrl database access!",
            bytes32(uint256(_contractAuthLevel))
        ); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External "write" contract functions / authuser---------------------------------//

    /*
     * @dev Make a new record in the database  *read fullHash, write rightsHolder, recorders, assetClass,countDownStart --new_record
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external nonReentrant whenNotPaused isAuthorized {
        require(
            database[_idxHash].assetStatus != 60,
            "PS:NR:Asset is recycled. Use T_PRUF_APP recycle instead"
        );
        require(
            database[_idxHash].rightsHolder == 0,
            "PS:NR:Rec already exists"
        );
        require(_rgt != 0, "PS:NR:RGT cannot be blank");
        require(_assetClass != 0, "PA:NR: !Asset class zero ");
        //^^^^^^^checks^^^^^^^^^

        Record memory rec;

        if (contractInfo[msg.sender].contractType == 1) {
            rec.assetStatus = 0;
        } else {
            rec.assetStatus = 51;
        }

        rec.assetClass = _assetClass;
        rec.countDownStart = _countDownStart;
        rec.countDown = _countDownStart;
        rec.rightsHolder = _rgt;
        rec.forceModCount = 0;
        rec.Ipfs1 = _Ipfs1;
        rec.numberOfTransfers = 0;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("New rec created", _idxHash);
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
        uint8 _forceCount,
        uint16 _numberOfTransfers
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
    {
        bytes32 idxHash = _idxHash; //stack saving
        bytes32 rgtHash = _rgtHash;

        require( //prohibit increasing the countdown value
            _countDown <= database[idxHash].countDown,
            "PS:MR:new countDown +!"
        );
        require(
            _forceCount >= database[idxHash].forceModCount,
            "PS:MR:new forceModCount -!"
        );
        require(
            _numberOfTransfers >= database[idxHash].numberOfTransfers,
            "PS:MR:new transferCount -!"
        );
        require(
            _newAssetStatus < 200,
            "PS:MR:assetStatus > 199 cannot be set by user"
        );
        require(
            isLostOrStolen(_newAssetStatus) == 0,
            "PS:MR:Must use stolenOrLost to set lost or stolen status"
        );
        //^^^^^^^checks^^^^^^^^^

        Record memory rec = database[_idxHash];
        rec.rightsHolder = rgtHash;
        rec.countDown = _countDown;
        rec.assetStatus = _newAssetStatus;
        rec.forceModCount = _forceCount;
        rec.numberOfTransfers = _numberOfTransfers;

        database[idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("Rec Modified", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Change asset class of an asset
     */
    function changeAC(bytes32 _idxHash, uint16 _newAssetClass)
        external
        nonReentrant
        whenNotPaused
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
    {
        Record memory rec = database[_idxHash];

        require(
            AssetClassTokenManagerContract.isSameRootAC(
                _newAssetClass,
                rec.assetClass
            ) == 170,
            "PS:CAC:Cannot change AC to new root"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetClass = _newAssetClass;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("Changed Asset Class", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset tot stolen or lost. Allows narrow modification of status 6/12 assets, normally locked
     */
    function setStolenOrLost(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        isAuthorized
        whenNotPaused
        exists(_idxHash)
    {
        require(
            isLostOrStolen(_newAssetStatus) == 170,
            "PS:SSL:Must set to L/S"
        );
        require(
            (database[_idxHash].assetStatus != 5) &&
                (database[_idxHash].assetStatus != 50) &&
                (database[_idxHash].assetStatus != 55),
            "PS:SSL:Txfr or escrow locked asset cannot be set to L/S."
        );
        //^^^^^^^checks^^^^^^^^^

        Record memory rec = database[_idxHash];
        rec.assetStatus = _newAssetStatus;
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        if ((_newAssetStatus == 3) || (_newAssetStatus == 53)) {
            emit REPORT("Status changed to STOLEN", _idxHash);
        } else {
            emit REPORT("Status changed to LOST", _idxHash);
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
        require(isEscrow(_newAssetStatus) == 170, "PS:SE: Status");
        require(
            (isLostOrStolen(database[_idxHash].assetStatus) == 0) &&
                (database[_idxHash].assetStatus != 5) &&
                (database[_idxHash].assetStatus != 55),
            "PS:SE: Cannot be set to escrow"
        );
        require(
            isEscrow(database[_idxHash].assetStatus) == 0,
            "PS:SE: In escrow status"
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
        emit REPORT("Escrow set successfully", _contractNameHash);
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
            "PS:EE:Not in escrow status"
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
        emit REPORT("Escrow Ended by contract:", _contractNameHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify record Ipfs1 data
     */
    function modifyIpfs1(bytes32 _idxHash, bytes32 _Ipfs1)
        external
        nonReentrant
        whenNotPaused
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
    {
        Record memory rec = database[_idxHash];

        require((rec.Ipfs1 != _Ipfs1), "PS:MI1: New value same as old");
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _Ipfs1;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("IPFS1 modified", _idxHash);
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
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
    {
        Record memory rec = database[_idxHash];

        require((rec.Ipfs2 == 0), "PS:MI2: Cannot overwrite IPFS2");
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _Ipfs2;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("IPFS2 modified", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------External READ ONLY contract functions / authuser---------------------------------//
    /*
     * @dev return a complete record from the database
     */
    function retrieveRecord(bytes32 _idxHash)
        external
        view
        isAuthorized
        returns (
            //bytes32,
            //bytes32,
            bytes32,
            uint8,
            uint8,
            uint16,
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
            uint16,
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
            emit REPORT("Record match confirmed", _idxHash);
            return 170;
        } else {
            emit REPORT("Record does not match", _idxHash);
            return 0;
        }
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev //returns the address of a contract with name _name. This is for web3 implementations to find the right contract to interact with
     * example :  Frontend = ****** so web 3 first asks storage where to find frontend, then calls for frontend functions.
     */
    function resolveContractAddress(string memory _name)
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
    function ContractAuthType(address _addr) external view returns (uint8) {
        return contractInfo[_addr].contractType;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev //returns the contract type of a contract with address _addr.
     */
    function ContractInfoHash(address _addr)
        external
        view
        returns (uint8, bytes32)
    {
        return (
            contractInfo[_addr].contractType,
            keccak256(abi.encodePacked(contractInfo[_addr].name))
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //-----------------------------------------------Private functions------------------------------------------------//
}
