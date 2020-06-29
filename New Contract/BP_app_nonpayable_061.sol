/*  TO DO
 * verify security and user permissioning /modifiers
 *
 * mint a token at asset creation
 *
 * @implement remint_asset ?
 *-----------------------------------------------------------------------------------------------------------------
 * Should all assets have a token, minted to reside within the contract for curated / "nontokenized" asset classes?
 * If so, make a move-token function that can be enabled later (set to an address to control it)
 *-----------------------------------------------------------------------------------------------------------------
 *
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, tokenless asset classes are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
*
 * Order of require statements:
 * 1: (modifiers)
 * 2: checking the asset existance
 * 3: checking the idendity and credentials of the caller
 * 4: checking the suitability of provided data for the proposed operation
 * 5: checking the suitability of asset details for the proposed operation
 * 6: verifying that provided verification data matches required data
 * 7: verifying that message contains any required payment
 *
 *
 * Contract Resolution Names -
 *  assetToken
 *  assetClassToken
 *  BPappPayable
 *  BPappNonPayable
 *
 * CONTRACT Types (storage)
 * 0   --NONE
 * 1   --E
 * 2   --RE
 * 3   --RWE
 * 4   --ADMIN (isAdmin)
 * >4  NONE
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
 * 9 = stolen (automation set)(ONLY ACAdmin can unset)
 * 10 = lost (automation set/unset)(ACAdmin can unset)
 * 11 = asset transferred automation set/unset (secret confirmed)(ACAdmin can unset)
 * 12 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
 *
 * escrow status = lock time set to a time instead of a block number
 *
 *
 * Authorized User Types   registeredUsers[]
 *
 * 1 - 4 = Standard User types
 * 1 - all priveleges
 * 2 - all but force-modify
 * 5 - 9 = Robot (cannot create of force-modify)
 * Other = unauth
 *
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;
import "./Imports/Ownable.sol";
import "./Imports/SafeMath.sol";
import "./Imports/ReentrancyGuard.sol";
import "./_ERC721/IERC721Receiver.sol";

interface BPappPayableInterface {
    function getUserExt(bytes32 _userHash)
        external
        view
        returns (uint8, uint16);
}

interface AssetClassTokenInterface {
    function ownerOf(uint256) external view returns (address);

    function transferAssetClassToken(
        address from,
        address to,
        bytes32 idxHash
    ) external;
}

interface AssetTokenInterface {
    function ownerOf(uint256) external view returns (address);

    function transferAssetToken(
        address from,
        address to,
        bytes32 idxHash
    ) external;
}

interface StorageInterface {
    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount,
        uint16 _numberOfTransfers
    ) external;

    function setStolenOrLost(
        bytes32 _userHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus
    ) external;

    function modifyIpfs1(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs1
    ) external;

    function setEscrow(
        bytes32 _userHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        uint256 _escrowTime
    ) external;

    function endEscrow(
        bytes32 _userHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus
    ) external;

    function ACTH_setCosts(
        uint16 _class,
        uint256 _newRecordCost,
        uint256 _transferRecordCost,
        uint256 _createNoteCost,
        uint256 _reMintRecordCost,
        uint256 _modifyStatusCost,
        uint256 _forceModCost,
        address _paymentAddress
    ) external;

    function retrieveRecord(bytes32 _idxHash)
        external
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
        );

    function retrieveShortRecord(bytes32 _idxHash)
        external
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
        );

    function _verifyRightsHolder(bytes32, bytes32) external returns (uint256);

    function blockchainVerifyRightsHolder(bytes32, bytes32)
        external
        returns (uint8);

    function retrieveCosts(uint16 _assetClass)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function retrieveBaseCosts()
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function resolveContractAddress(string calldata _name)
        external
        returns (address);
}

contract BP_APP_NP is Ownable, IERC721Receiver, ReentrancyGuard {
    using SafeMath for uint256;

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

    struct User {
        uint8 userType; // User type: 1 = human, 9 = automated
        uint16 authorizedAssetClass; // Asset class in which user is permitted to transact
    }

    struct Costs {
        uint256 newRecordCost; // Cost to create a new record
        uint256 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        uint256 createNoteCost; // Cost to add a static note to an asset
        uint256 reMintRecordCost; // Extra
        uint256 changeStatusCost; // Extra
        uint256 forceModifyCost; // Cost to brute-force a record transfer
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    address private storageAddress;

    StorageInterface private Storage; // Set up external contract interface

    // address minterContractAddress;
    address private AssetTokenAddress;
    AssetTokenInterface private AssetTokenContract; //erc721_token prototype initialization
    address private AssetClassTokenAddress;
    AssetClassTokenInterface private AssetClassTokenContract; //erc721_token prototype initialization
    address private BPappPayableAddress;
    BPappPayableInterface private BPappPayableContract; //erc721_token prototype initialization
    // --------------------------------------Events--------------------------------------------//

    event REPORT(string _msg);
    // --------------------------------------Modifiers--------------------------------------------//

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 to 9
     *      Is authorized for asset class
     *      asset token held by this.contract
     * ----OR---- (comment out part that will not be used)
     *      holds asset token
     */
    modifier isAuthorized(bytes32 _idxHash) {
        uint256 tokenID = uint256(_idxHash);
        User memory user = getUser();

        require(
            (((user.userType > 0) && (user.userType < 10)) &&
            (AssetTokenContract.ownerOf(tokenID) == BPappPayableAddress)) || //User is authorized in database and contract holds token
            (AssetTokenContract.ownerOf(tokenID) == msg.sender), //or msg.sender is token holder
            "ST:MOD-UA-ERR:User not registered "
        );
        _;
    }

    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//
    /*
     * @dev Address Setters
     */

    function OO_ResolveContractAddresses() external onlyOwner nonReentrant {
        //^^^^^^^checks^^^^^^^^^
        AssetClassTokenAddress = Storage.resolveContractAddress(
            "assetClassToken"
        );
        AssetClassTokenContract = AssetClassTokenInterface(
            AssetClassTokenAddress
        );

        AssetTokenAddress = Storage.resolveContractAddress("assetToken");
        AssetTokenContract = AssetTokenInterface(AssetTokenAddress);

        BPappPayableAddress = Storage.resolveContractAddress("BPappPayable");
        BPappPayableContract = BPappPayableInterface(BPappPayableAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    function OO_TX_asset_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
        nonReentrant
    //^^^^^^^checks^^^^^^^^^
    {
        AssetTokenContract.transferAssetToken(address(this), _to, _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function OO_TX_AC_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
        nonReentrant
    //^^^^^^^checks^^^^^^^^^
    {
        AssetClassTokenContract.transferAssetClassToken(
            address(this),
            _to,
            _idxHash
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "ADMIN: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage = StorageInterface(_storageAddress);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//
    /*
     * @dev Compliance for erc721
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
        //^^^^^^^interactions^^^^^^^^^
    }

    function setEscrow(bytes32 _idxHash, uint256 _escrowTime, bytes32 _escrowOwnerHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        uint256 escrowTime = now.add(_escrowTime); //set escrow end time to _escrowTime seconds in the future
        uint8 newAssetStatus;

        require((rec.rightsHolder != 0), "SE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "SE: User not authorized to modify records in specified asset class"
        );
        require(
            (escrowTime >= now),
            "SE:ERR-Escrow must be set to a time in the future"
        );
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 9) &&
                (rec.assetStatus != 10),
            "SE:ERR-Transferred, lost, or stolen status cannot be set to escrow."
        );
        //^^^^^^^checks^^^^^^^^^

        if (callingUser.userType < 5) {
            //If escrow was initiated by custodial user
            newAssetStatus = 6; //Set asset status to 6 (left custodial escrow)
        } else {
            //escrow initiated by automation
            newAssetStatus = 12; //Set asset status to 12 (left P2P escrow)
        }
        //^^^^^^^effects^^^^^^^^^

        Storage.setEscrow(
            _escrowOwnerHash,
            _idxHash,
            newAssetStatus,
            escrowTime
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Record memory shortRec = getShortRecord(_idxHash);
        User memory callingUser = getUser();
        uint8 _newAssetStatus;

        require((rec.rightsHolder != 0), "EE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "EE: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 6) || (rec.assetStatus == 12),
            "EE:ERR- record must be in escrow status"
        );
        require(
            ((rec.assetStatus == 12) || (callingUser.userType < 5)),
            "EE:ERR- Usertype less than 5 required to end this escrow"
        );
        require(
            (shortRec.timeLock < now) ||
                (keccak256(abi.encodePacked(msg.sender)) == rec.recorder),
            "EE:ERR- Escrow period not ended"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.assetStatus == 6) {
            //If escrow was initiated by custodial user
            _newAssetStatus = 20; //Set asset status to 20 (left custodial escrow)
        } else {
            //escrow initiated by automation
            _newAssetStatus = 21; //Set asset status to 21 (left P2P escrow)
        }
        //^^^^^^^effects^^^^^^^^^

        Storage.endEscrow(
            keccak256(abi.encodePacked(msg.sender)),
            _idxHash,
            _newAssetStatus
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function _modStatus(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    ) external nonReentrant isAuthorized(_idxHash) returns (uint8) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();

        require((rec.rightsHolder != 0), "MS: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "MS: User not authorized to modify records in specified asset class"
        );
        require(_newAssetStatus < 200, "MS: user cannot set status > 199");
        require(
            (rec.assetStatus != 6) && (rec.assetStatus != 12),
            "MS: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            (rec.assetStatus != 5),
            "MS:ERR-Cannot change status of asset in transferred-unregistered status."
        );
        require(
            (rec.assetStatus > 6) || (callingUser.userType < 5),
            "SS:ERR-Only usertype < 5 can change status < 7"
        );
        require(rec.assetStatus < 200, "MS: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "MS: ERR-Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation required.
     */
    function _setLostOrStolen(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    ) external nonReentrant isAuthorized(_idxHash) returns (uint8) {
        Record memory rec = getRecord(_idxHash);
        rec.assetStatus = _newAssetStatus;
        User memory callingUser = getUser();

        require((rec.rightsHolder != 0), "SS: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "SS: User not authorized to modify records in specified asset class"
        );
        require(
            (_newAssetStatus == 3) ||
                (_newAssetStatus == 4) ||
                (_newAssetStatus == 9) ||
                (_newAssetStatus == 10),
            "SS:ERR-Must set to a lost or stolen status"
        );
        require(
            (rec.assetStatus > 6) ||
                (_newAssetStatus < 7) ||
                (callingUser.userType < 5),
            "SS:ERR-Only usertype <5 can change a <7 status asset to a >7 status"
        );
        require(
            (rec.assetStatus != 5),
            "SS:ERR-Transferred asset cannot be set to lost or stolen after transfer."
        );
        require(rec.assetStatus < 200, "RR: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "SS: ERR-Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        Storage.setStolenOrLost(userHash, _idxHash, rec.assetStatus);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function _decCounter(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint256 _decAmount
    ) external nonReentrant isAuthorized(_idxHash) returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();

        require((rec.rightsHolder != 0), "DC: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "DC: User not authorized to modify records in specified asset class"
        );
        require( //------------------------------------------should the counter still work when an asset is in escrow?
            (rec.assetStatus != 6) && (rec.assetStatus != 12), //If so, it must not erase the recorder, or escrow termination will be broken!
            "DC: Cannot modify asset in Escrow"
        );
        require(_decAmount > 0, "DC: cannot decrement by negative number");
        require(rec.assetStatus < 200, "DC: Record locked");
        require(
            rec.assetStatus != 5,
            "DC: Record In Transferred-unregistered status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "DC: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown.sub(_decAmount);
        } else {
            rec.countDown = 0;
        }
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        return (rec.countDown);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs1 with confirmation
     */
    function _modIpfs1(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    ) external nonReentrant isAuthorized(_idxHash) returns (bytes32) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        //Costs memory cost = getCost(rec.assetClass);

        require((rec.rightsHolder != 0), "MI1: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "MI1: User not authorized to modify records in specified asset class"
        );

        require(rec.Ipfs1 != _IpfsHash, "MI1:ERR--New data same as old");
        require( //-------------------------------------Should an asset in escrow be modifiable?
            ((rec.assetStatus != 6) && (rec.assetStatus != 12)), //Should it be contingent on the original recorder address?
            "MI1: Cannot modify asset in Escrow" //If so, it must not erase the recorder, or escrow termination will be broken!
        );
        require(rec.assetStatus < 200, "MI1: Record locked");
        require(
            rec.assetStatus != 5,
            "DC: Record In Transferred-unregistered status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "MI1:ERR--Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Private functions
    /*
     * @dev Get a User Record from Storage @ msg.sender
     */
    function getUser() private view returns (User memory) {
        //User memory callingUser = getUser();
        User memory user;
        (user.userType, user.authorizedAssetClass) = BPappPayableContract
            .getUserExt(keccak256(abi.encodePacked(msg.sender)));
        return user;
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Storage Reading private functions
    /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord(bytes32 _idxHash) private returns (Record memory) {
        Record memory rec;

        {
            //Start of scope limit for stack depth
            (
                bytes32 _recorder,
                bytes32 _rightsHolder,
                bytes32 _lastRecorder,
                uint8 _assetStatus,
                uint8 _forceModCount,
                uint16 _assetClass,
                uint256 _countDown,
                uint256 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2,
                uint16 _numberOfTransfers
            ) = Storage.retrieveRecord(_idxHash); // Get record from storage contract

            rec.recorder = _recorder;
            rec.rightsHolder = _rightsHolder;
            rec.lastRecorder = _lastRecorder;
            rec.assetStatus = _assetStatus;
            rec.forceModCount = _forceModCount;
            rec.assetClass = _assetClass;
            rec.countDown = _countDown;
            rec.countDownStart = _countDownStart;
            rec.Ipfs1 = _Ipfs1;
            rec.Ipfs2 = _Ipfs2;
            rec.numberOfTransfers = _numberOfTransfers;
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Get a ShortRecord from Storage @ idxHash
     */
    function getShortRecord(bytes32 _idxHash) private returns (Record memory) {
        Record memory rec;

        {
            //Start of scope limit for stack depth
            (
                bytes32 _recorder,
                bytes32 _lastRecorder,
                uint8 _assetStatus,
                uint8 _forceModCount,
                uint16 _assetClass,
                uint256 _countDown,
                uint256 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2,
                uint16 _numberOfTransfers,
                uint256 _timeLock
            ) = Storage.retrieveShortRecord(_idxHash); // Get record from storage contract

            rec.recorder = _recorder;
            rec.lastRecorder = _lastRecorder;
            rec.assetStatus = _assetStatus;
            rec.forceModCount = _forceModCount;
            rec.assetClass = _assetClass;
            rec.countDown = _countDown;
            rec.countDownStart = _countDownStart;
            rec.Ipfs1 = _Ipfs1;
            rec.Ipfs2 = _Ipfs2;
            rec.numberOfTransfers = _numberOfTransfers;
            rec.timeLock = _timeLock;
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Storage Writing private functions

    /*
     * @dev Write an Ipfs Record to Storage @ idxHash
     */
    function writeRecordIpfs1(bytes32 _idxHash, Record memory _rec)
        private
        isAuthorized(_idxHash)
    //^^^^^^^checks^^^^^^^^^
    {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging
        //^^^^^^^effects^^^^^^^^^
        Storage.modifyIpfs1(userHash, _idxHash, _rec.Ipfs1); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        private
        isAuthorized(_idxHash)
    //^^^^^^^checks^^^^^^^^^
    {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging
        //^^^^^^^effects^^^^^^^^^
        Storage.modifyRecord(
            userHash,
            _idxHash,
            _rec.rightsHolder,
            _rec.assetStatus,
            _rec.countDown,
            _rec.forceModCount,
            _rec.numberOfTransfers
        ); // Send data and writehash to storage
        //^^^^^^^interactions^^^^^^^^^
    }
}
