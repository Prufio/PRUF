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
 *  prufPayable
 *  prufNonPayable
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
 * 55 = asset transferred automation set/unset (secret confirmed)(ACAdmin can unset)
 * 56 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
 * 57 = out of escrow
 * 58 = out of locked escrow
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

import "./PRUF_interfaces.sol";
import "./Imports/Ownable.sol";
import "./Imports/SafeMath.sol";
import "./Imports/ReentrancyGuard.sol";
import "./_ERC721/IERC721Receiver.sol";


contract PRUF_NP is Ownable, IERC721Receiver, ReentrancyGuard {
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

    address private storageAddress;

    StorageInterface private Storage; // Set up external contract interface

    // address minterContractAddress;
    address private AssetTokenAddress;
    AssetTokenInterface private AssetTokenContract; //erc721_token prototype initialization
    address private AssetClassTokenAddress;
    AssetClassTokenInterface private AssetClassTokenContract; //erc721_token prototype initialization
    address private prufPayableAddress;
    prufPayableInterface private prufPayableContract; //erc721_token prototype initialization
    // --------------------------------------Events--------------------------------------------//

    event REPORT(string _msg);
    // --------------------------------------Modifiers--------------------------------------------//

    // modifier isAuthorized(bytes32 _idxHash) {
    //     uint256 tokenID = uint256(_idxHash);
    //     User memory user = getUser();

    //     require(
    //         (((user.userType > 0) && (user.userType < 10)) &&
    //             (AssetTokenContract.ownerOf(tokenID) == address(this))) || //User is authorized in database and contract holds token
    //             (AssetTokenContract.ownerOf(tokenID) == msg.sender), //or msg.sender is token holder
    //         "ST:MOD-UA-ERR:User not registered "
    //     );
    //     _;
    // }
    modifier isAuthorized(bytes32 _idxHash) {
        uint256 tokenID = uint256(_idxHash);
        User memory user = getUser();

        require(
            (((user.userType > 0) && (user.userType < 10)), 
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

        prufPayableAddress = Storage.resolveContractAddress("prufPayable");
        prufPayableContract = prufPayableInterface(prufPayableAddress);
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
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "MS: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "MS:ERR-Cannot change status of asset in transferred-unregistered status."
        );
        require(
            (rec.assetStatus > 49) || (callingUser.userType < 5),
            "SS:ERR-Only usertype < 5 can change status < 49"
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
                (_newAssetStatus == 53) ||
                (_newAssetStatus == 54),
            "SS:ERR-Must set to a lost or stolen status"
        );
        require(
            (rec.assetStatus > 49) ||
                ((_newAssetStatus < 50) && (callingUser.userType < 5)),
            "SS:ERR-Only usertype <5 can change a <49 status asset to a >49 status"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "SS:ERR-Transferred asset cannot be set to lost or stolen after transfer."
        );
        require(
            (rec.assetStatus != 50),
            "SS:ERR-Asset in locked escrow cannot be set to lost or stolen"
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
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //If so, it must not erase the recorder, or escrow termination will be broken!
            "DC: Cannot modify asset in Escrow"
        );
        require(_decAmount > 0, "DC: cannot decrement by negative number");
        require(rec.assetStatus < 200, "DC: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
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
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //Should it be contingent on the original recorder address?
            "MI1: Cannot modify asset in Escrow" //If so, it must not erase the recorder, or escrow termination will be broken!
        );
        require(rec.assetStatus < 200, "MI1: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
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
        (user.userType, user.authorizedAssetClass) = prufPayableContract
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
