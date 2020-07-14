/*-----------------------------------------------------------------
 *  TO DO
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, tokenless asset classes are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Order of require statements:
 * 1: (modifiers)
 * 2: checking custodial status
 * 3: checking the asset existance
 * 4: checking the idendity and credentials of the caller
 * 5: checking the suitability of provided data for the proposed operation
 * 6: checking the suitability of asset details for the proposed operation
 * 7: verifying that provided verification data matches required data
 * 8: verifying that message contains any required payment
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Contract Resolution Names -
 *  assetToken
 *  assetClassToken
 *  PRUF_APP
 *  PRUF_NP
 *  PRUF_simpleEscrow
 *  PRUF_AC_MGR
 *  PRUF_AC_Minter
 *  T_PRUF_APP
 *  T_PRUF_NP
 *  T_PRUF_simpleEscrow
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * CONTRACT Types:
 * 0   --NONE
 * 1   --Custodial
 * 2   --Non-Custodial
 * Owner (onlyOwner)
 * other = unauth
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * ASSET CLASS Types:
 * 1   --Custodial
 * 2   --Non-Custodial
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
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
 * 6 = in supervised escrow, locked until timelock expires, but can be set to lost or stolen
 *       Status 1-6 Actions cannot be performed by automation.
 *       only ACAdmins can set or unset these statuses, except 5 which can be set by automation
 * 7 = out of Supervised escrow (user < 5)
 *
 * 50 Locked escrow
 * 51 = transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 * 52 = non-transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 * 53 = stolen (automation set)(ONLY ACAdmin can unset)
 * 54 = lost (automation set/unset)(ACAdmin can unset)
 * 55 = asset transferred automation set/unset (secret confirmed)(Only ACAdmin can unset) ####DO NOT USE????
 * 56 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
 * 57 = out of escrow
 * 58 = out of locked escrow
 * 59 = Recyclable
 * 60 = Burned (can only be reimported by an ACAdmin can unset)
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Authorized User Types   registeredUsers[]
 * 1 - 4 = Standard User types
 * 1 - all priveleges
 * 2 - all but force-modify
 * 5 - 9 = Robot (cannot create of force-modify)
 * Other = unauth
 *
 *-----------------------------------------------------------------
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_interfaces_065.sol";
import "./Imports/Ownable.sol";
import "./Imports/SafeMath.sol";
import "./Imports/ReentrancyGuard.sol";

contract Storage is Ownable, ReentrancyGuard {
    //using SafeMath for uint256;

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
        uint16 numberOfTransfers; //number of transfers and forcemods
    }

    // struct User {
    //     uint8 userType; // Human / Automated / Unauthorized
    //     uint16 authorizedAssetClass; // User authorized for specific asset class
    // }

    mapping(address => uint8) private contractAdresses; // Authorized contract addresses, indexed by address, with auth level 0-255
    mapping(string => address) private contractNames; // Authorized contract addresses, indexed by name
    mapping(bytes32 => Record) private database; // Main Data Storage

    address private AssetClassTokenAddress;
    AssetClassTokenInterface private AssetClassTokenContract; //erc721_token prototype initialization

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
            (contractAdresses[msg.sender] == 1) ||
                (contractAdresses[msg.sender] == 2),
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
                (database[_idxHash].assetStatus != 56)) ||
                (database[_idxHash].timeLock < now), //Since time here is +/1 a day or so, now can be used as per the 15 second rule (consensys)
            "PS:NE:record modification prohibited while locked in escrow"
        );
        _;
    }

    /*
     * @dev Check record exists in database
     */
    modifier exists(bytes32 _idxHash) {
        require(
            database[_idxHash].rightsHolder != 0,
            "PS:E:record does not exist"
        );
        _;
    }

    /*
     * @dev Check record isn't time locked
     */
    modifier notBlockLocked(bytes32 _idxHash) {
        //this modifier makes the bold assumption the block number will "never" be reset. hopefully, this is true...
        require(
            ((database[_idxHash].assetStatus == 6) ||
                (database[_idxHash].assetStatus == 50) ||
                (database[_idxHash].assetStatus == 56) ||
                (database[_idxHash].timeLock < block.number)),
            "PS:NBL:record time locked"
        );
        _;
    }

    //-----------------------------------------------Events------------------------------------------------//

    event REPORT(string _msg, bytes32 b32);

    //--------------------------------Internal Admin functions / onlyowner or isAdmin---------------------------------//
    // /*
    //  * @dev Address Setters
    //  */
    // function OO_ResolveContractAddresses() external onlyOwner {
    //     AssetClassTokenContract = AssetClassTokenInterface(contractNames["assetClassToken"]);
    // }

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
        contractAdresses[_addr] = _contractAuthLevel;
        contractNames[_name] = _addr;
        AssetClassTokenContract = AssetClassTokenInterface(
            contractNames["assetClassToken"]
        );
        //^^^^^^^effects^^^^^^^^^
        emit REPORT(
            "internal user database access!",
            bytes32(uint256(_contractAuthLevel))
        ); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
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
    ) external nonReentrant isAuthorized {
        require(
            (database[_idxHash].rightsHolder == 0) ||
                (database[_idxHash].assetStatus == 60),
            "PS:NR:Record already exists"
        );
        require(_rgt != 0, "PS:NR:Rightsholder cannot be blank");
        require(_assetClass != 0, "PA:NR: Asset class cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        Record memory rec;
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));

        if (contractAdresses[msg.sender] == 1) {
            rec.assetStatus = 0;
        } else {
            rec.assetStatus = 51;
        }

        rec.assetClass = _assetClass;
        rec.countDownStart = _countDownStart;
        rec.countDown = _countDownStart;
        rec.recorder = _userHash;
        rec.rightsHolder = _rgt;
        rec.lastRecorder = senderHash;
        rec.forceModCount = 0;
        rec.Ipfs1 = _Ipfs1;
        rec.numberOfTransfers = 0;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("New record created", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify a record in the database  *read fullHash, write rightsHolder, update recorder, assetClass,countDown update recorder....
     */
    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint256 _countDown,
        uint8 _forceCount,
        uint16 _numberOfTransfers
    )
        external
        nonReentrant
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
        notBlockLocked(_idxHash)
    {
        bytes32 idxHash = _idxHash; //stack saving
        bytes32 rgtHash = _rgtHash;

        require( //prohibit increasing the countdown value
            _countDown <= database[idxHash].countDown,
            "PS:MR:new countDown exceeds original countDown"
        );
        require(
            _forceCount >= database[idxHash].forceModCount,
            "PS:MR:new forceModCount less than original forceModCount"
        );
        require(
            _numberOfTransfers >= database[idxHash].numberOfTransfers,
            "PS:MR:new transferCount less than original transferCount"
        );
        require(
            _newAssetStatus < 200,
            "PS:MR:assetStatus over 199 cannot be set by user"
        );
        require(
            (_newAssetStatus != 3) &&
                (_newAssetStatus != 4) &&
                (_newAssetStatus != 53) &&
                (_newAssetStatus != 54),
            "PS:MR:Must use stolenOrLost function to set lost or stolen status"
        );
        //^^^^^^^checks^^^^^^^^^

        database[idxHash].timeLock = block.number;
        Record memory rec = database[_idxHash];

        (rec.lastRecorder, rec.recorder) = storeRecorder(_idxHash, _userHash);
        rec.rightsHolder = rgtHash;
        rec.countDown = _countDown;
        rec.assetStatus = _newAssetStatus;
        rec.forceModCount = _forceCount;
        rec.numberOfTransfers = _numberOfTransfers;

        database[idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("Record Modified", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset tot stolen or lost. Allows narrow modification of status 6/12 assets, normally locked
     */
    function setStolenOrLost(
        bytes32 _userHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus
    )
        external
        nonReentrant
        isAuthorized
        exists(_idxHash)
        notBlockLocked(_idxHash)
    //isACtokenHolder(_idxHash)
    {
        require(
            (_newAssetStatus == 3) ||
                (_newAssetStatus == 4) ||
                (_newAssetStatus == 53) ||
                (_newAssetStatus == 54),
            "PS:SSL:Must set to a lost or stolen status"
        );
        require(
            (database[_idxHash].assetStatus != 5) &&
                (database[_idxHash].assetStatus != 55),
            "PS:SSL:Transferred asset cannot be set to lost or stolen after transfer."
        );
        //^^^^^^^checks^^^^^^^^^

        database[_idxHash].timeLock = block.number;
        Record memory rec = database[_idxHash];

        (rec.lastRecorder, rec.recorder) = storeRecorder(_idxHash, _userHash);
        rec.assetStatus = _newAssetStatus;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^

        if ((_newAssetStatus == 3) || (_newAssetStatus == 53)) {
            emit REPORT("Record status changed to STOLEN", _idxHash);
        } else {
            emit REPORT("Record status changed to LOST", _idxHash);
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     */
    function setEscrow(
        bytes32 _EscrowOwnerHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        uint256 _escrowTime
    )
        external
        nonReentrant
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
        notBlockLocked(_idxHash)
    //isACtokenHolder(_idxHash)
    {
        require(
            (_newAssetStatus == 6) ||
                (_newAssetStatus == 50) ||
                (_newAssetStatus == 56),
            "PS:SE: Must set to an escrow status"
        );
        require(
            (database[_idxHash].assetStatus != 3) &&
                (database[_idxHash].assetStatus != 4) &&
                (database[_idxHash].assetStatus != 53) &&
                (database[_idxHash].assetStatus != 54) &&
                (database[_idxHash].assetStatus != 5) &&
                (database[_idxHash].assetStatus != 55),
            "PS:SE: Transferred, lost, or stolen status cannot be set to escrow."
        );
        //^^^^^^^checks^^^^^^^^^

        database[_idxHash].timeLock = block.number;
        Record memory rec = database[_idxHash];

        (rec.lastRecorder, rec.recorder) = storeRecorder(
            _idxHash,
            _EscrowOwnerHash
        );
        rec.assetStatus = _newAssetStatus;
        rec.timeLock = _escrowTime;

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("Record locked for escrow", _EscrowOwnerHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status
     */
    function endEscrow(bytes32 _userHash, bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized
        notBlockLocked(_idxHash)
        exists(_idxHash)
    {
        require(
            (database[_idxHash].assetStatus == 6) ||
                (database[_idxHash].assetStatus == 50) ||
                (database[_idxHash].assetStatus == 56),
            "PS:EE:Asset not in escrow"
        );
        //^^^^^^^checks^^^^^^^^^

        database[_idxHash].timeLock = block.number;
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

        (rec.lastRecorder, rec.recorder) = storeRecorder(_idxHash, _userHash);
        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("Escrow Ended by", _userHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify record Ipfs1 data
     */
    function modifyIpfs1(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs1
    )
        external
        nonReentrant
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
        notBlockLocked(_idxHash)
    {
        Record memory rec = database[_idxHash];

        require((rec.Ipfs1 != _Ipfs1), "PS:MI1: New value same as old");
        //^^^^^^^checks^^^^^^^^^

        database[_idxHash].timeLock = block.number;

        rec.Ipfs1 = _Ipfs1;

        (rec.lastRecorder, rec.recorder) = storeRecorder(_idxHash, _userHash);
        //^^storeRecorder() is view, private

        database[_idxHash] = rec;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("IPFS1 modified", _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function modifyIpfs2(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs2
    )
        external
        nonReentrant
        isAuthorized
        exists(_idxHash)
        notEscrow(_idxHash)
        notBlockLocked(_idxHash)
    //isACtokenHolder(_idxHash)
    {
        Record memory rec = database[_idxHash];

        require((rec.Ipfs2 == 0), "PS:MI2: Cannot overwrite IPFS2");
        //^^^^^^^checks^^^^^^^^^

        database[_idxHash].timeLock = block.number;

        rec.Ipfs2 = _Ipfs2;

        (rec.lastRecorder, rec.recorder) = storeRecorder(_idxHash, _userHash);
        //^^storeRecorder() is view, private

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
            bytes32,
            bytes32,
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
            rec.recorder,
            rec.rightsHolder,
            rec.lastRecorder,
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
            bytes32,
            bytes32,
            uint8,
            uint8,
            uint16,
            uint256,
            uint256,
            bytes32,
            bytes32,
            uint16,
            uint256
        )
    {
        Record memory rec = database[_idxHash];

        // if (
        //     (rec.assetStatus == 3) ||
        //     (rec.assetStatus == 4) ||
        //     (rec.assetStatus == 53) ||
        //     (rec.assetStatus == 54)
        // ) {
        //     emit REPORT_B32("Lost or stolen record queried", _idxHash);
        // }

        return (
            rec.recorder,
            rec.lastRecorder,
            rec.assetStatus,
            rec.forceModCount,
            rec.assetClass,
            rec.countDown,
            rec.countDownStart,
            rec.Ipfs1,
            rec.Ipfs2,
            rec.numberOfTransfers,
            rec.timeLock
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
        public
        view
        returns (address)
    {
        return contractNames[_name];
        //^^^^^^^interactions^^^^^^^^^
    }

    //-----------------------------------------------Private functions------------------------------------------------//

    /*
     * @dev Update lastRecorder
     */
    function storeRecorder(bytes32 _idxHash, bytes32 _recorder)
        private
        view
        returns (bytes32, bytes32)
    {
        if (database[_idxHash].recorder != _recorder) {
            return (database[_idxHash].recorder, _recorder);
        } else {
            return (database[_idxHash].lastRecorder, _recorder);
        }
        //^^^^^^^checks/interactions^^^^^^^^^
    }
}
